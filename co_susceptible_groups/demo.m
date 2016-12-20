% demo
orig_path = path;
save original_path.mat orig_path
addpath('./src');
addpath('./data');

% load the correlation matrix
load('texas_11sum_onpeak.mat','C');

% set the density threshold
den_thresh = 0.8;

% set the correlation threshold
corr_thresh = 0.4;

% detect co-susceptable groups
[CoGroup, G0] = detect_co_sus_group(C, den_thresh, corr_thresh);

% display results
display_results(CoGroup, C)

load original_path.mat orig_path
warning off
path(orig_path)
warning on
