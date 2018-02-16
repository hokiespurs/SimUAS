function makeWaveSims
% -	(1) FOV = 70
% -	(1) Texture
% 
% -	(1) Wavespeed (Random Camera pose times to disassociate phase)
% -	(5) Wavelength (2, 5, 10, 20)
% -	(5) Amplitude (0.1, 0.2, 0.5, 1)

% Compute Simulation with Sin Waves
%% CONSTANTS
EXPDIRNAME  = 'O:\simUAS\wavetest';       % Experiment Directory
PREFIX      = 'SINEWAVE';                  % Experiment Prefix 
SENSORWIDTH = 20;                         % Sensor Width (doesnt matter)
PIXX        = 2000;                       % Sensor X Pixels
PIXY        = 2000;                       % Sensor Y Pixels
SCALEPAD    = 1.05;                       % How much to pad the texture
HFOV        = 60;                         % Horizontal FOV
NOVERLAP    = 5;                          % Number of Overlaps Overlap Percent = 80

%% INDEPENDENT VARIABLES
DEPTH_PERCENTS = [0.025 0.05 0.10 0.2];
ALTITUDES      = [20 50 100];
WAVELENGTHS    = [2 5 10 20];
AMPLITUDES     = [0.1 0.2 0.3 0.4];

nExperiments = numel(DEPTH_PERCENTS) * numel(ALTITUDES) * ...
    numel(WAVELENGTHS) * numel(AMPLITUDES);
fprintf('Number of Experiments = %.0f\n',nExperiments);

%% Make Experiments
ind = 0;
starttime = now;
for ialtitude = ALTITUDES
    for kdepthpercent = DEPTH_PERCENTS
        if kdepthpercent==0
            kwaterdepth=0;
        else
            syms d;
            kwaterdepth = solve(d/(d+ialtitude)==kdepthpercent,d);
        end
        for jWavelength = WAVELENGTHS
            for lAmplitude = AMPLITUDES
                ind = ind+1;
                fprintf('Generating Experiment %03.0f \n',ind);
                
                % Make Experiment Folder
                expdname = makeExperimentFolder(EXPDIRNAME, PREFIX, ind);
                
                [xg,yg,footprint]=computeCameraPositions(HFOV,...
                    NOVERLAP,ialtitude);
                
                % Make Sensor.xml
                focallength = round(SENSORWIDTH/(2*tand(HFOV/2)),3);
                writeSensor([expdname '/input/sensor_' sprintf('%.1f.xml',HFOV)],...
                    'sensorname',['overside' sprintf('%.1f',HFOV)],...
                    'focallength',focallength,'resolution',[PIXX PIXY],...
                    'sensorwidth',SENSORWIDTH,'principalpoint',[PIXX PIXY]/2);
                
                % Make Scene file
                texturescale = SCALEPAD * repmat(max(2*([max(xg(:)) max(yg(:))]+footprint/2)),1,2);
                
                ncams = numel(xg);
                writeBathySceneWaves([expdname '/input/scene_' sprintf('%03.0f.xml',ind)],...
                    'bathywaves',kwaterdepth,texturescale,jWavelength,lAmplitude,ncams)
                
                % Make Trajectory file
                zg = ones(size(xg))*ialtitude;

                
                rpy = zeros(size(zg));
                t = 1:numel(xg);
                
                writeTrajectory([expdname '/input/trajectory' sprintf('%.0f_truth.xml',ind)],'overside',...
                    xg(:),yg(:),zg(:),rpy,rpy,rpy,t,'img',4,0);
                
                % Make metadata file
                makeMetaFile(expdname, ialtitude, kdepthpercent, jWavelength, lAmplitude);

                % Make processing settings
                DNAME = sprintf('%s/proc/settings/',expdname);
                mkdir(DNAME);
                % make settings
                camacc = [0.01 0.5 10];
                camcalname = 'sensor_photoscan.xml';
                trajname = 'trajectory_norpy.xml';

                camcal = {camcalname};
                camlock = [true];
                optim = [true];
                optimset = {'11100111011000'};
                iProcNum = 0;
                settingnames=cell(numel(camacc)*numel(optim)*numel(camcal),1);
                for iCamAcc=1:numel(camacc)
                    for jCamCal=1:numel(camcal)
                        for koptim=1:numel(optim)
                            iProcNum = iProcNum+1;
                            settingnames{iProcNum}=[DNAME sprintf('setting%02.0f.xml',iProcNum)];
                            writeprocsettings([DNAME sprintf('setting%02.0f.xml',iProcNum)],...
                                'camposacc',camacc(iCamAcc),...
                                'trajectory',trajname,...
                                'sensorname',camcal{jCamCal},...
                                'projectname',sprintf('setting%02.0f.xml',iProcNum),...
                                'rootname',sprintf('%s/output','../..'),...
                                'imagefoldername','images',...
                                'sensorlock',camlock(jCamCal),...
                                'optimize',optim(koptim),...
                                'optimizefits',optimset{koptim},...
                                'outputroot',sprintf('%s/proc/results/setting%02.0f','../..',iProcNum),...
                                'reprocmvsqual','00000',...
                                'reprocmvsfilt','0000',...
                                'sparseacc','high',...
                                'densequality','medium');
    %                         fprintf('%i:posacc: %05.2f - camcal %i - optim %i\n',iProcNum,camacc(iCamAcc),jCamCal,koptim)
                        end
                    end
                end
            % 
                loopStatus(starttime,ind,nExperiments,10);
            end
        end
    end
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

