function rmpc = check_data(rmpc)
% check_data(): remove the bugs from data
%
% Copyright: Yang Yang, 2013, Northwestern University

%% Disconnect the no-output generators
% if there are generators whose Pmax=0, set the generator to be not-in-service
l = find(rmpc.gen(:,9)==0);

if ~isempty(l);
    rmpc.gen(l,8) = 0; % set not-in-service;
end

% disconnect the generators whose Pmax =9999
rmpc.gen(rmpc.gen(:,9)>9990,8) = 0; % set to be not-in-service


%% Add the gencost field to the data

if ~isfield(rmpc,'gencost');
    ng = size(rmpc.gen,1);
    rmpc.gencost = sparse(ng,7);
end

% set power generation cost as zero
rmpc.gencost(:,4)=2;
rmpc.gencost(:,5:7)=0;
rmpc.gencost(:,7)=[];

% set the model to be polynomial
rmpc.gencost(:,1) = 2;


%% Fix the generator whose output is larger than limit, i.e. Pmax < PG
ind = find(rmpc.gen(:,2) > rmpc.gen(:,9));
rmpc.gen(ind,9) = rmpc.gen(ind,2)*1.1;%adjust the capacity


%% Revert the negative power demand buses

bus_list = rmpc.bus(:,1);
gbus = bus_list(rmpc.bus(:,3)<0);
NewG = zeros(length(gbus),size(rmpc.gen,2));
NewGcost = zeros(length(gbus),size(rmpc.gencost,2));

% change the demand to generator
for i = 1 : length(gbus)
    u = find(bus_list==gbus(i));
    
    % real power demand
    PD = rmpc.bus(u,3);
    QD = rmpc.bus(u,4);
    
    if rmpc.bus(u,2)~=3
        rmpc.bus(u,2) = 2;% change bustype to PV
    end
    rmpc.bus(u,3) = 0;% PD = 0
    rmpc.bus(u,4) = 0;% QD = 0
    
    % add a new bus row in rmpc.gen
    gen = zeros(1,size(rmpc.gen,2));
    gen(1) = gbus(i);             % bus number
    gen(2) = -1 * PD;          % real power output (MW)
    gen(3) = -1 * QD;          % reactive power output(MVAr)
    gen(4) = abs(gen(3));          % maximum reactive power output(MVAr)
    gen(5) = -1*abs(gen(3));          % minimum reactive power output(MVAr)
    gen(6) = 1;             % voltage magnitude setpoint(p.u)
    gen(7) = rmpc.baseMVA;   % total MVA base of machind, defaults to baseMVA
    gen(8) = 1;             % machine status: 1=connected
    gen(9) = abs(PD)*1.1;             % maxiumum real power (MVA)
    gen(10) = 0;         % minimum real power output(MW)
    gen(11:end) = 0;
    
    NewG(i,:) = gen;
    
    % add new generation cost function (This data will only be used if
    % optimal power flow calculation is to be run.
    genc = zeros(1,size(rmpc.gencost,2));
    genc(1) = 2;        %cost model 1=piecewise 2=polynomial
    genc(2) = 0;        %startupcost in USdollar
    genc(3) = 0;        %shutdown cost in USdollar
    genc(4) = 2;        %number of const equation
    genc(5) = 0;   % set the power generation cost as zero
    genc(6) = 0;
    NewGcost(i,:) = genc;
    
end

rmpc.gen = [rmpc.gen; NewG];
rmpc.gencost = [rmpc.gencost; NewGcost];

%% Remove the lines that are not in service
rmpc.branch(rmpc.branch(:,11)==0,:) = [];


%% Get a reasonable initial power flow solution
% run dc power flow

mpopt = mpoption('OUT_ALL',0);
rmpc = rundcpf(rmpc,mpopt);

% check the slack bus dmd>gen or dmd<gen?
% redistribute the power on slack bus by decreasing or increasing stress
DECREASE_STRESS = 1; % lower generation
INCREASE_STRESS = 2; % increase dmd
rmpc = distri_slack(rmpc,DECREASE_STRESS);
rmpc = rundcpf(rmpc,mpopt);

% print the initial power flow information
disp('initial power dmd');
disp(num2str(sum(rmpc.bus(:,3))));
disp('initial power gen');
disp(num2str(sum(rmpc.gen(:,2))));
disp('check power balacne: gen-dmd-Gshunt=');
disp(num2str(sum(rmpc.gen(:,2))-sum(rmpc.bus(:,3))-sum(rmpc.bus(:,5))));


return;