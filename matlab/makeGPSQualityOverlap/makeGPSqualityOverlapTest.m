function makeGPSqualityOverlapTest
%
% RENDERING
% (5) DEPTHS                   = [ 0, 1, 2, 3, 4 ]
% (1) HFOV                     = [ 60 ]
% (1) IO                       = [ pinhole ]
% (1) GSD                      = [ 1cm ]
% (7) OVERLAP                  = [ 2, 3, 4, 5, 6, 7, 8 ]
% (6) EO NOISE MAGNITUDE       = [ 1, 3, 5, 10, 50, 100 ]
% (3) EO NOISE ITERATIONS      = [ 3 ]
% 
% PHOTOSCAN 
% (1) EO Traj Noise Magnitude  = [ 0(desired grid trajectory pre-noise) ]
% (1) EO Traj Noise Iterations = [ 1 ]
% (3) EO PS Setting Accuracy   = [ x0.1, x1, x10 ]
% (2) IO Loaded/Locked Setting = [ load/lock, no-load/no-lock ]
% (1) PS Sparse Setting        = [ high ]
% (1) PS Dense Setting         = [ lowest ]

%% Compute True Overlap Percent
warning off;
%% CONSTANTS
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\GPSQUALOVERLAP'; % Experiment Directory
PREFIX      = 'GPSQUALOVERLAP';                  % Experiment Prefix 
ALTITUDE    = 17.32;                      % UAS altitude in meters (1cm gsd)
SENSORWIDTH = 20;                         % Sensor Width (doesnt matter)
PIXX        = 2000;                       % Sensor X Pixels
PIXY        = 2000;                       % Sensor Y Pixels
SCALEPAD    = 1.15;                       % How much to pad the texture
HFOV        = 60;                         % Horizontal FOV
RANDSEED    = 14;
%% INDEPENDENT VARIABLES
NOVERLAPS = 2:8;
WATER_DEPTHS = [0 1 2 3 4];
ADDED_NOISE_LEVEL = [0.01 0.03 0.05 0.1 0.5 1];    % Reported GPS error in trajectory
PS_NOISE_LEVEL_SCALAR = [0.1 1 10];
NTRAJITER   = 3;                                    % number of simulations per GPS noise level

nExperiments = NTRAJITER * numel(WATER_DEPTHS) * numel(ADDED_NOISE_LEVEL) * numel(NOVERLAPS);
fprintf('Number of Experiments = %.0f\n',nExperiments);

%% Calc Experiment Parameters [noverlap, depths, noise]
[allwaterdepths,alladdednoise,allnoverlap]= ...
    meshgrid(WATER_DEPTHS,...
             kron(ADDED_NOISE_LEVEL,ones(1,NTRAJITER))',...
             NOVERLAPS);


EXPER = [allnoverlap(:) allwaterdepths(:) alladdednoise(:)];

