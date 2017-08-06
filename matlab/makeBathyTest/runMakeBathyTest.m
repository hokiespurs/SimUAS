function runMakeBathyTest
%% CONSTANTS
EXPDIRNAME = 'C:/Users/slocumr.ONID/github/SimUAS/data/bathytest';

NEXPERIMENTS = 100;

% HFOVRANGE = [5 160];
% ALTRANGE = [1 100];
% DEPTHRANGE = [0.01 15];

OVERLAP = 0.8;
SIDELAP = 0.8;

SENSORWIDTH = 20;

PIXX = 2000;
PIXY = 2000;

EXPSCALE = 1;
SCALEPAD = 1.05;
%% Make Experiments
EXPDATA = [];
% sample across everything but altitude
depthvals = [0.05 0.1 0.5 1 2 5 10 25];
altvals = 50;
hfovvals = [30 50 60 70 80 90 100 120];
for i=1:numel(depthvals)
    for j=1:numel(altvals)
        for k = 1:numel(hfovvals)
            EXPDATA = [EXPDATA;depthvals(i) altvals(j) hfovvals(k)];
        end
    end
end
% match ratio for 70 degree and 20 alt
depthvals = [0.02 0.04 0.2 0.4 0.8 2 4 10];
altvals = 20;
hfovvals = 70;
for i=1:numel(depthvals)
    for j=1:numel(altvals)
        for k = 1:numel(hfovvals)
            EXPDATA = [EXPDATA;depthvals(i) altvals(j) hfovvals(k)];
        end
    end
end
% do fine resolution with 70 degree fov and 50m
depthvals = 0.25:0.25:10;
altvals = 50;
hfovvals = 70;
for i=1:numel(depthvals)
    for j=1:numel(altvals)
        for k = 1:numel(hfovvals)
            EXPDATA = [EXPDATA;depthvals(i) altvals(j) hfovvals(k)];
        end
    end
end

%%
randbetween = @(nreturn,lim) rand(nreturn,1)*(lim(2)-lim(1))+lim(1);
%%
NEXPERIMENTS = size(EXPDATA,1);
for iExperimentNum = 1:NEXPERIMENTS
%% 
% Independent Variables
%     hfov = round(randbetween(1,HFOVRANGE),2);
%     alt = round(randbetween(1,ALTRANGE),0);
%     waterdepth = round(randbetween(1,DEPTHRANGE),2);   
hfov = EXPDATA(iExperimentNum,3);
alt = EXPDATA(iExperimentNum,2);
waterdepth = EXPDATA(iExperimentNum,1);
% Dependent Variables 
    focallength = round(SENSORWIDTH/(2*tand(hfov/2)),3);
    
    hfov = calcfov(SENSORWIDTH,focallength);
    vfov = hfov*PIXY/PIXX; %assume square pixels
    
    footprint = [2*alt*tand(hfov/2) 2*alt*tand(vfov/2)];
    
    d = footprint.*[1-SIDELAP 1-OVERLAP];
    
    lineinds = ceil(round(footprint./d,10));
    
    [xg,yg] = meshgrid((-lineinds(1):lineinds(1))*d(1),(-lineinds(2):lineinds(2))*d(2));
    
    %how big to make the plane with texture
    scale = SCALEPAD * repmat(max(2*([max(xg(:)) max(yg(:))]+footprint/2)),1,2);

%     % Figure
%     clf
%     plot(xg,yg,'.-','markersize',50,'linewidth',2)
%     hold on
%     axis equal
%     ind = xg==0 & yg==0;
%     plotRect([xg(ind),yg(ind)],footprint/2,'linewidth',5,'color','k');
%     for i=1:numel(xg)
%        plotRect([xg(i),yg(i)],footprint/2,'color','k');
%     end

    %% SCALE THE EXPERIMENT DOWN
    xg = xg*EXPSCALE;
    yg = yg*EXPSCALE;
    alt = alt*EXPSCALE;
    scale = scale*EXPSCALE;
    waterdepth = waterdepth*EXPSCALE;

    %% Make Experiment Folder
    DNAME = sprintf('%s/BATHY%03.0f/input/',EXPDIRNAME,iExperimentNum);
    [status,message,messageid] =mkdir(DNAME);
    if strcmp(messageid, 'MATLAB:MKDIR:DirectoryExists')
        error('going to be overwriting things: delete yoself...'); 
    end
    FNAME = sprintf('bathytest%.0f.xml',iExperimentNum);
    %% Make Scene.xml
    writeBathyScene([DNAME 'scene_' FNAME],'bathytest',waterdepth,scale)

    %% Make Sensor.xml
    writeSensor([DNAME 'sensor_' FNAME],'sensorname','bathyimg',...
        'focallength',focallength,'resolution',[PIXX PIXY],...
        'sensorwidth',SENSORWIDTH,'principalpoint',[PIXX PIXY]/2);
    
    %% Make Trajectory.xml
    alt = ones(size(xg))*alt;
    R = zeros(size(xg));
    t = 1:numel(xg);
    writeTrajectory([DNAME 'trajectory_' FNAME],'bathytest',...
        xg(:),yg(:),alt(:),R(:),R(:),R(:),t,'img',4,0);    
    
    %% Make Metadata file
    fid = fopen([DNAME 'meta.txt'],'w+t');
    fprintf(fid,'BathyTest Experiment Parameters\n');
    fprintf(fid,'Experiment Number %.0f/%.0f\n',iExperimentNum,NEXPERIMENTS);
    fprintf(fid,'WaterDepth : %f\n',waterdepth);
    fprintf(fid,'Altitude   : %f\n',alt(1));
    fprintf(fid,'HFOV       : %f\n',hfov);
    fprintf(fid,'Overlap     : %f\n',OVERLAP);
    fprintf(fid,'Sidelap     : %f\n',SIDELAP);
    fprintf(fid,'SensorWidth : %f\n',SENSORWIDTH);
    fprintf(fid,'Resolution  : %.0fx%.0f\n',PIXX,PIXY);
    fprintf(fid,'FocalLength : %f\n',focallength);
    fclose(fid);
    %%
    altdepthratio(iExperimentNum)=(alt(1)+waterdepth)/waterdepth;
    allalt(iExperimentNum)=alt(1);
    alldepth(iExperimentNum)=waterdepth;
end

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


