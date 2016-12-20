function [mpc, Outlines, tload_rq] = setup_case(squeeze_ratio, dmd_ratio, rmpc)
% Input:
% squeeze_ratio: the ratio squeeze the line capacity
% dmd_ratio: the ratio to tune the total load demand.
% rmpc: matpower data
% Output:
% mpc: matpower data with given squeeze_ratio and dmd_ratio
% Outlines: a binary vector indicating the on/off status of transmission
% lines
% tload_rq: total load required in the network

% Yang Yang
% 2016-12-18


%%
% copy the data
mpc = rmpc;

% squeeze the branch capacity by squeeze_ratio
nl =length(mpc.branch);
mpc = tune_linecap(mpc,1:nl,squeeze_ratio);

% set the demand level, default dmd_ratio=1
[mpc.bus, mpc.gen] = scale_load(dmd_ratio, mpc.bus, mpc.gen);

mpc.gen(:,2) = mpc.gen(:,2)*dmd_ratio;
I = find(mpc.gen(:,2)>mpc.gen(:,9));
if ~isempty(I)
    mpc.gen(I,9) = mpc.gen(I,2);
end


% mark the initial outlines and the total numbers
Outlines = ones(1,size(mpc.branch,1));
Outlines(mpc.branch(:,11)==0) = 0;

% total load required
tload_rq = sum(mpc.bus(mpc.bus(:,3)>0,3));


return;