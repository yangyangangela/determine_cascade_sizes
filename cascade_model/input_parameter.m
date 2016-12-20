%
% INPUT PARAMETERS
%

%%
% number of lines to be removed in order to trigger cascades
global ntrig; 
ntrig = 3;

% total number of tests
nt = 3;

% power demand ratio for adjusting power total power demand
%  dr = (new total power demand) / (original total power demand)
dr = 1;% default = 1

% squeeze the transmission capacity by multiplying a constant
sqr = 1;% default = 1

% the cut-off probability when one line is overheated
% p = 1;% default = 1 (do not use p in the current version)

% when line flow reach the (1-alpha)*Pmax, consider to be overheated.
% must be zero in this model
alpha = 0;% default = 0


%% Advanced setting: triggering strategy 

% Trigger Strategy
global TStrategy; 
TStrategy = 0; % randomly select from all lines. 
%TStrategy = 1; % select triggers from a specific group (community)


% index of triggering community
global tnc; tnc = 0;% default: tnc=0, random select triggers from all lines.

if TStrategy == 0
    tnc = 0;
end
