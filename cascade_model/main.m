%% Main file for running physical cascade model
%
% This file is to run cascade model described in the paper
% "Vulnerability and co-susceptibility determine cascades sizes" by Yang
% Yang, Takashi Nishikawa, and Adilson Motter.
%
% The model takes in the matpower power flow data format and outputs
% cascade results (automatically saved in the directory ./results),
% including the line failure time stamps, sequences of failures, and the
% final power flow status.
%
% The demand level, line capacity, and the way to select initial triggers
% can be modified by editing input_parameter.m file. 
% 
% An example data can be found in directory ./data and the example output can
% be found in the directory ./results.
%
% by Yang Yang
% 2016-12-18

%%
orig_path = path;
save original_path.mat orig_path
warning off
addpath(genpath('./src'));
addpath('./data')
warning on

%% Claim all the variables, set up model parameters, and load network data.

% Define global variables
run('config');


% Set-up model parameter
run('input_parameter');

% Read network data, remove bugs in the data.
[pathname, rmpc] = load_data();
rmpc = check_data(rmpc);


%% Advanced setting.

% In prepare_branch_data.m, one can indicate the set of transmission lines
% that can be removed as a trigger to cascade (by default,
% Tinner_branch=1:nl, where nl is the number of lines in the network. 
% One can also group all transmission lines using branch_comm and indicate 
% which group the initial triggers are selected. This can be done by modified 
% Tstrategy and tnc in the input_parameter.m file.

[Tinner_branch, branch_comm] = prepare_branch_data(rmpc);


%% Initiate the data structure to save cascade results.

init_data(nt,rmpc);


%% Recursive cascade model.

% display results?
DON = 1; DOFF = 0;

% run the cascade model nt times.
for tt = 1 : nt
    disp(strcat('=== test #',num2str(tt),' ==='));
    [results, inovl, inOl, inld, trig_origin,Outlines,Proc,Proc_time,rrmpc]...
        = Cascade(sqr, dr, DOFF,rmpc,ntrig,Tinner_branch,branch_comm,TStrategy,tnc);
    blck_info = ...
        check_blackout(results,inovl,trig_origin,Outlines,Proc,Proc_time,rrmpc);
    CasRes(tt) = record_cascade_res(blck_info,DON);
end


%% save the results

% clearvars Outlines Proc Proc_time DOFF DON inOl inld inovl nl presults rrmpc trig_origin tt blck_info;
foldername = strcat('./results/', pathname);
if ~exist(foldername,'dir');mkdir(foldername);end

%indx = find(ismember(pathname,'/'),1,'last');
dt = datestr(now,'mmdd_HHMM');
filename = strcat(pathname(1:end),'_ntrg',num2str(ntrig),'_dr',num2str(dr),'_',dt,'.mat');
fullFileName = fullfile(foldername, filename);

% clearvars filename foldername indx pathname dt;
OtherInfo.nt = nt;
OtherInfo.ntrig = ntrig;
OtherInfo.sqr = sqr;
OtherInfo.dr = dr;
OtherInfo.tnc = tnc;
OtherInfo.TStrategy = TStrategy;
OtherInfo.Tinner_branch = Tinner_branch;
GenInfo.init_mpc = rmpc;
save(fullFileName, 'CasRes', 'GenInfo', 'OtherInfo');

load original_path.mat orig_path
warning off
path(orig_path)
warning on

toc;
