—————————————————————————————————————————————————————
 cascade_model: Simulation of physical cascade model
—————————————————————————————————————————————————————

by Yang Yang
2016-12-20


Folders
———————

data: contains a sample data file case3375wp.mat

results: contains a sample results file in the subfolder case3375wp

src: has subfolders matlab_bgl and matpower4.1, containing Matlab toolboxes (Matlab BGL and Matpower, respectively) that are required to run main.m


How to use
——————————

1) In the function file load_data.m, indicate the name of the network data file (variable: pathname).  The data file should be in the Matpower format and be located in an appropriate folder (see load_data.m for details). Default: uses the Matpower case file, case3375wp.m in ./src/matpower4.1

2) Edit the function file input_parameter.m to set the number of realizations (tests) of cascade simulation (variable: nt). 

3) (Advanced optional setting) Modify the stress level (power demand ratio, dr), the line capacity factor (sqr).  Default values: dr = sqr = 1.

4) Run main.m. (Warning: This will clear all the global variables and the command window.) 

5) The results will be automatically saved in a .mat file under in a folder (whose name matches that of the network data file) under the folder ./results.  For example, the result file name would be case3375wp_ntrg3_dr1_1219_2319.mat, where case3375wp.mat or case3375wp.m is the data file name, ntrg3 indicates that the total number of initial triggers is 3, dr1 indicates that the demand ratio is the same as the original data, and 1219_2319 is a date/time stamp (MMDD_HHMM). 


Interpreting results
————————————————————

The results file has the following Matlab variables:

nt: the number of cascade realizations simulated

CasRes: a vector of struct variables of length nt, each corresponding to a single cascade realization and with the following fields:

  power_rq: struct with field TOTAL (initial power demand, in MW)

  power_del: struct with field TOTAL (total power delivered at the end of the cascade, in MW)

  power_shed: struct with field TOTAL (total power shed at the end of the cascade, in MW)

  slackchange: struct with field TOTAL (changes in the total power output of the slack busses)

  origin: ntrigger-by-1 vector, the indices of the initial triggers (i.e., the initial line failures)

  line_out: scalar, number of line outages at the end of the cascade (including the initial failures)

  process: ordered sequence of the indices of line outages in the cascade

  proctime: the time separation between two consecutive failures, it has the same length as process and the first ntrigger numbers are zero.

(See record_cascade_res.m for more details) 