function procBathyTest
close all
foldername = 'F:\bathytestdata2';
[~, dnames] = dirname([foldername '/BATHY*']);

startTime = now;
%for each simulation
for i=1:numel(dnames)
    % read correct parameters
    [seafloor,camIO,camEO, Scene] = getTruth(dnames{i});
    % for each processing setting
    procsettingfiles = dirname('proc/settings/setting*.xml',0,dnames{i});
    for j=1:numel(procsettingfiles)
        % read settings
        procsetting = xml2struct(procsettingfiles{j});
        d = fileparts(procsettingfiles{j});
        outfolder = [d '/' procsetting.procsettings.export.Attributes.rootname];
        % see if it exists
        sparsename = [outfolder '/sparse.las'];
        densename = [outfolder '/dense.las'];
        trajname = [outfolder '/trajectory.xml'];
        IOname = [outfolder '/sensorcalib.xml'];
        if exist(sparsename)
            fprintf('Processing: %s%02.0f\n',[dnames{i} '\setting'],j);
            % read/process sparse/dense pointclouds
            sparse=calcpointcloudstats(sparsename, seafloor, Scene, camEO.traj);
            dense=calcpointcloudstats(densename, seafloor, Scene,  camEO.traj);
            
            % read and compare camera positions
            cams = calccamstats(trajname,camEO);
            
            % read and compare interior orientation
            IOstats = calcIOstats(IOname,camIO);
            
            %consolidate useful data into structure
            testdata.truedepth = seafloor;
            testdata.altitude  = camEO.alt;
            testdata.hfov      = camIO.hfov;
            testdata.accuracy  = nanmean(sparse.grid.zgmean(:));
            posaccsettings = [0.01 0.5 10];
            testdata.poscamacc = posaccsettings(mod(j-1,3)+1);
%             testdata.lockIO = any(j==[1,6,11]);
%             testdata.loadIO = any(j==[1,2,3,6,7,8,11,12,13]);
%             testdata.solveb1b2 = any(j==[3,5,8,10,13,15]);
            testdata.lockIO = true;
            testdata.loadIO = true;
            testdata.solveb1b2 = false;
            
            % save output to folder
            if ~exist([outfolder '/matlab'],'dir')
                mkdir([outfolder '/matlab'])
            end
            
            save([outfolder '/matlab/results.mat'],...
                'sparse','dense','cams','IOstats','testdata');
            
            % make figures from sparse/dense
            f = makeFigs(sparse,dense,camEO,camIO,seafloor,j);
            saveas(f,[outfolder '/matlab/sparsedensepcolor.png']);
            clf;
            % make setting01/setting06/setting11 plots
            accuracy = nanmean(sparse.grid.zgmean(:));
            f2 = figure(100+j);
            set(f2,'Units','Normalize','Position',[0.05 0.05 0.9 0.9]);
            subplot 221
            plot(seafloor,accuracy,'b.');
            hold on
            xlabel('seafloor');
            ylabel('accuracy');
            
            subplot 222
            plot(testdata.altitude,accuracy,'b.');
            hold on
            xlabel('altitude');
            ylabel('accuracy');
            
            subplot 223
            plot(testdata.hfov,accuracy,'b.');
            hold on
            xlabel('hfov');
            ylabel('accuracy');
            
            subplot 224
            scatter(seafloor,testdata.altitude,100,accuracy,'filled');
            hold on
            colorbar
            xlabel('seafloor');
            ylabel('altitude');
        
        else
            fprintf('Fail      : %s%02.0f\n',[dnames{i} '\setting'],j);
        end
    end
    loopStatus(startTime,i,numel(dnames),1)
end

end

function f = makeFigs(sparse,dense,camEO,camIO,seafloor,settingnum)
f = figure(1);
set(f,'Units','Normalize','Position',[0.1 0.1 0.8 0.8]);

axg = axgrid(3,4,0.02,0.01,0.01,0.9,0.05,0.95);

dzsparse = nanmean(sparse.grid.zgmean(:));
stdsparse = nanstd(sparse.grid.zgmean(:));
dzdense = nanmean(dense.grid.zgmean(:));
CLIM = [dzsparse-stdsparse*3 dzsparse+stdsparse*3];
if any(isnan(CLIM))
   CLIM = [0 1]; 
