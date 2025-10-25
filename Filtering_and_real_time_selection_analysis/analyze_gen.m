function analyze_gen(gen_no)

%CAT: During selection ACROSS BLOCKS

%This script creates generation wise, family-wise data used for analysis
%and visualizaiton during selection

% 'Initial analysis files' refers to VSx and VCx block-wise
% tables with family-wise TB var scores saved as 'analysis_vscxgenn.mat' in 'gen_sel_data.m'

disp(['Pick folder containing initial analysis files for all blocks for ' num2str(gen_no)])

var_fam = fam_var_all('Keyword','analysis');

VC1 = table2array(var_fam(:,'VC1'));
VS1 = table2array(var_fam(:,'VS1'));
VC2 = table2array(var_fam(:,'VC2'));
VS2 = table2array(var_fam(:,'VS2'));
VC3 = table2array(var_fam(:,'VC3'));
VS3 = table2array(var_fam(:,'VS3'));

gen = string(gen_no);
fname = append ('results/fam_var/',gen);
fname = append (fname,'.mat');

save(fname,'VC1','VS1','VC2','VS2','VC3','VS3');

clearvars -except gen;

%VS1
disp(['Pick MARGO data for VS1 ' gen]) %pick folder containing margo expmt raw data folders
expmt = extract_data_tb();
fname = append('results/tb_all/',gen);
fname = append(fname,'/VS1.mat');
save(fname,"expmt");

clearvars -except gen;

%VC1
disp(['Pick MARGO data for VC1 ' gen])
expmt = extract_data_tb();
fname = append('results/tb_all/',gen);
fname = append(fname,'/VC1.mat');
save(fname,"expmt");

clearvars -except gen;

%VS2 
disp(['Pick MARGO data for VS2 ' gen])
expmt = extract_data_tb();
fname = append('results/tb_all/',gen);
fname = append(fname,'/VS2.mat');
save(fname,"expmt");

clearvars -except gen;

%VC2 
disp(['Pick MARGO data for VC2 ' gen])
expmt = extract_data_tb();
fname = append('results/tb_all/',gen);
fname = append(fname,'/VC2.mat');
save(fname,"expmt");

clearvars -except gen;

%VS3 
disp(['Pick MARGO data for VS3' gen])
expmt = extract_data_tb();
fname = append('results/tb_all/',gen);
fname = append(fname,'/VS3.mat');
save(fname,"expmt");

clearvars -except gen;

%VC3 
disp(['Pick MARGO data for VC3' gen])
expmt = extract_data_tb();
fname = append('results/tb_all/',gen);
fname = append(fname,'/VC3.mat');
save(fname,"expmt");

clearvars -except gen;

%------%

disp(['Pick tb_all data for' gen]) %Pick folder containing tb_all data generated above for all populations in this generation

var_pop = analyze_pop_sd(gen);
fname = append ('results/pop_var/',gen);

fname_csv = append (fname,'.csv');
fname = append (fname,'.mat');

save(fname,"var_pop");

writetable(var_pop,fname_csv);
clearvars -except gen;
