function [Tinner_branch, branch_comm] = prepare_branch_data(rmpc)
% Return the 
% Tinner_branch: a vector indicating the branches that can be removed as triggers
% branch_comm: the group index of each branch. It will be used when
% Tstrategy ~=0, i.e. one can select the group of branches as initial
% triggers.

% default set-up
nl = length(rmpc.branch);
Tinner_branch = 1:nl;
branch_comm = ones(1,nl);

return;