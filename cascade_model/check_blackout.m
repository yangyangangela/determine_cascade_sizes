function blck_info = check_blackout(results,inovl,trig_origin,Outlines,Proc,Proc_time,rrmpc)
% Prepare the black out information to be outprint
% Input:
% results: matpower pf(opf) results
% inovl: initial overload lines index
% trig_origin: the trigger line index
% Outlines: binary vector
% Proc: sparse vector containing the index of burned line in sequence

% Output:
% A structure contains all the info


% some index
PMAX = 9;
PF = 14;
RATE_A = 6;

%%

% power request = inital non-isolated power
blck_info.load_rq.TOTAL = abs(sum(rrmpc.bus(rrmpc.bus(:,2)~=4,3)));% total power request

% number of lineoutages;
blck_info.lineout.TOTAL = length(find(Outlines==0));


%%
% loadlevel before cascade
on = find(rrmpc.branch(:,11));
H = abs(rrmpc.branch(on,PF)./rrmpc.branch(on,RATE_A));
T = [0.5:0.1:1];

% fraction of lines with high stress
for i = 1 : length(T);
    blck_info.loadlevel.hcaprate(i) = length(find(H>T(i)));
end

blck_info.loadlevel.stress=sum(abs(rrmpc.branch(on,PF)));

% calculate the power delievered on slack bus initially
oslack = 0;
oref = rrmpc.bus(rrmpc.bus(:,2) == 3,1);
for k = 1 : length(oref)
    temp = find(rrmpc.gen(:,1)==oref(k));
    ind = find( rrmpc.gen(temp,PMAX) == max(rrmpc.gen(temp,PMAX)));
    oslack = oslack + rrmpc.gen(temp(ind(1)),2);
end

% calculate the power delieverd on slack buses after cascade
nslack = 0;
nref = rrmpc.bus(results.bus(:,2) == 3,1);
for k = 1:length(nref)
    temp = find(results.gen(:,1) == nref(k));
    if ~isempty(temp)
        ind = find( results.gen(temp,PMAX) == max(results.gen(temp,PMAX)));
        nslack = nslack + results.gen(ind(1),2);
    end
end
dslack = nslack - oslack;

% total load shed (in MW)
blck_info.dslack.TOTAL = dslack;
blck_info.load_dl.TOTAL = sum(results.bus(results.bus(:,2)~=4,3));
blck_info.loadshed.TOTAL = 1 - blck_info.load_dl.TOTAL/blck_info.load_rq.TOTAL;

% initial triggering status
if nargin > 1
    blck_info.origin = trig_origin;% lineoutage origin
    blck_info.inovl= length(inovl); %initial lineoutage under power grid parameter setting
end

%% Record the cascade process

% record the process
Proc(Proc==0) = [];
blck_info.process = Proc;
blck_info.proctime = Proc_time(1:length(Proc));
