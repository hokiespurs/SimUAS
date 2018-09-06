function makeGPSqualityTest
% Compute True Overlap Percent
warning off;
%% CONSTANTS
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\GPSQUALTEST'; % Experiment Directory
PREFIX      = 'GPSQUAL';                  % Experiment Prefix 
ALTITUDE    = 40;                         % UAS altitude in meters
SENSORWIDTH = 20;                         % Sensor Width (doesnt matter)
PIXX        = 2000;                       % Sensor X Pixels
PIXY        = 2000;                       % Sensor Y Pixels
SCALEPAD    = 1.15;                       % How much to pad the texture
HFOV        = 60;                         % Horizontal FOV
NOVERLAP    = 4;                          % Number of Overlaps Overlap Percent = 75
RANDSEED    = 14;
%% INDEPENDENT VARIABLES
WATER_DEPTHS = [0 1 2 3 4];
ADDED_NOISE_LEVEL = [0 0.01 0.03 0.05 0.1 0.5 2];    % Reported GPS error in trajectory
PS_NOISE_LEVEL = [0.001 0.01 0.03 0.05 0.1 0.5 2];
NTRAJITER   = 10;                                    % number of simulations per GPS noise level

nExperiments = numel(WATER_DEPTHS);
fprintf('Number of Experiments = %.0f\n',nExperiments);

%% Calc Experiment Parameters
EXPER = [ones(nExperiments,1)*HFOV, WATER_DEPTHS', ones(nExperiments,1)*NOVERLAP, ...
         ones(nExperiments,1)*ALTITUDE];

AOI = 2 * ALTITUDE * tand(HFOV/2);
%% Make Experiments
for i=1:nExperiments
    hfov = EXPER(i,1);
    depth = EXPER(i,2);
    noverlap = EXPER(i,3);
    altitude = EXPER(i,4);
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
    writeTrajectory([expdname '/input/trajectory_' sprintf('%03.0f.xml',i)],'overside',...
        xg(:),yg(:),zg(:),R(:),R(:),R(:),t,'img',4,0);

    % Make metadata file
    makeMetaFile(expdname, hfov, noverlap, depth);
    
    % Make Fake Trajectories and Processing Settings
    DNAME = sprintf('%s/proc/settings/',expdname);
    mkdir(DNAME);

    camcal = 'sensor_photoscan.xml';
    camlock = true;
    optim = true;
    optimset = '11100111011000';
    
    rng(RANDSEED); % same random traj for each depth
    iProcNum = 0;
    for inoiselevel=1:numel(ADDED_NOISE_LEVEL)
        for jiter = 1:NTRAJITER
           iProcNum = iProcNum + 1;
           %add noise
           xg_noise = xg + randn(size(xg))*ADDED_NOISE_LEVEL(inoiselevel);
           yg_noise = yg + randn(size(yg))*ADDED_NOISE_LEVEL(inoiselevel);
           zg_noise = zg + randn(size(zg))*ADDED_NOISE_LEVEL(inoiselevel);
           trajname = sprintf('%s/proc/parameters/trajectory/trajnoise_%02.2f_%02.0f.xml',...
               expdname,ADDED_NOISE_LEVEL(inoiselevel),jiter);
           
           trajRelativeName = sprintf('../proc/parameters/trajectory/trajnoise_%02.2f_%02.0f.xml',...
               ADDED_NOISE_LEVEL(inoiselevel),jiter);
           
           writeOutputTrajectory(trajname,xg_noise,yg_noise,zg_noise)

           writeprocsettings([DNAME sprintf('setting%02.0f.xml',iProcNum)],...
               'camposacc',PS_NOISE_LEVEL(inoiselevel),...
               'trajectory',trajRelativeName,...
               'sensorname',camcal,...
               'projectname',sprintf('setting%02.0f.xml',iProcNum),...
               'rootname',sprintf('%s/output','../..'),...
               'imagefoldername','images',...
               'sensorlock',camlock,...
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

function makeMetaFile(expdname, iHfov, jNOverlap, kDepthPercent)
    fid = fopen([expdname '/input/meta.txt'],'w+t');
    fprintf(fid,'Experiment to determine effect of sidelap/overlap\n');
    fprintf(fid,'No Distortion\n');
    fprintf(fid,'HFOV (deg)           : %f\n',iHfov);
    fprintf(fid,'Water Depth (m)      : %.2f\n',kDepthPercent);
    fprintf(fid,'N Overlapping Images : %f\n',jNOverlap);
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