function makeMetaFile(expdname, ialtitude, kdepthpercent, jWavelength, lAmplitude)
    fid = fopen([expdname '/input/meta.txt'],'w+t');
    fprintf(fid,'Experiment to determine effect of sidelap/overlap\n');
    fprintf(fid,'No Distortion\n');
    fprintf(fid,'Altitude           : %f\n',ialtitude);
    fprintf(fid,'Water Percent      : %.2f\n',kdepthpercent);
    fprintf(fid,'Water Wavelength   : %f\n',jWavelength);
    fprintf(fid,'Water Amplitude    : %.0f\n',lAmplitude);

    fclose(fid);
end

function writeBathySceneWaves(fname,name,waterdepth,scale,jWavelength,lAmplitude,ncams)
% fprintf(fid,data,name,jWavelength,jWavelength,lAmplitude,-waterdepth,scale);

fid = fopen(fname,'w');
% fid = 1;
fprintf(fid,addSceneHeader(name,'objects/beaverdb'));
% header
fprintf(fid,addSceneEnvironment('envlight',0.5,'envlighttime',1,...
    'horizonRGB',[1 1 1],'horizontime',1,...
    'zenithRGB',[1 1 1],'zenithtime',1));
% seafloor
tx = 0; ty = 0; tz = -waterdepth; tt = 0;
rx = 0; ry = 0; rz = 0; tr = 0;
sx = scale(1); sy = scale(2); sz = 1; ts = 0;
tex = {'objects\\textures\\buck.png',...
       'objects\\textures\\rock_square.png',...
       'objects\\textures\\randomNoise.png'};
fprintf(fid,addSceneObject('basic_plane','seafloor',...
    'tx',tx,'ty',ty,'tz',tz,'tt',tt,...
    'rx',rx,'ry',ry,'rz',rz,'tr',tr,...
    'sx',sx,'sy',sy,'sz',sz,'ts',ts,...
    'texture',tex,'textureinterpolate',[1 1 1],'textureRepX',[1 5 1],...
    'textureRepY',[1 5 1],'textureinterpolate',[1 1 1],...
    'textureInfColor',[1 0.2 0.3]));
% water surface
tx = jWavelength*rand(ncams,1); ty = zeros(size(tx)); tz = zeros(size(tx)); tt = randperm(ncams,ncams);
rx = 0; ry = 0; rz = 0; tr = 0;
sx = jWavelength; sy = jWavelength; sz = lAmplitude; ts = 0;
fprintf(fid,addSceneObject('basic_plane','seafloor',...
    'tx',tx,'ty',ty,'tz',tz,'tt',tt,...
    'rx',rx,'ry',ry,'rz',rz,'tr',tr,...
    'sx',sx,'sy',sy,'sz',sz,'ts',ts,...
    'Shadeless',1,'receiveShadow',0,'castshadow',0,...
    'alphatransparency',0.2,'alphaior',1.33));
fprintf(fid,'</scene>\n');
fclose(fid);

end

function [xg,yg,footprint]=computeCameraPositions(hfov,noverlapimages,altitude)
    percentoverlap = ((1-1./noverlapimages)*100);
    nlines = calcNoverlap(percentoverlap);
    [dx,footprint] = calcOverlapDistance(hfov,altitude,percentoverlap);
    
    ni = (1:nlines)-mean(1:nlines);
    
    [xg,yg]=meshgrid(ni*dx,ni*dx);
    
end