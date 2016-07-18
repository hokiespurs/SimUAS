%% testOrthos
clear
close all
clc

%% Test Marker locations 

dataDirectory = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\example';
imDir = [dataDirectory '/output/images/'];
trajectoryFilename = [dataDirectory '/output/trajectory.txt'];
markerFilename = [dataDirectory '/output/marker.txt'];
controlFilename = [dataDirectory '/output/control.txt'];
intrinsicFilename = [dataDirectory '/output/sensor.xml'];

trajectory = importdata(trajectoryFilename);
markers = importdata(markerFilename);
control = importdata(controlFilename);

%% Assemble Structures
% Trajectory
Traj.names = trajectory.textdata(2:end,1);
Traj.T = trajectory.data(:,1:3);
Traj.R = trajectory.data(:,4:6);

% Markers 
Mark.names = markers.textdata(2:end,1);
Mark.T = markers.data(:,1:3);

% Control
Cont.names = control.textdata(2:end,1);
Cont.T = control.data(:,1:3);
Cont.R = control.data(:,4:6);

% Intrinsics
camIntrinsics = xml2struct(intrinsicFilename);
calibration = camIntrinsics.calibration;


[xg,yg] = meshgrid(-50:.5:50,-50:.5:50);
zg = zeros(size(xg));
xyz = [xg(:) yg(:) zg(:)];
%% make ortho for each image
for iImage = 1:numel(Traj.names)
    I = imread([imDir Traj.names{iImage}]);
    I = fliplr(I);
    [uG,vG,sG] = calcPhotogrammetryUV(calibration, ...
       Traj.R(iImage,:), Traj.T(iImage,:), xyz);
    
   R = I(:,:,1);R(1)=0;
   G = I(:,:,2);G(1)=0;
   B = I(:,:,3);B(1)=0;
   
   uG = round(uG);
   vG = round(vG);
   
   [m,n,~]=size(I);
   indbad = uG<1 | uG>=m | vG<1 | vG>=n | sG<0 ;
   
   uG(indbad)=1;
   vG(indbad)=1;
   
   indx=sub2ind([m,n],uG,vG);
   indx=reshape(indx,size(xg));
   
   [mgrid,ngrid]=size(xg);
   
   Ortho=zeros(mgrid,ngrid,3,'uint8');
    Ortho(:,:,1)=R(indx);
    Ortho(:,:,2)=G(indx);
    Ortho(:,:,3)=B(indx);
    
    imagesc(xg(1,:),yg(:,1),Ortho)
    title(Traj.names{iImage})
    set(gca,'ydir','normal')
    pause(1)
end


