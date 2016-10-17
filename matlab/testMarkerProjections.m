clear
close all
clc
all_du = [];
all_dv = [];
%% Test Marker locations 

dataDirectory = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\foo';
imDir = [dataDirectory '/output/images/'];
trajectoryFilename = [dataDirectory '/output/trajectory.csv'];
markerFilename = [dataDirectory '/output/xyzFiducial.csv'];
controlFilename = [dataDirectory '/output/xyzControl.csv'];
intrinsicFilename = [dataDirectory '/output/sensor.xml'];
foo = dirname([dataDirectory '/output/sensor*.xml']);
inputSensorFilename = foo{1};

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
mkdir([dataDirectory '/proc']);
mkdir([dataDirectory '/proc/points']);
mkdir([dataDirectory '/proc/deltas']);

f = figure('units','normalized','position',[0 0 1 1]);
f2 = figure('units','normalized','position',[0 0 1 1]);
for iImage = 1:numel(Traj.names)
   I = imread([imDir Traj.names{iImage}]);
   
   [uMark,vMark] = calcPhotogrammetryUV(calibration, ...
       Traj.R(iImage,:), Traj.T(iImage,:), Mark.T);
   [uCont,vCont] = calcPhotogrammetryUV(calibration, ...
       Traj.R(iImage,:), Traj.T(iImage,:), Cont.T);
   [uCheck,vCheck] = myDetectCorner(I);
   
   [xy,~]=detectCheckerboardPoints(I);
   uCheck = xy(:,1);
   vCheck = xy(:,2);
   
   figure(f);
   image(I)
   axis equal
   ax = axis;
   hold on
   plot(uMark,vMark,'mo')
   plot(uCheck,vCheck,'c.')
   plot(uCont,vCont,'g.')
   hold off
%    xlim([min(uMark(:)) max(uMark(:))])
%    ylim([min(vMark(:)) max(vMark(:))])
    axis(ax)
    title(Traj.names{iImage})
    drawnow
    saveas(f,[dataDirectory '/proc/points/' Traj.names{iImage}])
  %% calc bias and std
  du = [];
  dv = [];
  for i=1:numel(uCheck)
      dist2points = pdist2([uCheck(i) vCheck(i)],[uMark' vMark']);
      [val,ind] = min(dist2points);
      du(i) = uCheck(i)-uMark(ind);
      dv(i) = vCheck(i)-vMark(ind);
  end
  figure(f2);
  subplot(221)
  hist(du);
  title('du')
  
  subplot(222)
  hist(dv)
  title('dv')
  
  subplot(223)
  plot(du,dv,'b.')
  xlim([-3 3]);
  ylim([-3 3])
  grid on
  title(Traj.names{iImage})
  
  all_du = [all_du du];
  all_dv = [all_dv dv];
  
  subplot 224
  xgi = -2:0.1:2;
  ygi = -2:0.1:2;
  H = heatmapscat(all_du,all_dv,xgi,ygi);
  pcolor(xgi,ygi,H);shading interp
  title('cumulative heatmap');
%   hold on
%   plot(du,dv,'m.','markersize',3);
%   hold off
  saveas(f2,[dataDirectory '/proc/deltas/' Traj.names{iImage}])
  pause(0.05)
end

f3 = figure('units','normalized','position',[0 0 1 1]);
xgi = -2:0.1:2;
ygi = -2:0.1:2;
H = heatmapscat(all_du,all_dv,xgi,ygi);
pcolor(xgi,ygi,H);shading interp
