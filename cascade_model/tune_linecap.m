function new_mpc = tune_linecap(old_mpc,branch_indx,ratio)
% multiply the rating of the line by ratio
% input:
% old_branch: branch data in mpc format
% branch_indx: vector, branch index that need to be tuned 
% ratio: scalar, change the capacity 
% output:
% new_branch: branch dat in mpc format

% change the line rating
new_mpc = old_mpc;
new_mpc.branch(branch_indx,6:8) = old_mpc.branch(branch_indx,6:8)*ratio;

if ratio <1e-4;
   new_mpc = cutoff_line(bew_mpc,branch_indx);
end % remove the branch
return;