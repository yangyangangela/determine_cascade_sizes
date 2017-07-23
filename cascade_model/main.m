%% Main file for running physical cascade model
%
% This file is to run cascade model described in the paper
% 
% Yang Yang, Takashi Nishikawa, and Adilson Motter
% Vulnerability and Cosusceptibility Determine the Size of Network Cascades
% Phys. Rev. Lett. 118, 048301 (2017)
% http://journals.aps.org/prl/abstract/10.1103/PhysRevLett.118.048301
%
% The model takes the matpower power flow data as input format and outputs
% cascade results (automatically saved in the directory ./results),
% including the line failure time stamps, sequences of failures, and the
% final power flow status.
%
% The demand level, line capacity, and the way initial triggers are chosen
% can all be modified by editing input_parameter.m file. 
% 
% An example data can be found in directory ./data and the example output can
% be found in the directory ./results.
%
% by Yang Yang
% 2017-01-27

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
% Tinner_branch=1:nl, where nl is the number of lines in the network,
% meaning that triggers are chosen from the set of all lines in the
% network). One can also group the transmission lines using branch_comm and
% indicate which group the initial triggers are selected. This can be done
% by modifying Tstrategy and tnc in the input_parameter.m file.

[Tinner_branch, branch_comm] = prepare_branch_data(rmpc);


%% Initiate the data structure to save cascade results.

init_data(nt,rmpc);


%% Recursive cascade model.

% display results?
DON = 1; DOFF = 0;

% run the cascade model nt times.
for tt = 1 : nt
    disp(strcat('=== test #',num2str(tt),' ==='));
    [results, inovl, inOl, inld, trig_origin,Outlines,Proc,Proc_time,rrmpc, tracing_res]...
        = Cascade(sqr, dr, DOFF,rmpc,ntrig,Tinner_branch,branch_comm,TStrategy,tnc);
    blck_info = ...
        check_blackout(results,inovl,trig_origin,Outlines,Proc,Proc_time,rrmpc);
    CasRes(tt) = record_cascade_res(blck_info,DON);
    TracRes(tt) = tracing_res;
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
OtherInfo.nt = nt; % total number of cascade events
OtherInfo.ntrig = ntrig;% number of lines selected as trigger in a single event.
OtherInfo.sqr = sqr; % squeezing ratio to adjust the capacity of lines. sqr=1 means that all lines have the original capacity.
OtherInfo.dr = dr;% demand ratio. dr=1 means that demand is kept equal to the original demand.
OtherInfo.tnc = tnc;% the group of lines where trigger are selected. For advance setting, the tnc should be changed along with TStrategy in prepare_branch_data.m.
OtherInfo.TStrategy = TStrategy;
OtherInfo.Tinner_branch = Tinner_branch;% Advance setting with tnc and TStrategy. See prepare_branch_data.m
GenInfo.init_mpc = rmpc;% the intial matpower structure for the grid.
save(fullFileName, 'CasRes', 'GenInfo', 'OtherInfo', 'TracRes');

load original_path.mat orig_path
warning off
path(orig_path)
warning on


toc;