end
makeSparseDensePC(sparse,axg,'Sparse',[1 5 9 2 6 10],CLIM)
makeSparseDensePC(dense,axg,'Dense',[3 7 11 4 8 12],CLIM)

bigtitle(['Sparse $\mu\Delta$Z=' sprintf('%.2fcm',dzsparse*100)],0.25,0.90,'interpreter','latex','fontsize',16);
bigtitle(['Dense $\mu\Delta$Z=' sprintf('%.2fcm',dzdense*100)],0.7,0.90,'interpreter','latex','fontsize',16);

bigtitle(sprintf('ALT:%.1fm',camEO.alt),0.1625,0.92,'interpreter','latex','fontsize',30);
bigtitle(sprintf('DEPTH:%.1fm',seafloor),0.3875,0.92,'interpreter','latex','fontsize',30);
bigtitle(sprintf('HFOV:%.1f',camIO.hfov),0.6125,0.92,'interpreter','latex','fontsize',30);
bigtitle(sprintf('SETTING:%02.0f',settingnum),0.8375,0.92,'interpreter','latex','fontsize',30);

end

function makeSparseDensePC(pc,axg,titlestr,inds,CLIM)

% mean
makePcolorPC(pc.grid.xg,pc.grid.yg,pc.grid.zgmean,...
    [titlestr ' mean'],axg,inds(1))
colorbar
caxis(CLIM)

% min
makePcolorPC(pc.grid.xg,pc.grid.yg,pc.grid.zgmin,...
    [titlestr ' min'],axg,inds(2))
colorbar
caxis(CLIM)

% max
makePcolorPC(pc.grid.xg,pc.grid.yg,pc.grid.zgmax,...
    [titlestr ' max'],axg,inds(3))
colorbar
caxis(CLIM)

% npts
makePcolorPC(pc.grid.xg,pc.grid.yg,pc.grid.npts,...
    [titlestr ' npts'],axg,inds(4))
colorbar
if strcmp(titlestr,'Sparse')
   caxis([0 10]) 
else
   caxis([200 300])
end
% median
makePcolorPC(pc.grid.xg,pc.grid.yg,pc.grid.zgmedian,...
    [titlestr ' median'],axg,inds(5))
colorbar
caxis(CLIM)

% variance
makePcolorPC(pc.grid.xg,pc.grid.yg,pc.grid.zgvar,...
    [titlestr ' variance'],axg,inds(6))
colorbar
caxis([0 1]*1e-3)

end

function makePcolorPC(xg,yg,zg,titlestr,axg,axnum)
axg(axnum);
pcolor(xg,yg,zg);shading flat
title(titlestr,'interpreter','latex','fontsize',14);
set(gca,'ytick','','xtick','');
axis equal
drawnow
end

function IOstats = calcIOstats(IOname,camIO)

calcIO = xml2struct(IOname);
calcIO = calcIO.calibration;

trueIO = camIO.xml;
trueIO = trueIO.calibration;

vars = {'f','cx','cy','k1','k2','k3','p1','p2','b1','b2'};

for i=1:numel(vars)
   if isfield(calcIO,vars{i}) && isfield(trueIO,vars{i})
       IOstats.(vars{i}) = str2double(calcIO.(vars{i}).Text)-str2double(trueIO.(vars{i}).Text);
   else
       IOstats.(vars{i}) = nan; 
   end
end

end

function [seafloor, camIO, camEO, Scene]=getTruth(dname)
% meta txt file
fid = fopen([dname '/input/meta.txt'],'r');
fgetl(fid);
fgetl(fid);
seafloor          = sscanf(fgetl(fid),'WaterDepth : %f');
camEO.alt         = sscanf(fgetl(fid),'Altitude   : %f');
camIO.hfov        = sscanf(fgetl(fid),'HFOV       : %f');
camEO.overlap     = sscanf(fgetl(fid),'Overlap     : %f');
camEO.sidelap     = sscanf(fgetl(fid),'Sidelap     : %f');
camIO.sensorWidth = sscanf(fgetl(fid),'SensorWidth : %f');
camIO.resolution  = sscanf(fgetl(fid),'Resolution  : %fx%f');
camIO.focallength = sscanf(fgetl(fid),'FocalLength : %f');
fclose(fid);

