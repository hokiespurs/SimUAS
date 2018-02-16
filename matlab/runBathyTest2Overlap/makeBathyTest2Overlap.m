function makeBathyTest2Overlap
% Compute True Overlap Percent
%% CONSTANTS
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\OVERSIDEB'; % Experiment Directory
PREFIX      = 'BATHYOVERSIDE';            % Experiment Prefix 
AOI         = 25;                        % UAS altitude in meters
SENSORWIDTH = 20;                         % Sensor Width (doesnt matter)
PIXX        = 2000;                       % Sensor X Pixels
PIXY        = 2000;                       % Sensor Y Pixels
SCALEPAD    = 1.15;                       % How much to pad the texture

%% INDEPENDENT VARIABLES
HFOVS = [20 30 40 50 60 70 80];
N_OVERLAPIMGS = 2:8;
DEPTHS = [0 1 2 3 4];

nExperiments = numel(HFOVS) * numel(N_OVERLAPIMGS) * numel(DEPTHS);
fprintf('Number of Experiments = %.0f\n',nExperiments);
%% PROCESSING INDEPENDENT VARIABLES
PS_CAMERA_ACCURACY = [0.01 0.5 5];

%% Compute Experiment Parameters
ind = 0;
EXPER = nan(nExperiments,4);
for iHFOV = HFOVS
    alt = calcAltForGSD(iHFOV,PIXX,AOI/PIXX);
    for kDEPTH = DEPTHS
        for jNOVERLAPS = N_OVERLAPIMGS
            ind = ind + 1;
            EXPER(ind,:) = [iHFOV, kDEPTH, jNOVERLAPS, alt];
        end
    end
end

%% Make Experiments
starttime = now;
for i=1:nExperiments
    hfov = EXPER(i,1);
    depth = EXPER(i,2);
    noverlap = EXPER(i,3);
    altitude = EXPER(i,4);
%     if any(noverlap==[3 6 7])
%         expdname = makeExperimentFolder(EXPDIRNAME, PREFIX, i);
%         rmdir(expdname,'s')
%     else
%         continue
%     end
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
    if depth==0
        scenedepth=-0.01; %dont want water surface and seafloor on same plane
    end
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
    
    % Make processing settings
    DNAME = sprintf('%s/proc/settings/',expdname);
    mkdir(DNAME);
    
    camcalname = 'sensor_photoscan.xml';
    trajname = 'trajectory_norpy.xml';
    
    camcal = camcalname;
    camlock = true;
    optim = true;
    optimset = '11100111011000';
    iProcNum = 0;
    settingnames=cell(numel(PS_CAMERA_ACCURACY)*numel(optim)*numel(camcal),1);
    for iCamAcc=1:numel(PS_CAMERA_ACCURACY)
                iProcNum = iProcNum+1;
                settingnames{iProcNum}=[DNAME sprintf('setting%02.0f.xml',iProcNum)];
                writeprocsettings([DNAME sprintf('setting%02.0f.xml',iProcNum)],...
                    'camposacc',PS_CAMERA_ACCURACY(iCamAcc),...
                    'trajectory',trajname,...
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
    %
    loopStatus(starttime,i,nExperiments,1);
end

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