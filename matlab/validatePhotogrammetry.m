function validatePhotogrammetry(foldername,detectCornerType)
dbstop if error
if nargin==1
   detectCornerType = 1; 
end
%% paths to folders
imDir = [foldername '/output/images/'];
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

%% Calculate Pixel Projections for Each Image
mkdir([foldername '/proc']);
mkdir([foldername '/proc/points']);
mkdir([foldername '/proc/deltas']);
f = figure;
f2 = figure;
all_du = [];
all_dv = [];
for iCamera = 1:numel(Trajectory.names)
    I = imread([imDir Trajectory.names{iCamera}]);
    
    camT = Trajectory.T(iCamera,:);
    camR = Trajectory.R(iCamera,:);
    markT = Fiducials.T;
    
    [xy, ~] = calcXYZtoPixel(markT, camT, camR, Calibration);
    uFiducials = xy(:,1);
    vFiducials = xy(:,2);
    
    [xy, ~] = calcXYZtoPixel(Control.T, Trajectory.T(iCamera,:), Trajectory.R(iCamera,:), Calibration);
    uControl = xy(:,1);
    vControl = xy(:,2);
    
    if detectCornerType == 1
        [uCheck,vCheck] = myDetectCorner(I);
    else
        [xy,~]=detectCheckerboardPoints(I);
        uCheck = xy(:,1);
        vCheck = xy(:,2);
    end
    
   figure(f);
   image(I)
   axis equal
   ax = axis;
   hold on
   plot(uFiducials,vFiducials,'mo')
   plot(uCheck,vCheck,'c.')
   plot(uControl,vControl,'g.')
   hold off
%    xlim([min(uFiducials(:)) max(uFiducials(:))])
%    ylim([min(vFiducials(:)) max(vFiducials(:))])
    axis(ax)
    title(Trajectory.names{iCamera})
    drawnow
    saveas(f,[foldername '/proc/points/' Trajectory.names{iCamera}])
  %% calc bias and std
  du = [];
  dv = [];
  for i=1:numel(uCheck)
      dist2points = pdist2([uCheck(i) vCheck(i)],[uFiducials vFiducials]);
      [val,ind] = min(dist2points);
      du(i) = uCheck(i)-uFiducials(ind);
      dv(i) = vCheck(i)-vFiducials(ind);
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
  title(Trajectory.names{iCamera})
  
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
  saveas(f2,[foldername '/proc/deltas/' Trajectory.names{iCamera}])
  pause(0.05)
    
end

end

function Trajectory = readtrajectory(fname)
rawdata = importdata(fname);
Trajectory.names = rawdata.textdata(2:end,1);
Trajectory.T = rawdata.data(:,1:3);
Trajectory.R = rawdata.data(:,4:6);

end

function Fiducials = readfiducials(fname)
rawdata = importdata(fname);
Fiducials.names = rawdata.textdata(2:end,1);
Fiducials.T = rawdata.data(:,1:3);
end

function Control = readcontrol(fname)
rawdata = importdata(fname);
if isstruct(rawdata)
    Control.names = rawdata.textdata(2:end,1);
    Control.T = rawdata.data(:,1:3);
else
    Control.names{1} = '';
    Control.T = [0 0 0];
    error('why did this happen?')
end
end

function Cal = readsensor(outsensor, insensor)
    indata = xml2struct(insensor);
    outdata = xml2struct(outsensor);
    oc = outdata.calibration;
    isp = indata.sensor.postprocessing;
    
    Cal.width = str2double(oc.width.Text);
    Cal.height = str2double(oc.height.Text);
    Cal.fx = str2double(oc.f.Text);
    Cal.fy = str2double(oc.f.Text);
    Cal.cx = str2double(oc.cx.Text);
    Cal.cy = str2double(oc.cy.Text);
    Cal.k = [str2double(oc.k1.Text),...
                     str2double(oc.k2.Text),...
                     str2double(oc.k3.Text),...
                     str2double(oc.k4.Text)];
    Cal.p = [str2double(oc.p1.Text),...
                     str2double(oc.p2.Text)];
    
    Cal.postproc.vignetting = [str2double(isp.vignetting.Attributes.v1),...
                             str2double(isp.vignetting.Attributes.v2),...
                             str2double(isp.vignetting.Attributes.v3)];
    Cal.postproc.saltnoise = str2double(isp.saltnoise.Attributes.prob);
    Cal.postproc.peppernoise = str2double(isp.peppernoise.Attributes.prob);
    Cal.postproc.gaussnoise.mean = ...
        str2double(isp.gaussiannoise.Attributes.mean);
    Cal.postproc.gaussnoise.var = ...
        str2double(isp.gaussiannoise.Attributes.variance);
    Cal.postproc.gaussblur = str2double(isp.gaussianblur.Attributes.sigma); 
    Cal.seed = str2double(isp.Attributes.seed);
end