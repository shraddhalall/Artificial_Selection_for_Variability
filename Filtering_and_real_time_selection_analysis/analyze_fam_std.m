function [std_all] = analyze_fam_std(varargin)

%CAT: During Selection, WITHIN EACH BLOCK

% This script reprocesses the expmt data structs from a user-selected set
% of files and generates families ranked by variability in turn bias

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

%define table to fill data over files
std_all = table();

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

    for i = 1:length(expmt.data.Turns.n)
        if expmt.data.Turns.n(i) <= 50
            expmt.data.Turns.rBias(i)=nan;
        end
    end

    tbl = expmt.meta.labels_table;

    tbl.TB = expmt.data.Turns.rBias';

    labels = tbl.('Strain');

    TB = tbl.('TB');

    tbl=tbl(~any(ismissing(tbl),2),:);
    
    G1 = groupsummary(tbl,"Strain");

    [G, fams] = findgroups(labels);

    if length(fams) == 4
        fams(4) = []
    end

    stdtb = splitapply(@std_calc,TB,G);

    if length(stdtb) == 4
        stdtb(4) = []
    end

    counts = table2cell(G1(:,2));

    T = table(fams,stdtb,counts);

    std_all = [std_all;T];

    clearvars -except varargin fPaths dir_idx fDir hwb std_all
end

delete(hwb);