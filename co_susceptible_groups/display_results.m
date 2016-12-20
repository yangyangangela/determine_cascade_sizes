function display_results(CoGroup, C)
% display the number of size of co-susceptible groups
disp(strcat('Total number of co-susceptible groups:',num2str(size(CoGroup,1))));
disp('The size of groups are:');
disp(num2str(sum(CoGroup,2)'));

% reindex the component by co-susceptible groups
I = zeros(1,size(CoGroup,2));
c = 1;
for i = 1 : size(CoGroup,1)
    I(c:c+nnz(CoGroup(i,:))-1) = find(CoGroup(i,:));
    c = c + nnz(CoGroup(i,:));
end


figure;
colormap('gray');
subplot(1,2,1);
imagesc(C);
title('Correlation matrix before re-index');
subplot(1,2,2);
imagesc(C(I,I));
title('Correlation matrix after re-index');