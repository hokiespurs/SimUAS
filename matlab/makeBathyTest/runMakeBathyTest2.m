function runMakeBathyTest
%% CONSTANTS
EXPDIRNAME = 'F:\bathytestdata2';

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
ratioval = [0.01 0.05:0.05:0.5];
altvals = 50;
depthvals = ratioval*altvals;
hfovvals = [30:10:120];
for i=1:numel(depthvals)
    for j=1:numel(altvals)
        for k = 1:numel(hfovvals)
            EXPDATA = [EXPDATA;depthvals(i) altvals(j) hfovvals(k)];
        end
    end
end

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
%     if strcmp(messageid, 'MATLAB:MKDIR:DirectoryExists')
%         error('going to be overwriting things: delete yoself...'); 
%     end
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
    %% Make processing Settings
  % 3 trajectory position accuracy [0.01,0.5,10]
  % 3 camera calibration [loaded + lock, loaded + unlock, unloaded + unlock]
  % 2 optimization [f,cx,cy,k1,k2,k3,p1,p2] , [f,cx,cy,k1,k2,k3,p1,p2,b1,b2]
    
    DNAME = sprintf('%s/BATHY%03.0f/proc/settings/',EXPDIRNAME,iExperimentNum);
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
                    'reprocmvsfilt','0000');
                fprintf('%i:posacc: %05.2f - camcal %i - optim %i\n',iProcNum,camacc(iCamAcc),jCamCal,koptim)
            end
        end
    end
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


