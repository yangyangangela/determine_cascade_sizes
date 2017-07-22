function [results, inovl, inOl, inld, trig_origin, Outlines, Proc, Proc_time, rrmpc] = Cascade(sqr, dr, dispon,rmpc,ntrig,Tinner_branch,branch_comm,TStrategy,tnc)
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


%% Recursive cascade model

% cascade propogate step
t = 1;
flag = 1; % mark if the cascade continues (=1) or not (=0)

prev_results = mpc;
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
    
    % if new line failed, do tracing
    if ~isempty(ovl)
        [delta_r, delta_g] = trace_flow_change(prev_results, results, fail_index);
    end
    
    % cascade propogation step
    t = t + 1;
    
    %
    prev_results = results;
    
    
    
end



return;
