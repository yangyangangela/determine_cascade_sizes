—————————————————————————————————————————————————————————————————
 co_susceptible_groups: identification of co-susceptibile groups
—————————————————————————————————————————————————————————————————

by Yang Yang
2016-12-20


Folders
———————

data: contains a sample correlation matrix in the file texas_11sum_onpeak.mat (Texas grid under the 2011 summer on-peak condition).

src: contains maximalCliques.m, a Matlab function to find maximal cliques using the Bron-Kerbosch algorithm, which is required by detect_co_sus_group.m.


How to use
——————————

detect_co_sus_group.m: This file defines a function that takes a correlation matrix as input and outputs the identified groups of co-susceptible components.

  Usage: [CoGroup, G0] = detect_co_sus_group(C, den_thresh, corr_thresh)

  Input:
    C: correlation matrix
    den_thresh: density threshold used when agglomerating cliques
    corr_thresh: correlation threshold, above which the correlation between
        two components corresponds to a link in the auxiliary graph G_0

  Output:
    CoGroup: matrix defining the co-susceptible groups; CoGroup(i,j) = 1 if
        component j belongs group i.  Note that the function does not check
        if the group sizes are >= 3.
    G0: auxillary graph G_0; G(i,j) = 1 if C(i,j)> corr_thresh


display_results.m: The function in this file takes the output from detect_co_sus_group and prints out the group on the command line as well as visualize the correlation matrix C after re-indexing based on the identified groups.

  Usage: display_results(CoGroup, C)


demo.m: This script computes the co-susceptible groups for the sample data in ./data and displays the result using the functions above with den_thresh = 0.8 and corr_thresh = 0.4 (the values used in the paper).
