function [new_mpc,trig_origin, nOutlines] = trig_line(old_mpc,Outlines,ntrig,Tinner_branch,branch_comm,TStrategy,tnc)
% trigger cascade by removing lines within Tinner_branch
% Input:
%   old_mpc: mpc before initial triggering
%   Outlines: a binary vector indicating the on/off status before triggering
%   ntrig: number of triggers
%   Tinner_branch: the set of lines to choose triggers
%   branch_comm: index of community for each line
%   TStrategy: strategy of selecting triggers
%   tnc:
% Output:
%   new_mpc: mpc after remove triggers
%   trig_origin: the index of lines that have been chosen as triggers
%   nOutlines: total number of lines not-in-service after the triggers
%   (i.e. triggers + lines that are not in service intially)



switch TStrategy
    
    % select triggers randomly from all lines in the network.
    case 0
        on = find(old_mpc.branch(:,11));
        T = Tinner_branch(ismember(Tinner_branch,on));
        indx = randperm(length(T));
        trig_origin = T(indx(1:ntrig));
       
    % select triggers randomly from given community.   
    case 1 
        % branch index within selected community
        Findx = Tinner_branch(branch_comm==tnc); 
        
        % if the community is too small, cut off one less line
        if length(Findx) < 1000
            ntrig = ntrig - 1;
        end
        
        T = Findx(old_mpc.branch(Findx,11)>0);        
        indx = randperm(length(T));
        trig_origin = T(indx(1:ntrig));
        
end

[new_mpc nOutlines] = cutoff_line(old_mpc, trig_origin,Outlines);


return;
