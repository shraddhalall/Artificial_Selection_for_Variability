function circ_bias = AngleArrays(centroids, times, widths)

%% Called by circ_data_process.m 
% centroids should be 'zeroed' - i.e., position should be wrt roi center = 0,0

out={};
out.inx=squeeze(centroids(:,1,:));
out.iny=squeeze(centroids(:,2,:));

roi_rad = (widths/2)';

out.theta=atan2(out.iny,out.inx);
out.r=sqrt((out.inx).^2+(out.iny).^2)./roi_rad;

out.direction=nan(size(out.inx));
out.speed=nan(size(out.inx));
out.turning=nan(size(out.inx));

out.speed(2:end,:) = sqrt((diff(out.iny)).^2 + (diff(out.inx)).^2);
out.speed = out.speed./times;

out.direction(2:end,:)=atan2(diff(out.iny),diff(out.inx));
out.turning(2:end,:)=atan2(sin(diff(out.direction)),cos(diff(out.direction)));

speedthreshold=8; %bimodal log speed plot has two peaks with dip around 2, ln(8) = ~2

reject_indexes=(out.speed<speedthreshold) | (out.r>0.9);
out.direction(reject_indexes)=NaN;
out.turning(reject_indexes)=NaN;

out.angle=nan(size(out.inx));
out.angle(~reject_indexes)=out.theta(~reject_indexes)-out.direction(~reject_indexes);
out.angle(out.angle<0)=out.angle(out.angle<0)+2*pi();
out.angle=sin(out.angle);

circ_bias = mean(out.angle,1,"omitmissing");

end
