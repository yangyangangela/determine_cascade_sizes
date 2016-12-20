function [pathname, rmpc] = load_data()
% load the power flow data
% return:
%   pathname: path to be used when result is saved
%   rmpc: matpower format power flow data

% by Yang Yang
% 2016-12-18

% Indicate the name of Matpower case file here. The file should be located
% under 'src/matpower4.1/'.

pathname = 'case3375wp';
rmpc = loadcase(pathname);


% A .mat file containing the Matpower mpc struct can also be used as the
% data file. The following will load such an example file from the data
% directory.

% basefolder = './data';
% pathname = 'case3375wp';
% file = strcat(basefolder,'/',pathname,'.mat');
% load(file,'mpc')
% rmpc = mpc;

return;
