function fam_var_herit(varargin)

%CAT: Heritability analysis data extract step 1

% This script reprocesses the block-wise analysis tables generated every generation in
% gen_sel_data.m and generates a single table per population containing
% family wise variability scores for all 21 generations of selection

keyarg = {};
for i=1:length(varargin)
    arg = varargin{i};
    if ischar(arg)
        switch arg
            case 'Keyword'
                keyidx = i;
                i=i+1;
                keyarg = {'keyword';varargin{i}};
        end
    end
end

if exist('keyidx','var')
    varargin(keyidx:keyidx+1)=[];
end
%define table size
tot_size = 36;

%define table to fill data over files
convar_all = table();
selvar_all = table();

% Get paths to data files
fDir = autoDir;

fPaths = recursiveSearch(fDir{1},'ext','.mat',keyarg{:});
varargin = [varargin,{'Dir'}];
dir_idx = numel(varargin)+1;
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
    varargin(dir_idx)=fDir(i);

    gen_number = extractBetween(fPaths{i},"gen",".mat");
    disp(gen_number)
    con_name = append('var',gen_number{1});
    con_name_fam = append('fam',gen_number{1});

    sel_name = append('var',gen_number{1});
    sel_name_fam = append('fam',gen_number{1});

    for i = [1:length(std_fam_con.counts)]
        n = std_fam_con.counts(i);
        if n{:} <= 18
            std_fam_con.stdtb(i)=nan;
        end
    end

    std_fam_con_parsed = rmmissing(std_fam_con);
    
    for i = [1:length(std_fam_sel.counts)]
        n = std_fam_sel.counts(i);
        if n{:} <= 18
            std_fam_sel.stdtb(i)=nan;
        end
    end

    std_fam_sel_parsed = rmmissing(std_fam_sel);

    con_fam_var = std_fam_con_parsed.stdtb;
    sel_fam_var = std_fam_sel_parsed.stdtb;

    con_fams = std_fam_con_parsed.fams;
    con_fam_nums = cellfun(@get_fam_numbers,con_fams);

    sel_fams = std_fam_sel_parsed.fams;
    sel_fam_nums = cellfun(@get_fam_numbers,sel_fams);

    pad_con = tot_size-length(con_fam_var);
    pad_sel = tot_size-length(sel_fam_var);

    con_fam_var = padarray(con_fam_var,pad_con,'post');
    sel_fam_var = padarray(sel_fam_var,pad_sel,'post');

    con_fam_nums = padarray(con_fam_nums,pad_con,'post');
    sel_fam_nums = padarray(sel_fam_nums,pad_sel,'post');

    convar_all.(con_name_fam) = con_fam_nums;
    convar_all.(con_name)=con_fam_var;
    
    selvar_all.(sel_name_fam) = sel_fam_nums;
    selvar_all.(sel_name)=sel_fam_var;
    
    clearvars -except varargin fPaths dir_idx fDir hwb convar_all selvar_all tot_size
end

writetable(convar_all,'./During_selection/analysis_files/processed/Con_vars_3.csv'); %change name by block
writetable(selvar_all,'./During_selection/analysis_files/processed/Sel_vars_3.csv');

clearvars -except convar_all selvar_all