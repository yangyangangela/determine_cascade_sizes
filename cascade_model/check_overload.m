function overload_line = check_overload(results,alpha)
% Get the overload_line index
% Input:
% results: structure from OPF results
% alpha: line outage threshold (see setup_parameter)
%
% Output:
% overload_line: vector containing the overloaded line number(not including
% lines that are cut off)

% 2012-08-14: current use Pmax as the judge

BR_STATUS = 11;
% Outlines vector: 1-by-N vector. 1=in service,0=outage

Pmax = results.branch(:,6);%short term rating capacity
PF = abs(results.branch(:,14));%power flow on the line

% lines with flow reaching (1-alpha)*Pmax are overloaded lines
Pd = PF - (1-alpha)*Pmax;
overload_line = find(Pd>0);

% dont't count burned lines twice
overload_line(results.branch(overload_line,BR_STATUS) == 0) = [];

return;
