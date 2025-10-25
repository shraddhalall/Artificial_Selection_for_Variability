function [data_all] = extract_copulation_metadata(varargin)

% This script reprocesses the expmt data structs from a user-selected set
% of .mat files and extracts metadata - date, box, tray etc

keyarg = {};
for i=1:length(varargin)
    arg = varargin{i};
    disp(arg)
    if ischar(arg)
        switch arg
            case 'Keyword'
                keyidx = i;
                j=i+1;
                keyarg = {'keyword';varargin{j}};
        end
    end
end

if exist('keyidx','var')
    varargin(keyidx:keyidx+1)=[];
end

%define table to fill data over files
data_all = table();

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
    disp(fPaths{i});
    load(fPaths{i});
    fname = fPaths{i};
    fname_sp = strsplit(fname,'/');
    varargin(dir_idx)=fDir(i);

    tbl = expmt.meta.labels_table;

    if any("Comments" == string(tbl.Properties.VariableNames))
        tbl = removevars(tbl, "Comments");
    end

    tbl.fname = repmat(fname_sp(7),height(tbl),1);

    date_split = strsplit(expmt.meta.date,'-');
    date = strjoin(date_split(1:3),'-');
    tbl.Date = repmat({date},height(tbl),1);

    data_all = [data_all;tbl];

    clearvars -except varargin fPaths dir_idx fDir hwb data_all
end

delete(hwb);