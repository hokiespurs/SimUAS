function makeBathyTest2Overlap
% Compute True Overlap Percent
%% CONSTANTS
EXPDIRNAME  = 'O:\simUAS\overlapsidelap'; % Experiment Directory
PREFIX      = 'BATHYOVERSIDE';            % Experiment Prefix 
ALTITUDE    = 100;                        % UAS altitude in meters
SENSORWIDTH = 20;                         % Sensor Width (doesnt matter)
PIXX        = 2000;                       % Sensor X Pixels
PIXY        = 2000;                       % Sensor Y Pixels
SCALEPAD    = 1.05;                       % How much to pad the texture

%% INDEPENDENT VARIABLES
HFOVS = [30 40 50 60 70];
N_OVERLAPIMGS = 2:8;
DEPTH_PERCENTS = [0 0.01 0.05 0.10 0.15];

nExperiments = numel(HFOVS) * numel(N_OVERLAPIMGS) * numel(DEPTH_PERCENTS);
fprintf('Number of Experiments = %.0f\n',nExperiments);

%% Solve Water Depths
syms d;
waterdepths = nan(1,numel(DEPTH_PERCENTS));
for i=1:numel(DEPTH_PERCENTS)
    if DEPTH_PERCENTS == 0
        waterdepths(i) = 0;
    else
        waterdepths(i) = solve(d/(d+ALTITUDE)==DEPTH_PERCENTS(i),d);
    end
end

%% Make Experiments
ind = 0;
for iHfov = HFOVS
    for jNOverlap = N_OVERLAPIMGS
        for kwaterdepths = waterdepths
            ind = ind+1;
            fprintf('Generating Experiment %03f.0 \n',ind);
            
            % Make Experiment Folder
            expdname = makeExperimentFolder(EXPDIRNAME, PREFIX, ind);
            
            % Compute Parameters
               % fixed altitude
               % water depth is percentage of nadic optical path
               % gsd to texel ratio constant
               
            [xg,yg,footprint]=computeCameraPositions(iHfov,...
                jNOverlap,ALTITUDE,kwaterdepths); 
            zg = ones(size(xg))*ALTITUDE;
            
            texturescale = SCALEPAD * repmat(max(2*([max(xg(:)) max(yg(:))]+footprint/2)),1,2);
            
            % Make Sensor.xml
            writeSensor([EXPDIRNAME 'sensor_' sprintf('%.1f',iHfov)],...
                'sensorname',['overside' sprintf('%.1f',iHfov)],...
                'focallength',focallength,'resolution',[PIXX PIXY],...
                'sensorwidth',SENSORWIDTH,'principalpoint',[PIXX PIXY]/2);
            
            % Make Scene file 
            writeBathyScene([expdname 'input/scene_' sprintf('%03.0f.xml',ind)],...
                'bathytest',waterdepth,texturescale)

            % Make Trajectory file
            
            % Make metadata file
            makeMetaFile(expdname, iHfov, jNOverlap, kwaterdepths);
            
            % Make processing settings
            
        end
    end
end



end

function expdname = makeExperimentFolder(dname, prefix, ind)
    expdname = [dname prefix sprintf('%03f.0',ind)];
    mkdir(expdname);
    mkdir([expdname '/input']);
    mkdir([expdname '/raw']);
    mkdir([expdname '/proc']);
end

function makeMetaFile(expdname, iHfov, jNOverlap, kDepthPercent)
    fid = fopen([expdname '/input/meta.txt'],'w+t');
    fprintf(fid,'Experiment to determine effect of sidelap/overlap\n');
    fprintf(fid,'BathyTest Experiment Parameters\n');
    fprintf(fid,'HFOV       : %f\n',iHfov);
    fprintf(fid,'WaterDepthPercent : %.2f\n',kDepthPercent);
    fprintf(fid,'N Overlapping Images : %f\n',jNOverlap);
    fclose(fid);
end

function writeBathyScene(fname,name,waterdepth,scale)

fidRead = fopen('scene_bathyplaneTemplate.xml');
data = fread(fidRead,'*char');
fclose(fidRead);

data = strrep(data','\','\\')';

fid = fopen(fname,'w');
fprintf(fid,data,name,-waterdepth,scale);
fclose(fid);

end

function [xg,yg,footprint]=computeCameraPositions(hfov,noverlap,altitude,percentoverlap)
    [dx,footprint] = calcOverlapDistance(hfov,altitude,percentoverlap);
    
    ni = (1:noverlap)-mean(1:noverlap);
    
    [xg,yg]=meshgrid(ni*dx,ni*dx);
    
end