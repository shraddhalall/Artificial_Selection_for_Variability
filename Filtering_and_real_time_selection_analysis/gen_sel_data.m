% This script calls functions that analyze turn bias data from a set of
% MARGO expmt files. This script is used every generation to pick families.

% CAT: During Selection, WITHIN EACH BLOCK

analyze_multiFile(Handedness=true); %Select raw expmt folders for VSx and VCx trays run for this block x
std_fam_sel = analyze_fam_std(); % pick only VSx experiments 
std_sorted_sel = sortrows(std_fam_sel,2); %Sorted table of VSx families by TB for using in selection
std_fam_con = analyze_fam_std(); % pick only VCx experiments
std_sorted_con = sortrows(std_fam_con,3); %Sorted table of VCx by family size to avoid picking random families which are too small
std_sorted_con_check = sortrows(std_fam_con,2); %Sorted table of VCx families by TB for curiosity/ quick comparing with VSx

save("analysis_vscxgenn.mat") %save all the tables for selected and control family-wise variability for use in later analysis