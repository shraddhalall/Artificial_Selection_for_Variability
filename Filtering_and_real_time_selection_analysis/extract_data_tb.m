function [tb_all] = extract_data_tb(varargin)
%CAT: During selection ACROSS BLOCKS

% This script reprocesses the raw data from MARGO expmt files selected by
% the user and generates a table of sex-separated individual turn biases

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
tb_all = table();

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

    for i = [1:length(expmt.data.Turns.n)]
        if expmt.data.Turns.n(i) <= 50
            expmt.data.Turns.rBias(i)=nan;
        end
    end

    tbl = expmt.meta.labels_table;

    tbl.TB = expmt.data.Turns.rBias';
    tbl.Sex = repmat("F", height(tbl), 1);

    tbl.Sex(tbl.ID > 14 & tbl.ID < 28) = "M";
    tbl.Sex(tbl.ID > 41 & tbl.ID < 55) = "M";
    tbl.Sex(tbl.ID > 68) = "M";
    
    labels = tbl.('Strain');
    ID = tbl.('ID');
    Sex = tbl.('Sex');

    TB = tbl.('TB');

    %tbl=tbl(~any(ismissing(tbl),2),:);
    
    
    T = table(labels,Sex,TB);

    tb_all = [tb_all;T];

    clearvars -except varargin fPaths dir_idx fDir hwb tb_all
end

delete(hwb);