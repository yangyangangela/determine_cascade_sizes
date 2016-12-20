function [new_mpc Outlines] = cutoff_line(old_mpc,cutl,Outlines)
% Input:
%   old_branch: branch data in matpower format
%   cutl: the index of line needs to cutoff
% Output:
%   new_mpc data: set the line not-in-service
%   Outlines: binary vector indicating on/off status

new_mpc = old_mpc;

% set line not in service
new_mpc.branch(cutl,11) = 0;
Outlines(cutl) = 0;

if isfield(new_mpc, 'branch_shunts');
    for i = 1 : length(cutl)
        inbf = find(new_mpc.bus(:,1)==new_mpc.branch(cutl(i),1));
        new_mpc.bus(inbf,5) = new_mpc.bus(inbf,5) - ...
            new_mpc.branch_shunts.F_GS(cutl(i));
        
        inbt = find(new_mpc.bus(:,1)==new_mpc.branch(cutl(i),2));
        new_mpc.bus(inbt,5) = new_mpc.bus(inbt,5) - ...
            new_mpc.branch_shunts.T_GS(cutl(i));
    end
end
return;

