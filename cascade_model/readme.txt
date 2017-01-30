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

5) The results will be automatically saved in a .mat file under in a folder (whose name corresponds that of the network data file and indicates the parameters used) under the folder ./results.  For example, the result file name would be case3375wp_ntrg3_dr1_1219_2319.mat, where case3375wp.mat or case3375wp.m is the data file name, ntrg3 indicates that the total number of initial triggers is 3, dr1 indicates that the demand ratio is the same as the original data, and 1219_2319 is a date/time stamp (MMDD_HHMM). 


Interpreting results
————————————————————

The results file has the following Matlab variables:


CasRes: a vector of struct variables of length nt, with each component corresponding to a single cascade realization and with the following fields:

  power_rq: initial power demand (MW)

  power_del: total power delivered at the end of the cascade (MW)

  power_shed: total power shed at the end of the cascade (MW)

  slackchange: changes in the total power output of the slack busses

  origin: ntrigger-by-1 vector of the indices for the initial triggers (i.e., the initial line failures)

  line_out: number of line outages at the end of the cascade (including the initial failures)

  process: ordered sequence of the indices of line outages in the cascade

  proctime: the time separation between two consecutive failures, it has the same length as process and the first ntrigger numbers are zero.


GenInfo: a struct variable with the following fields providing general information on the power grid system being analyzed:

  ng: number of generators

  nl: number of lines

  nInOutline: number of lines not-in-service before any simulations

  tload_in: total load in the initial steady state (in MW)

  tgencap: total power capacity of all generators (in MW)

  init_mpc: initial matpower struct before fixing bugs (see the comments in the file check_data.m for details)


OtherInfo: a struct variable with the following fields providing other information on the simulation set up: 

  nt: total number of cascade events

  ntrig: number of lines selected as the triggers in a single event

  sqr: squeezing ratio for adjusting the capacity of lines (where sqr=1 means that all lines have the original capacity)

  dr: demand ratio (where dr=1 means to keep demand as the original demand)

  tnc: the group of lines from which the triggers are selected (advanced setting; changing tnc requires changing TStrategy in prepare_branch_data.m)
   
  TStrategy: index indicating the triggering strategy (advanced setting)

  Tinner_branch: advanced setting with tnc and TStrategy (see prepare_branch_data.m)

  init_mpc: the intial matpower structure right before the simulation of cascade starts



(See record_cascade_res.m for more details) 
