function runMakeBathyTest
%% CONSTANTS
EXPDIRNAME = 'C:/Users/slocumr.ONID/github/SimUAS/data/bathytest';

NEXPERIMENTS = 100;

HFOVRANGE = [5 160];
ALTRANGE = [1 100];
DEPTHRANGE = [0.01 15];

OVERLAP = 0.8;
SIDELAP = 0.8;

SENSORWIDTH = 20;

PIXX = 2000;
PIXY = 2000;

EXPSCALE = 1/100;

%%
randbetween = @(nreturn,lim) rand(nreturn,1)*(lim(2)-lim(1))+lim(1);
%%
for iExperimentNum = 1:NEXPERIMENTS
%% 
% Independent Variables
    hfov = round(randbetween(1,HFOVRANGE),2);
    alt = round(randbetween(1,ALTRANGE),0);
    waterdepth = round(randbetween(1,DEPTHRANGE),1);   
% Dependent Variables 
    focallength = round(SENSORWIDTH/(2*tand(hfov/2)),3);
    
    hfov = calcfov(SENSORWIDTH,focallength);
    vfov = hfov*PIXY/PIXX; %assume square pixels
    
    footprint = [2*alt*tand(hfov/2) 2*alt*tand(vfov/2)];
    
    d = footprint.*[1-SIDELAP 1-OVERLAP];
    
    lineinds = ceil(round(footprint./d,10));
    
    [xg,yg] = meshgrid((-lineinds(1):lineinds(1))*d(1),(-lineinds(2):lineinds(2))*d(2));
    
    %how big to make the plane with texture
    scale = 1.1 * repmat(max(2*([max(xg(:)) max(yg(:))]+footprint/2)),1,2);

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
        warning('going to be overwriting things: Change to error...'); 
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
    fprintf(fid,'WaterDepth (%.2f,%.2f) : %f\n',DEPTHRANGE,waterdepth);
    fprintf(fid,'Altitude   (%.2f,%.2f) : %f\n',ALTRANGE,alt(1));
    fprintf(fid,'HFOV       (%.2f,%.2f) : %f\n',HFOVRANGE,hfov);
    fprintf(fid,'Overlap     : %f\n',OVERLAP);
    fprintf(fid,'Sidelap     : %f\n',SIDELAP);
    fprintf(fid,'SensorWidth : %f\n',SENSORWIDTH);
    fprintf(fid,'Resolution  : %.0fx%.0f\n',PIXX,PIXY);
    fprintf(fid,'FocalLength : %f\n',focallength);
    fclose(fid);
    
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


