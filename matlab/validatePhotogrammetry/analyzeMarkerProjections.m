function analyzeMarkerProjections(foldername)
dbstop if error
addpath(genpath('../'))

if nargin==0
   foldername = '../../data\calroom'; 
end
%% paths to folders
imDir = [foldername '/output/images/pre'];
outImDir = [foldername '/output/images'];
trajectoryFilename = [foldername '/output/trajectory.csv'];
fiducialFilename = [foldername '/output/xyzfiducial.csv'];
fiducialSavename = [foldername '/output/pixelfiducial.xml'];
controlFilename = [foldername '/output/xyzcontrol.csv'];
controlSavename = [foldername '/output/pixelcontrol.xml'];
intrinsicFilename = [foldername '/output/sensor.xml'];
foo = dirname([foldername '/input/sensor*.xml']);
inputSensorFilename = foo{1};

%% read input data
Trajectory = readtrajectory(trajectoryFilename);
Fiducials = readfiducials(fiducialFilename);
Control = readcontrol(controlFilename);
Calibration = readsensor(intrinsicFilename, inputSensorFilename);

%% 
[proj_x,proj_y,image_x,image_y,dx,dy]=calcFiducial(outImDir,Trajectory,Fiducials,Calibration);

%% Delta Plots
close all

figure(1)
plot(dx,dy,'b.','markersize',1)
xlim([-1 1]);
ylim([-1 1]);
xlabel('Image X minus Projected X (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('Image Points Minus Projected Points (pixels)');

figure(2)
xgi = -1:0.05:1;
ygi = -1:0.05:1;
H = heatmapscat(dx,dy,xgi,ygi);
npts = sum(~isnan(dx(:)));
pcolor(xgi,ygi,H/npts*100);shading flat
h = colorbar;
ylabel(h,'Percentage of Points in Bin','fontsize',20);
xlabel('Image X minus Projected X (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('Heatmap of Image Points Minus Projected Points (pixels)');

%% correlation plots
r = sqrt((Calibration.cx-proj_x).^2+(Calibration.cy-proj_y).^2);
dr = sqrt(dx.^2+dy.^2);
figure(3)

subplot 421
plot(proj_x,dx,'b.');grid on
ylim([-1 1])
xlabel('Projected X Coordinates (pixels)');
ylabel('Image X minus Projected X (pixels)');
title('proj\_x vs dx')

subplot 422
plot(proj_x,dy,'b.');grid on
ylim([-1 1])
xlabel('Projected X Coordinates (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('proj\_x vs dy')

subplot 423
plot(proj_y,dx,'b.');grid on
title('proj\_y vs dx')
ylim([-1 1])
xlabel('Projected Y Coordinates (pixels)');
ylabel('Image X minus Projected X (pixels)');

subplot 424
plot(proj_y,dy,'b.');grid on
ylim([-1 1])
xlabel('Projected Y Coordinates (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('proj\_y vs dy')

subplot 425
plot(r,dx,'b.');grid on
ylim([-1 1])
xlabel('Projected Radius to Principal Point (pixels)');
ylabel('Image X minus Projected X (pixels)');
title('radius to principal point vs dx')

subplot 426
plot(r,dy,'b.');grid on
ylim([-1 1])
xlabel('Projected Radius to Principal Point (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('radius to principal point vs dy')

subplot 427
plot(r,dr,'b.');grid on
ylim([0 1])
xlabel('Projected Radius to Principal Point (pixels)');
ylabel('Image total pixel error \sqrt(dx^2+dy^2)');
title('radius to principal point vs delta radius')

subplot 428
scatter(proj_x(:),proj_y(:),10,dr(:),'filled');grid on
caxis([0 0.1])
xlabel('Projected X Coordinates (pixels)');
ylabel('Projected Y Coordinates (pixels)');
colormap(jet(256));
title('delta radius plotted at projected points')

%% Image with plots overlaid
iNames = dirname([outImDir '/*.png']);
[~,ind]=max(sum(~isnan(dx)));
I = imread(iNames{ind});
figure(4)
clf
image(I)
hold on
plot(image_x(:,ind),image_y(:,ind),'g.','markersize',30);
plot(proj_x(:,ind),proj_y(:,ind),'r.','markersize',15);
legend('Image Points','Projected Points')
xlabel('Image X Coordinate (pixels)');
ylabel('Image Y Coordinate (pixels)');
title('All Points Detected for example Image');

figure(5)
clf
[dmax,imax] = nanmax(sqrt(dx(:,ind).^2 + dx(:,ind).^2));
[dmin,imin] = nanmin(sqrt(dx(:,ind).^2 + dx(:,ind).^2));

subplot 121
image(I)
hold on
plot(image_x(imin,ind),image_y(imin,ind),'g.','markersize',30);
plot(proj_x(imin,ind),proj_y(imin,ind),'r.','markersize',15);
axis equal
xlim([proj_x(imin,ind)-10 proj_x(imin,ind)+10]);
ylim([proj_y(imin,ind)-10 proj_y(imin,ind)+10]);
legend('Image Points','Projected Points')
xlabel('Image X Coordinate (pixels)');
ylabel('Image Y Coordinate (pixels)');
title(sprintf('Most Accurate Image Detection(delta %.3f pixels)',dmin));

subplot 122
image(I)
hold on
plot(image_x(imax,ind),image_y(imax,ind),'g.','markersize',30);
plot(proj_x(imax,ind),proj_y(imax,ind),'r.','markersize',15);
axis equal
xlim([proj_x(imax,ind)-10 proj_x(imax,ind)+10]);
ylim([proj_y(imax,ind)-10 proj_y(imax,ind)+10]);
legend('Image Points','Projected Points')
xlabel('Image X Coordinate (pixels)');
ylabel('Image Y Coordinate (pixels)');
title(sprintf('Least Accurate Image Detection(delta %.3f pixels)',dmax));
end

function [proj_x,proj_y,image_x,image_y,dx,dy]=calcFiducial(outImDir,Trajectory,Fiducials,Calibration)
iNames = dirname([outImDir '/*.png']);
NLOOPS = numel(Trajectory.names);
NSKIPS = 1;
startTime = now;
%preallocate
Npts = numel(Fiducials.names);
proj_x = nan(Npts,NLOOPS);
proj_y = nan(Npts,NLOOPS);
image_x = nan(Npts,NLOOPS);
image_y = nan(Npts,NLOOPS);
dx = nan(Npts,NLOOPS);
dy = nan(Npts,NLOOPS);
for iImage = 1:numel(Trajectory.names)
    [image_xy] = detectFiducials(iNames{iImage},1);
    [projected_xy] = projectFiducials(Fiducials, ...
        Trajectory.T(iImage,:), Trajectory.R(iImage,:), Calibration);
    proj_x(:,iImage) = projected_xy(:,1);
    proj_y(:,iImage) = projected_xy(:,2);

    if numel(image_xy)>0 && numel(projected_xy)>0
        [IDX,D] = knnsearch(image_xy,projected_xy);
        badvals = zeros(size(IDX));
        badvals(D>5)=nan; % this turns bad values to nans on the next line
        image_x(:,iImage) = image_xy(IDX,1);
        image_y(:,iImage) = image_xy(IDX,2);
        dx(:,iImage) = image_xy(IDX,1) - projected_xy(:,1) + badvals;
        dy(:,iImage) = image_xy(IDX,2) - projected_xy(:,2) + badvals;
    else
        image_x(:,iImage) = nan;
        image_y(:,iImage) = nan;
        dx(:,iImage)=nan;
        dy(:,iImage)=nan;
    end
    loopStatus(startTime,iImage,NLOOPS,NSKIPS);
end

end

function xy=myDetectCorner(I)
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

% figure
% image(I);
% hold on
% plot(corners.Location(:,1),corners.Location(:,2),'mo')
% plot(xy(:,1),xy(:,2),'g.')
% drawnow
end

function xy=projectFiducials(Fiducials, T, R, Calibration)

for i=1:numel(Fiducials.names)
    [xy(i,:), inframe] = calcXYZtoPixel(Fiducials.T(i,:), T, R, Calibration);
end

end

function xy = detectFiducials(imname, method)
I = imread(imname);

if method==1
    [xy,~] = detectCheckerboardPoints(I);
else
    xy=myDetectCorner(I);    
end
xy = xy - 0.5;

end
