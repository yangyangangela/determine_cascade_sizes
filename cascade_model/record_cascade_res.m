function CasRes = record_cascade_res(blck_info,dispon)
% CasRes: a vector of struct variables of length nt, each corresponding to
% a single cascade realization and with the following fields:
% 
%   power_rq: struct with field TOTAL (initial power demand, in MW)
% 
%   power_del: struct with field TOTAL (total power delivered at the end of
%   the cascade, in MW)
% 
%   power_shed: struct with field TOTAL (total power shed at the end of the
%   cascade, in MW)
% 
%   slackchange: struct with field TOTAL (changes in the total power output
%   of the slack busses)
% 
%   origin: ntrigger-by-1 vector, the indices of the initial triggers
%   (i.e., the initial line failures)
% 
%   line_out: scalar, number of line outages at the end of the cascade
%   (including the initial failures)
% 
%   process: ordered sequence of the indices of line outages in the cascade
% 
%   proctime: the time separation between two consecutive failures, it has
%   the same length as process and the first

CasRes = struct('power_rq',[],'power_del',[],'power_shed',[],...
    'slackchange',[],'origin',[],'line_out',[],...
    'process',[],'proctime',[]);

CasRes.power_rq = blck_info.load_rq;% power request
CasRes.power_del = blck_info.load_dl;%power delivered 
CasRes.power_shed = blck_info.loadshed;% power shed percentage 
CasRes.slackchange = blck_info.dslack;% change of power on slack buses
CasRes.line_out = blck_info.lineout;% total line out number.
CasRes.process = blck_info.process;% line outages sequence
CasRes.proctime = blck_info.proctime;% burning time

CasRes.origin = blck_info.origin; % lineout origin


% display the results

if dispon == 1;
    
    disp('Blackout origin (initial line failures):');
    disp(num2str(blck_info.origin));
    
    disp('Total load request this time: ');
    disp(num2str(blck_info.load_rq));
    
    disp('Total load delivered this time: ');
    disp(num2str(blck_info.load_dl));
    
    disp('Total load shed percentage this time:');
    disp(num2str(blck_info.loadshed));

    disp('Total line outage number (including the initial failures): ');
    disp(num2str(blck_info.lineout));

end

return
