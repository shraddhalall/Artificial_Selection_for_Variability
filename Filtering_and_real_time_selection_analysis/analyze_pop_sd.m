function [sd_pop] = analyze_pop_sd(gen_no)
%CAT: During selection ACROSS BLOCKS

% This script reprocesses the expmt data structs from a user-selected set
% of files and generates a table of sex-separated population turn biases

%define table to fill data over files
sd_pop = table();

% Get paths to data files
fDir = autoDir;

fPaths = recursiveSearch(fDir{1},'ext','.mat');
%varargin = [varargin,{'Dir'}];
%dir_idx = numel(varargin)+1;
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '/']};
end                    
            

%% reprocess data

if ~iscell(fPaths)
    fPaths = {fPaths};
end

hwb = waitbar(0,'loading files');

for i=1:length(fPaths)

    hwb = waitbar(i/length(fPaths),hwb,['processing file '...
        num2str(i) ' of ' num2str(length(fPaths))]);

    disp(['processing file ' num2str(i) ' of ' num2str(length(fPaths))]);
    load(fPaths{i});
    %varargin(dir_idx)=fDir(i);
    
    %remove rows with NAN

    expmt_nonan = rmmissing(expmt);

    G1 = groupsummary(expmt_nonan,"labels");

    for k = 1:length(G1.GroupCount)
        if G1.GroupCount(k,:) <= 18
            exc_fam =G1.labels(k,:);
            for j = 1:length(exc_fam)
                expmt_nonan(ismember(expmt_nonan.labels,exc_fam{j}),:)=[];
            end
        end
    end

    TB = expmt_nonan.TB;
    Sex = expmt_nonan.Sex;

    %calculate std across all individuals so std of TB
    var_all = std(TB);

    %calculate std of TB if sex is F - var_F
    is_female = cat(1,expmt_nonan.Sex{:}) == 'F';
    var_F = std(expmt_nonan.TB(is_female));

    %calculate std of TB if sex is M - var_M
    is_male = ~is_female;
    var_M = std(expmt_nonan.TB(is_male));

    %generate the name of the dataset from fpaths
    fdeets = split(fPaths(i),"/");
    fname_tot = fdeets(end);
    fname_split = split(fname_tot,'.');
    fname = fname_split(1);
   
    %save to results table as fname, var_all,var_F,var_M
    
    T = table(fname,var_all,var_F,var_M);

    sd_pop = [sd_pop;T];

    clearvars -except fPaths fDir hwb sd_pop S gen_no
end

fpath_famvar= append ('results/fam_var/',gen_no); %Use tables generated in first step of 'analyze_gen.m' and stored as fam_var population wise 

S = load(fpath_famvar);

VC1_avgvar = mean(nonzeros(S.VC1));
VC2_avgvar = mean(nonzeros(S.VC2));
VC3_avgvar = mean(nonzeros(S.VC3));
VS1_avgvar = mean(nonzeros(S.VS1));
VS2_avgvar = mean(nonzeros(S.VS2));
VS3_avgvar = mean(nonzeros(S.VS3));

VC1_sderr = std(S.VC1,'omitnan')/sqrt(nnz(S.VC1));
VC2_sderr = std(S.VC2,'omitnan')/sqrt(nnz(S.VC2));
VC3_sderr = std(S.VC3,'omitnan')/sqrt(nnz(S.VC3));
VS1_sderr = std(S.VS1,'omitnan')/sqrt(nnz(S.VS1));
VS2_sderr = std(S.VS2,'omitnan')/sqrt(nnz(S.VS2));
VS3_sderr = std(S.VS3,'omitnan')/sqrt(nnz(S.VS3));

VC1_sd = std(S.VC1,'omitnan');
VC2_sd = std(S.VC2,'omitnan');
VC3_sd = std(S.VC3,'omitnan');
VS1_sd = std(S.VS1,'omitnan');
VS2_sd = std(S.VS2,'omitnan');
VS3_sd = std(S.VS3,'omitnan');

Cov_1 = cov(S.VS1,S.VC1);
Cov_2 = cov(S.VS2,S.VC2);
Cov_3 = cov(S.VS3,S.VC3);

VC1_fam_no = nnz(S.VC1);
VC2_fam_no = nnz(S.VC2);
VC3_fam_no = nnz(S.VC3);
VS1_fam_no = nnz(S.VS1);
VS2_fam_no = nnz(S.VS2);
VS3_fam_no = nnz(S.VS3);

AvgVars = [VC1_avgvar,VC2_avgvar,VC3_avgvar,VS1_avgvar,VS2_avgvar, VS3_avgvar];

AvgVars_T = transpose(AvgVars);

Errs = [VC1_sderr,VC2_sderr,VC3_sderr,VS1_sderr,VS2_sderr, VS3_sderr];

Errs_T = transpose(Errs);

SDs = [VC1_sd,VC2_sd,VC3_sd,VS1_sd,VS2_sd, VS3_sd];

SDs_T = transpose(SDs);

Covs = [Cov_1(1,1),Cov_2(1,1),Cov_3(1,1),0,0,0];

Covs_T = transpose(Covs);

num_fams = [VC1_fam_no,VC2_fam_no,VC3_fam_no,VS1_fam_no,VS2_fam_no, VS3_fam_no];

num_fams_T = transpose(num_fams);

sd_pop.avg_pop_var = AvgVars_T;
sd_pop.err_avg = Errs_T;
sd_pop.sd = SDs_T;
sd_pop.covs = Covs_T;
sd_pop.counts_fams = num_fams_T;

delete(hwb);