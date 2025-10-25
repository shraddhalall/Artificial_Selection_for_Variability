function centroids_zeroed = zero_centroid(centroids,roi)

%Called by circ_data_process.m 

centers = roi.centers';

centroids_zeroed = nan(size(centroids));

centroids_zeroed(:,1,:) = squeeze(centroids(:,1,:))-centers(1,:);
centroids_zeroed(:,2,:) = squeeze(centroids(:,2,:))-centers(2,:);

end