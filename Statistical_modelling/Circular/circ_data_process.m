function circ_table = circ_data_process()

%This function recursively searches through a directory, and extracts
%circling bias from all the .mat files in the directory. It gives a single 
%table with circling bias data from all the individuals from that directory. 

% Get paths to data files
fDir = autoDir;

fPaths = recursiveSearch(fDir{1},'ext','.mat');
fDir=cell(size(fPaths));
for j=1:length(fPaths)
    [tmp_dir,~,~]=fileparts(fPaths{j});
    fDir(j) = {[tmp_dir '/']};
end                    

% Process data
if ~iscell(fPaths)
    fPaths = {fPaths};
end

hwb = waitbar(0,'loading files');

data_all = table();

for i=1:length(fPaths)

    hwb = waitbar(i/length(fPaths),hwb,['processing file '...
        num2str(i) ' of ' num2str(length(fPaths))]);

    disp(['processing file ' num2str(i) ' of ' num2str(length(fPaths))]);
    load(fPaths{i});

    centroid = expmt.data.centroid.raw();
    time = expmt.data.time.raw();
    roi_struc = expmt.meta.roi;
    width_arr = roi_struc.corners();
    widths = ((width_arr(:,3)-width_arr(:,1))+(width_arr(:,4)-width_arr(:,2)))./2;
    centroid = zero_centroid(centroid,roi_struc);

    circ_bias = AngleArrays(centroid,time,widths);

    data_table = expmt.meta.labels_table;
    
    if ~any("Comments" == string(data_table.Properties.VariableNames))
        data_table.Comments = repmat({'Shraddha'},height(data_table),1);
    end

    data_table.circ_bias = circ_bias';

    date_split = strsplit(expmt.meta.date,'-');
    date = strjoin(date_split(1:3),'-');
    data_table.Date = repmat({date},height(data_table),1);

    data_all = [data_all;data_table];

end

circ_table = data_all;

delete(hwb);

end



    







