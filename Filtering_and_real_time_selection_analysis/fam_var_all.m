function [famvar_all] = fam_var_all(varargin)

%CAT: During selection ACROSS BLOCKS

% This script reprocesses the tables with family-wise TB var scores from the user-selected set
% of files and generates one .mat file with scores for VSx and one for VCx
% for use in analyze_pop_sd.m and plotting

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
famvar_all = table();

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

    pop_number = extractBetween(fPaths{i},"vsc","gen");
    con_name = append('VC',pop_number{1});
    sel_name = append('VS',pop_number{1});

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

    pad_con = tot_size-length(con_fam_var);
    pad_sel = tot_size-length(sel_fam_var);

    con_fam_var = padarray(con_fam_var,pad_con,'post');
    sel_fam_var = padarray(sel_fam_var,pad_sel,'post');

    famvar_all.(con_name)=con_fam_var;
    famvar_all.(sel_name)=sel_fam_var;

    clearvars -except varargin fPaths dir_idx fDir hwb famvar_all tot_size
end

clearvars -except famvar_all