clear
close all
clc

%% Test Marker locations 

dataDirectory = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\validateChecker1';
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
if isstruct(control)
    Cont.names = control.textdata(2:end,1);
    Cont.T = control.data(:,1:3);
    Cont.R = control.data(:,4:6);
else
    Cont.names{1} = '';
    Cont.T = [0 0 0];
    Cont.R = [0 0 0];
end
% Intrinsics
camIntrinsics = xml2struct(intrinsicFilename);
calibration = camIntrinsics.calibration;

%% For each Image

for iImage = 1:numel(Traj.names)
   I = imread([imDir Traj.names{iImage}]);
   
   [uMark,vMark] = calcPhotogrammetryUV(calibration, ...
       Traj.R(iImage,:), Traj.T(iImage,:), Mark.T);
   [uCont,vCont] = calcPhotogrammetryUV(calibration, ...
       Traj.R(iImage,:), Traj.T(iImage,:), Cont.T);
   figure(1)
   image(I)
   hold on
   plot(uMark,vMark,'m.')
   plot(uCont,vCont,'g.')
   hold off
   
%    xlim([min(uMark(:)) max(uMark(:))])
%    ylim([min(vMark(:)) max(vMark(:))])
    axis equal 
    title(Traj.names{iImage})
    
   pause(1)
end

