function display_geninfo(sqr,dr,inOl,inld,ovl,tload_dl)
% display the general information before the each cascade run
% Input:
%   sqr: squeeze network ratio
%   ir: interdependency ratio
%   dr: demand ratio
%   inOl: vector nl-by-1, initial not-in-service line=0
%   inld: scalar, initial load demand
%   ovl: overload line 
%   tload_dl: total load delivered initially.

global GenInfo; % struct: general informationd

disp('***************************');
disp('    NEW TEST    ');
disp('    GENERAL INFO:     ');
disp('---------------------------');
disp('Transmission line squeeze ratio: ');
disp(num2str(sqr));
disp('Load demand increase ratio: ');
disp(num2str(dr));
disp('Total load request after changes:');
disp(num2str(inld));
disp('Total load delivered:');
disp(num2str(tload_dl));
disp('Initial out of service line number:');
disp(num2str(length(find(inOl==0))));
disp('Initial overload line number:');
disp(num2str(length(ovl)));
disp(' ');disp(' ');

return;