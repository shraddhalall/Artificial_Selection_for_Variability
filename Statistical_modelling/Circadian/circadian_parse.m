function [circ_table] = circadian_parse()
%Generates table with metadata information for all selected matlab expmt
%folders 

%define table to fill data over files
circ_table = table();

% Get paths to data files
fDir = autoDir;
fnamedir = fDir{1};

fPaths = recursiveSearch(fDir{1},'ext','.mat');
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
    
    %get time of start

    start_time = split(expmt.meta.date,"-");

    hh = start_time(4);
    hh = str2num(hh{1});

    mm = start_time(5);
    mm = str2num(mm{1});

    ss_split = split(start_time(6),'_');

    ss = ss_split(1);
    ss = str2num(ss{1});

    NROI = expmt.meta.num_traces;

    date = string(strjoin(start_time(1:3),'-'));
    box = expmt.meta.labels_table{1,"Box"};
    tray = expmt.meta.labels_table{1,"Tray"};

    T = table(i,hh,mm,ss,NROI,date,box,tray);

    circ_table = [circ_table;T];

    %labels = expmt.meta.labels;
    %labels = labels(1:4,1:5);
    %labels(:,2) = [];
    %label_table = cell2table(labels);

    %fname = append(fnamedir,'\label_table\',num2str(i),'.csv');
    %writetable(label_table,fname);

    clearvars -except fPaths fDir fnamedir hwb circ_table
end