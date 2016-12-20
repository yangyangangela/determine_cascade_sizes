% config.m
% claim all the variables 

% clear all;%clc;
clear
clc

tic;

%%
%
% DEFINE GLOBAL VARIABLES
%

% some scalars
global p;           %scalar: probability to cut off the overheated line
global tnc;         %scalar: community index where to trigger cascades, only used in very large network such as Eastern Interconnection.


% some ratios
global dr;       % scalar: the ratio of demand
global sqr;          % scalar: the squeeze line capcity ratio
%global netflow_rt; %scalar: tune the netflow between communities

% the data structure
global rmpc;        %struct: matpower data structure


% the branch data
global Tinner_branch; %a list contains the inner_branch in each community here
global branch_comm; %branch community list(same size as Tinner_branch)


% temporary data structure
global Outlines; % a nb-by-1 vector

% cascade results - to be saved
global CasRes;      %struct: record final results

% general info - to be saved
global GenInfo;


