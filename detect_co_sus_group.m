function [CoGroup G0] = detect_co_sus_group(C, den_thresh, corr_thresh)
% Input:
%   C: correlation matrix
%   den_thresh: density threshold used when agglomerating cliques
%   corr_thresh: correlation threshold, above which the correlation between
%       two components corresponds to a link in the auxiliary graph G_0.
%
% Output:
%   CoGroup: matrix defining the co-susceptible groups; CoGroup(i,j) = 1 if
%       component j belongs group i. Note that the function does not check
%       if the group sizes are >= 3.
%   G0: auxillary graph G_0; G(i,j) = 1 if C(i,j)> corr_thresh


% Auxillary graph, diagonal elements=0.
G0 = zeros(size(C));
G0(C>corr_thresh) = 1;
N = size(C,2); G0(find(eye(N))) = 0;


% maximal clique detection.
[ MC ] = maximalCliques( G0 );


% re-index cliques
[v, ind] = sort(sum(MC,1),'descend');
MC = MC(:,ind);
ncl = size(MC,2);


% maximal clique decomposition  
cMC = MC; H = sum(cMC,1);
c = 1;
while max(H) > 0 %recursively detect and remove 
    cMC(:,c+1:end) = ~cMC(:,c)*ones(1,ncl-c) & cMC(:,c+1:end);
    [v, ind] = sort(sum(cMC,1),'descend');
    cMC = cMC(:,ind);
    H = sum(cMC(:,c+1:end));
    c = c + 1;
end
cMC(:,c:end) = [];% cliques without overlapping
ncl = size(cMC,2);


% clique agglomeration
group_num = 1 : ncl;

for i = 2 : ncl
    
    for j = 1 : i - 1
        
        ind1 = find(cMC(:,i));l1 = length(ind1);% index in current group
        
        if length(find(group_num==j)) > 1
            ind2 = find(sum(cMC(:,group_num==j),2));l2 = length(ind2);
        else
            ind2 = find(cMC(:,group_num==j));l2 = length(ind2);
        end
        
        if length(find(G0(ind1,ind2)))/(l1*l2) > den_thresh
            group_num(i) = group_num(j);
        end
    end
end


% record the co-susceptible groups
CoGroup = zeros(length(unique(group_num)),N);
c = 1;
for i = unique(group_num)
    for j = find(group_num==i)
        CoGroup(c,:) = CoGroup(c,:) + cMC(:,j)';
    end
    c = c + 1;
end