AOI = 2 * ALTITUDE * tand(HFOV/2);
%% Make Experiments
for i=1:nExperiments
    hfov = HFOV;
    depth = EXPER(i,2);
    noverlap = EXPER(i,1);
    altitude = ALTITUDE;
    if ~(trajnoise==EXPER(i,3)) % seed random number generator
        rng(RANDSEED);
    end
    trajnoise = EXPER(i,3);
    % Make Experiment Folder
    expdname = makeExperimentFolder(EXPDIRNAME, PREFIX, i);
    
    % Compute Trajectory
    [xg,yg,~]=computeCameraPositions(hfov,noverlap,altitude);
    
    % Make Sensor.xml
    focallength = round(SENSORWIDTH/(2*tand(hfov/2)),3);
    writeSensor([expdname '/input/sensor_' sprintf('%.1f.xml',hfov)],...
        'sensorname',['overside' sprintf('%.1f',hfov)],...
        'focallength',focallength,'resolution',[PIXX PIXY],...
        'sensorwidth',SENSORWIDTH,'principalpoint',[PIXX PIXY]/2);
    
    % Make Scene.xml
      %* scene must be 3 times bigger than AOI... plus some padding
    texturescale = AOI * 3 * SCALEPAD;
    scenedepth=depth;

    writeBathyScene([expdname '/input/scene_' sprintf('%03.0f.xml',i)],...
        'oversidetest',scenedepth,texturescale);
   
    % Make Trajectory file
    zg = ones(size(xg))*altitude;
    R = zeros(size(xg));
    t = 1:numel(xg);
    
    xg_noise = xg + randn(size(xg))*trajnoise;
    yg_noise = yg + randn(size(yg))*trajnoise;
    zg_noise = zg + randn(size(zg))*trajnoise;
    
    writeTrajectory([expdname '/input/trajectory_' sprintf('%03.0f.xml',i)],'overside',...
        xg_noise(:),yg_noise(:),zg_noise(:),R(:),R(:),R(:),t,'img',4,0);

    % Make metadata file
    makeMetaFile(expdname, hfov, noverlap, depth, trajnoise);
    
    % Make Fake Trajectories and Processing Settings
    DNAME = sprintf('%s/proc/settings/',expdname);
    mkdir(DNAME);

    camcal = 'sensor_photoscan.xml';
    camlock = [true false];
    optim = true;
    optimset = '11100111011000';
    
    iProcNum = 0;
   %add noise
   trajname = sprintf('%s/proc/parameters/trajectory/trajDesired.xml',...
       expdname);

   trajRelativeName = sprintf('../proc/parameters/trajectory/trajDesired.xml');

   writeOutputTrajectory(trajname,xg,yg,zg)

   for ii = 1:numel(camlock)
       for jj=1:numel(PS_NOISE_LEVEL_SCALAR)
           iProcNum = iProcNum + 1;
           writeprocsettings([DNAME sprintf('setting%02.0f.xml',iProcNum)],...
               'camposacc',PS_NOISE_LEVEL_SCALAR(jj)*trajnoise,...
               'trajectory',trajRelativeName,...
               'sensorname',camcal,...
               'projectname',sprintf('setting%02.0f.xml',iProcNum),...
               'rootname',sprintf('%s/output','../..'),...
               'imagefoldername','images',...
               'sensorlock',camlock(ii),...
               'optimize',optim,...
               'optimizefits',optimset,...
               'outputroot',sprintf('%s/proc/results/setting%02.0f','../..',iProcNum),...
               'reprocmvsqual','00000',...
               'reprocmvsfilt','0000',...
               'sparseacc','high',...
               'densequality','medium');
       end
   end
    
end
   
warning on
end

function expdname = makeExperimentFolder(dname, prefix, ind)
    expdname = [dname '/' prefix '_' sprintf('%03.0f',ind)];
    if exist(expdname,'dir')
%         error('no force overwrite');
    end
    mkdir(expdname);
    mkdir([expdname '/input']);
    mkdir([expdname '/output']);
    mkdir([expdname '/proc']);
end

function makeMetaFile(expdname, iHfov, jNOverlap, kDepthPercent, acc)
    fid = fopen([expdname '/input/meta.txt'],'w+t');
    fprintf(fid,'Experiment to determine effect of sidelap/overlap\n');
    fprintf(fid,'No Distortion\n');
    fprintf(fid,'HFOV (deg)           : %f\n',iHfov);
    fprintf(fid,'Water Depth (m)      : %.2f\n',kDepthPercent);
    fprintf(fid,'N Overlapping Images : %f\n',jNOverlap);
    fprintf(fid,'GPS uncertainty      : %f\n',acc);
    fclose(fid);
end

function writeBathyScene(fname,name,waterdepth,scale)

if waterdepth<=0
    fidRead = fopen('scene_planeTemplate.xml'); % no water
else
    fidRead = fopen('scene_bathyplaneTemplate.xml');
end

    data = fread(fidRead,'*char');
    fclose(fidRead);
    
    data = strrep(data','\','\\')';
    
    fid = fopen(fname,'w');
    fprintf(fid,data,name,-waterdepth,scale,scale);
    fclose(fid);

end

function [xg,yg,footprint]=computeCameraPositions(hfov,noverlapimages,altitude)
    percentoverlap = ((1-1./noverlapimages)*100);
    nlines = noverlapimages*2+1;
    [dx,footprint] = calcOverlapDistance(hfov,altitude,percentoverlap);
    
    ni = (1:nlines)-mean(1:nlines);
    
    [xg,yg]=meshgrid(ni*dx,ni*dx);
    
end