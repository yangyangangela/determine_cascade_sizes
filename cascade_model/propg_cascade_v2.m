function [new_mpc, new_T0, flag,Outlines,new_Proc,t2b, fail_index] = propg_cascade_v2(mpc,ovl,T0,Outlines,Proc,dispon)
% cut off the line which reaches the critical temperature first
% update the temperature of all other lines

% input:
% mpc: matlab structure
% ovl: index of overload lines
% T0: the temperature of all lines

% Output:
% new_mpc:
% new_T0: the temperature of all lines when the line was cut off
% flag = 1: contine propagating, 0:stop here
% new_Proc: sparse vector containing the burned line in sequence
% t2b: the time between the previous burned line to next burned line
% fail_index: the index of the failed line

fail_index = nan;

new_mpc = mpc;
new_T0 = T0;
new_Proc = Proc;
t2b = 0;

% some index
RATE_A = 6;
PF = 14;

%power flow on each line
P = mpc.branch(:,PF);

if length(ovl) == 0
    flag = 0;
    return;
else
    flag = 1;
    
    % The time for overload lines to reach their critical temperature
    tel = -log((mpc.branch(ovl,RATE_A).^2 - P(ovl).^2)./(T0(ovl) - P(ovl).^2));
    
    if ~isempty(find(tel< -1e5,1))
        mpc.branch(ovl,RATE_A).^2 - P(ovl).^2
        T0(ovl) - P(ovl).^2
        T0(ovl)
        Outlines(ovl)
        error('time below zero');
    end
    
    % select the line that first reaches critical temperature
    [t, ind] = min(tel);
    t2b = t; % record the time
    
    % update the temperature for all lines
    new_T0 = exp(-t) * (T0 - P.^2) + P.^2;
    
    if ~isempty(find(~isreal(new_T0)))
        new_T0(~isreal(new_T0))
        T0(~isreal(new_T0))
        P(~isreal(new_T0))
        mpc.branch(~isreal(new_T0))
        Outlines(~isreal(new_T0))
    error('not real temperature');
    end
    
    % cut off the line
    [new_mpc Outlines] = cutoff_line(new_mpc,ovl(ind),Outlines);
    
    % the index of failed line
    fail_index=ovl(ind);
    
    % record the process
    pt = find(new_Proc==0,1);
    new_Proc(pt) = ovl(ind);
    
end

if dispon == 1
disp('Propogating...');
disp('The tobe-cutoff lines index for this time:');
disp(num2str(ovl(ind)));
disp('Total lineoutage number:');
disp(num2str(length(find(Outlines==0))));


end