% sensor file
xmlname = dirname([dname '/output/Sensor_photoscan.xml']);
camIO.xml = xml2struct(xmlname{1});

% scene to get xy scale
xmlname = dirname([dname '/input/scene*']);
Scene = xml2struct(xmlname{1});

% traj to get camEO positions
xmlname = dirname([dname '/input/traj*']);
camEO.traj = xml2struct(xmlname{1});

end

function data = calcpointcloudstats(lasname,seafloor, Scene, Traj)
boxscale  = str2double(Scene.scene.object{2}.position.scale.Attributes.x)/2;
camaoi = str2double(Traj.trajectory.pose{1}.translation.Attributes.x);
if exist(lasname,'file')
    dat = lasdata(lasname);
    inaoi = dat.x>camaoi & dat.x<-camaoi & dat.y>camaoi & dat.y<-camaoi;
    inaoiTight = dat.x>camaoi/2 & dat.x<-camaoi/2 & dat.y>camaoi/2 & dat.y<-camaoi/2;
    dz = dat.z+seafloor;
    data.RegionA = zstat(dz);
    data.RegionB  = zstat(dz(inaoi));
    data.RegionC = zstat(dz(inaoiTight));
    [xg,yg]=meshgrid(linspace(-boxscale,boxscale,100),linspace(-boxscale,boxscale,100));
    [zgmean,npts] = roundgridfun(dat.x,dat.y,dz,xg,yg,@mean);
    zgmin = roundgridfun(dat.x,dat.y,dz,xg,yg,@min);
    zgmax = roundgridfun(dat.x,dat.y,dz,xg,yg,@max);
    zgmedian = roundgridfun(dat.x,dat.y,dz,xg,yg,@median);
    zgvar = roundgridfun(dat.x,dat.y,dz,xg,yg,@var);

    data.grid.xg = xg;
    data.grid.yg = yg;
    data.grid.zgmean = zgmean;
    data.grid.npts = npts;
    data.grid.zgmin = zgmin;
    data.grid.zgmax = zgmax;
    data.grid.zgmedian = zgmedian;
    data.grid.zgvar = zgvar;
else
    data.RegionA = zstat(nan);
    data.RegionB = zstat(nan);
    data.RegionC = zstat(nan);
end

end

function cams = calccamstats(trajname,camEO)

calctraj = xml2struct(trajname);

S = str2double(calctraj.document.chunk.transform.scale.Text);
T = sscanf(calctraj.document.chunk.transform.translation.Text,'%f');
R = reshape(sscanf(calctraj.document.chunk.transform.rotation.Text,'%f'),3,3)';

ncams = numel(calctraj.document.chunk.cameras.camera);


for i=1:ncams
    try
        C = reshape(sscanf(calctraj.document.chunk.cameras.camera{i}.transform.Text,'%f'),4,4)';
        X = S * R * C(1:3,4) + T;
        camXYZ = [str2double(camEO.traj.trajectory.pose{i}.translation.Attributes.x),...
                  str2double(camEO.traj.trajectory.pose{i}.translation.Attributes.y),...
                  str2double(camEO.traj.trajectory.pose{i}.translation.Attributes.z)];
        cams.Toffset(i,:)=X-camXYZ';
    catch %camera wasnt placed
       cams.Toffset(i,:)=[nan nan nan]; 
    end
end

end

function s = zstat(z)
if ~isnan(z)
    HISTRANGE = -5:0.005:5;
    s.u = mean(z);
    s.v = var(z);
    s.r = [min(z) max(z)];
    s.med = median(z);
    s.h = roundgridfun(z,1:numel(z),HISTRANGE,@numel);
    s.hval = HISTRANGE;
    s.npts = numel(z);
else
    s.u = nan;
    s.v = nan;
    s.r = nan;
    s.med = nan;
    s.h = nan;
    s.npts = nan;
end

end