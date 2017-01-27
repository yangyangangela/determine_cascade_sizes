function init_data(nt,rmpc)
% Input:
% rmpc: the matpower struture
% nt: number of tests
% Complete the following tasks
% 1) calculate some basic properties
% 2) initialize the data structure to save data

global CasRes;% struct used to store cascade result
global GenInfo; % struct: store the general information about the data before doing any interdependency manipulation

%% Calculate basic properties

ng = size(rmpc.gen,1);%number of generators
nl = size(rmpc.branch,1);%number of lines
nInOutline = length(find(rmpc.branch(:,11)==0));%intial not in-service line

GenInfo.ng = ng;
GenInfo.nl = nl;
GenInfo.nInOutline = nInOutline;

% calculate the total load before making any changes
GenInfo.tload_in = sum(rmpc.bus(rmpc.bus(:,3)>0,3));

% calculate total generation capacity
GenInfo.tgencap = sum(rmpc.gen(:,9));


%% initialize data structure to save results

CasRes = struct('power_rq',[],'power_del',[],'power_shed',[],...
    'slackchange',[],'origin',[],'line_out',[],...
    'process',[],'proctime',[]);

CasRes(nt) = struct('power_rq',[],'power_del',[],'power_shed',[],...
    'slackchange',[],'origin',[],'line_out',[],...
    'process',[],'proctime',[]);



