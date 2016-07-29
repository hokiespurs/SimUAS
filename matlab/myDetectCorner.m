function [x,y]=myDetectCorner(I)
MINCHECKERPIXSIZE = 10;
METRICTHRESH = 0.00;
GAUSSFILT = 1;

I = imgaussfilt(I,GAUSSFILT);

corners = detectHarrisFeatures(rgb2gray(I));
xy = corners.Location;
xy(corners.Metric<METRICTHRESH,:)=[];
indClose = rangesearch(xy,xy,MINCHECKERPIXSIZE);

for i=1:numel(indClose)
   if ~isnan(indClose{i})
       indpts = indClose{i};
       xy(i,:)=mean(xy(indpts,:),1);
       indClose(indpts)={nan};
   else
       xy(i,:)=[nan nan];
   end
%    figure(1)
%    plot(xy(:,1),xy(:,2),'k.');
%    hold on
%    plot(xy(indpts,1),xy(indpts,2),'c*')
%    plot(corners.Location(:,1),corners.Location(:,2),'ro')
%    plot(xy(i,1),xy(i,2),'mo','markersize',20)
%    hold off
end
badind = isnan(xy(:,1));
xy(badind,:)=[];

x = xy(:,1);
y = xy(:,2);

% figure
% image(I);
% hold on
% plot(corners.Location(:,1),corners.Location(:,2),'mo')
% plot(xy(:,1),xy(:,2),'g.')
% drawnow
end