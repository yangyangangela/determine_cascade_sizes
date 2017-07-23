function [results, inovl, inOl, inld, trig_origin, Outlines, Proc, Proc_time, rrmpc, tracing_res] = Cascade(sqr, dr, dispon,rmpc,ntrig,Tinner_branch,branch_comm,TStrategy,tnc)
% Start from an initial power grid, propogate cascade until no transmission
% lines will be triggered. Return the final power grid structure mpc.
%
% Input:
%   sqr: the ratio squeeze the line capacity
%   ir: the ratio increase or decrease the interdependency
%   dr: the ratio to tune the total load demand.
%   dispon: display the general info or not.
%   rmpc: matpower data
%   ntrig: number of triggers
%   Tinner_branch: the set of transmission lines to choose triggers from. default is all lines.
%   branch_comm: advanced setting, indicating the community index of each branch
%   TStrategy: advanced setting, indicating how to select triggers, default is random.
%   tnc: initial trigger regions, 
%
% Output:
%   results: power grid structure in matpower format
%   inOl: index of transmission lines that are not in-service initially.
%   inld: initial required total load.
%   inovl: initial overload lines index
%   trig_origin: the line indices of all triggers
%   Outlines: a binary vector indicating the final on/off status of each
%   transmission line
%   Proc : sparse vector, record the line index that has been tripped during
%           the cascade.
%   Proc_time: sparse vector, record the time separtion (scaled by some
%               constants) between two consecutive line trips.
%   rrmpc: the data structure before cascade
%   tracing_res.Delta_*: failure-causing line flow changes due to rerouting (*=r) 
%               and generation change (*=g)
%   tracing_res.Rerouting: =1 if failure is caused purely by rerouting, =0
%               if generation change or mixed, =-1 for triggering failures

% by Yang Yang
% 2016-12-18
%% initiate

global T0; % record the temperature of each line

mpopt = mpoption('OUT_ALL',0);

% set up the parameter for this test
[mpc, inOl, inld] = setup_case(sqr, dr, rmpc);


% initilize Outlines
nl = length(mpc.branch);
Outlines = ones(1, nl);
Outlines(inOl==0) = 0;

% initiate the line temperature
nl = length(mpc.branch);
T0 = zeros(nl,1);

% initiate the burned line sequence (outage sequence)
Proc = spalloc(1,nl,floor(0.1*nl));

% record the time span (scaled by some constant) between two consecutive
% outages
Proc_time = spalloc(1,nl,floor(0.1*nl));

% calculate the power flow
results = rundcpf(mpc,mpopt);


%% run the initial power flow
resultsmpc = rmfield(results,{'order','et','success'});

% adjust the slack bus, if needed
mpc = distri_slack(resultsmpc);

% run power flow again
results = rundcpf(mpc,mpopt);

% some index constants
RATE_A = 6;
PF = 14;
F_BUS = 1;
T_BUS = 2;

% make sure all lines are within 95% of Rate_A
ovl = check_overload(results, 0.05);
mpc.branch(ovl, RATE_A) = abs(results.branch(ovl,PF))* 1.06;
results = rundcpf(mpc,mpopt);

% copy the data before cascade
rrmpc = results;


%% check inital power flow result overloaded lines, it should have no initial
% overload.
ovl = check_overload(results,0);
inovl = ovl;
tload_dl = sum(results.gen(results.gen(:,2)>0,2));

% display the general info
if dispon == 1
    display_geninfo(sqr,dr,inOl,inld,ovl,tload_dl);
end


%% randomly select triggers from Tinner_branch (default is all lines can be selected as triggers)
[mpc, trig_origin, Outlines] = trig_line(mpc, Outlines, ntrig, Tinner_branch,branch_comm, TStrategy,tnc);

% record the triggers
pt = find(Proc ==0,1);
for i = 1 : length(trig_origin)
    Proc(1,pt+i-1) = trig_origin(i);
end

prev_results = results;


%% Recursive cascade model

% cascade propogate step
t = 1;
flag = 1; % mark if the cascade continues (=1) or not (=0)

% tolerance used to determine the sign of flow changes
tol = 1e-8;

% Will store cumulative line flow changes due to rerouting (r) and changes
% in the generation (g)
delta_r_c = zeros(nl,1);
delta_g_c = zeros(nl,1);
Delta_r = zeros(1,nl);
Delta_g = zeros(1,nl);
Rerouting = zeros(1,nl);
Rerouting(trig_origin) = -1;
while (~isempty(ovl) > 0 && tload_dl > 0 && flag ==1) || t==1
       
    % run test pf
    test_results = rundcpf(mpc,mpopt);
    resultsmpc = rmfield(test_results,{'order','et','success'});
    
    % assign the slack bus
    mpc = distri_slack(resultsmpc);
    
    % run power flow again
    results = rundcpf(mpc,mpopt);
     
    % check and print out the overload line indices
    ovl = check_overload(results,0);
    
    [mpc, T0, flag, Outlines,Proc,proctime, fail_index] = propg_cascade_v2(results,ovl,T0,Outlines,Proc,dispon);
    Proc_time(t+ntrig) = proctime;
    
    % if there is an overloaded line, do the tracing, compute delta_*, and
    % add to Delta_*, the cumulative line flow changes
    if ~isempty(ovl)
%         fprintf('t = %d: Overloading occured\n', t);
        [delta_r, delta_g] = trace_flow_change(prev_results, results, ovl);
        delta_r_c(ovl) = delta_r_c(ovl) + delta_r;
        delta_g_c(ovl) = delta_g_c(ovl) + delta_g;
        ix = true(nl,1);
        ix(ovl) = false;
        delta_r_c(ix) = 0;
        delta_g_c(ix) = 0;
        
%         for k = 1:nl
%             if ~ix(k)
%                 fprintf(' %d->%d: Delta_r=%6.2f, Delta_g=%6.2f, Delta=%6.2f, f=%6.2f, RATE_A=%6.2f\n', ...
%                     results.branch(k,F_BUS), ...
%                     results.branch(k,T_BUS), ...
%                     Delta_r(k), Delta_g(k), Delta_r(k)+Delta_g(k), ...
%                     abs(results.branch(k,PF)), ...
%                     results.branch(k,RATE_A));
%             end
%         end
    
        k = fail_index;
        Delta_r(k) = delta_r_c(k);
        Delta_g(k) = delta_g_c(k);
        Delta = Delta_r(k) + Delta_g(k);
        if (Delta > tol && Delta_r(k) > tol && Delta_g(k) < tol) ...
                || (Delta < -tol && Delta_r(k) < -tol && Delta_g(k) > -tol)
            Rerouting(k) = 1;       
            fprintf('t=% 3d: cause=r, ', t);
        else
            fprintf('t=% 3d: cause= , ', t);
        end
        fprintf('failed line: % 5d->% 5d, Delta_r=%6.2f, Delta_g=%6.2f, Delta=%6.2f, prev_flow=%6.2f, curr_flow=%6.2f, RATE_A=%6.2f\n', ...
            results.branch(k,F_BUS), ...
            results.branch(k,T_BUS), ...
            Delta_r(k), Delta_g(k), Delta_r(k)+Delta_g(k), ...
            prev_results.branch(k,PF), ...
            results.branch(k,PF), ...
            results.branch(k,RATE_A));
    end

    % cascade propogation step
    t = t + 1;
    
    %
    prev_results = results;
    
    
    
end

tracing_res.Delta_r = Delta_r;
tracing_res.Delta_g = Delta_g;
tracing_res.Rerouting = Rerouting;



return;
