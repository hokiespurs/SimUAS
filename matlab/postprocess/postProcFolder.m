function postProcFolder(foldername, doexit)
tic
dbstop if error
addHomePath('SimUAS')
hpath = getHomePath('SimUAS');
foldername = [hpath '/' foldername];
if nargin==1
   doexit = 0; 
end
if ~exist([foldername '/output/'],'dir')
    fprintf('%s\n',[foldername '/output']);
    error( '''Output'' Folder does not exist')
end
%% paths to folders
imDir = [foldername '/output/images/pre'];
outImDir = [foldername '/output/images'];
trajectoryFilename = [foldername '/output/trajectory.csv'];
fiducialFilename = [foldername '/output/xyzfiducial.csv'];
fiducialSavename = [foldername '/output/pixelfiducial.xml'];
controlFilename = [foldername '/output/xyzcontrol.csv'];
controlSavename = [foldername '/output/pixelcontrol.xml'];
intrinsicFilename = [foldername '/output/sensor.xml'];
logFilename = [foldername '/output/log/renderblender.log'];
proctimeFilename = [foldername '/output/log/processingTime.txt'];
foo = dirname([foldername '/input/sensor*.xml']);
inputSensorFilename = foo{1};

%% read input data
Trajectory = readtrajectory(trajectoryFilename);
Fiducials = readfiducials(fiducialFilename);
Control = readcontrol(controlFilename);
Calibration = readsensor(intrinsicFilename, inputSensorFilename);

%% Add Distortion to all Images
if isDistortion(Calibration)
    distortImagesInFolder(imDir, outImDir, Calibration)
else
    copyImages(imDir,outImDir);
end
%% Crop image if need be
cropImagesInFolder(outImDir, Calibration);

%% Add Noise and Blur to Images
addNoiseAndBlurFolder(outImDir, Calibration)

%% Calculate Pixel Coords for Control + Save pixelControl.xml
savePixelXML(controlSavename, Trajectory, Control, Calibration);

%% Calculate Pixel Coords for Fiducial + Save pixelFiducial.xml
savePixelXML(fiducialSavename, Trajectory, Fiducials, Calibration);

%% Write processing time
tblender = calcproctime(logFilename);
tmatlab = toc;
writeproctime(proctimeFilename,tblender,tmatlab);

%% Make proc folder structure
mkdir([foldername '/proc']);

mkdir([foldername '/proc/parameters']);
mkdir([foldername '/proc/parameters/sensor']);
mkdir([foldername '/proc/parameters/control']);
mkdir([foldername '/proc/parameters/pix']);
mkdir([foldername '/proc/parameters/trajectory']);

mkdir([foldername '/proc/settings']);

mkdir([foldername '/proc/results']);

%% Quit program
if doexit
   exit 
end
end

function writeproctime(fname,tblender,tmatlab)
fid = fopen(fname,'w+t');
[HH,MM,SS,dd] = calchms(tblender);
fprintf(fid,'Blender Time : %5.0f days %2.0f hours %2.0f minutes %5.3f seconds\n',dd,HH,MM,SS);
[HH,MM,SS,dd] = calchms(tmatlab);
fprintf(fid,'Matlab Time  : %5.0f days %2.0f hours %2.0f minutes %5.3f seconds\n',dd,HH,MM,SS);
fclose(fid);
end

function tblender = calcproctime(fname)
strstart = '] run: logger opened';
a = importdata(fname);
t = cellfun(@(x) datenum(x(2:24),'yyyy-mm-dd HH:MM:SS,fff'),a);
isstart = cellfun(@(x) strcmp(x(25:end),strstart),a);
ind = find(isstart,1,'last');
if isempty(ind)
    tblender = nan;
else
    tblender = t(end)-t(ind);
end
tblender = tblender * 24*60*60; %convert to seconds
end

function [HH,MM,SS,dd] = calchms(tseconds)
%% Calculate time in seconds to HMS and Days

dd = mod(floor(tseconds/(24*60*60)),0);
HH = mod(floor(tseconds/(60*60)),24);
MM = mod(floor(tseconds/(60)),60);
SS = mod(tseconds,60);

end

function copyImages(imDir, outImDir)
fprintf('No Distortion... Copying Files\n');
imNames = dirname([imDir '/*.png']);
for i = 1:numel(imNames)
    iName = imNames{i};
    [~,fname,ext] = fileparts(iName);
    fprintf('Copying: %s\n',[fname ext])
    newName = [outImDir '/' fname ext];
    copyfile(iName,newName);
end
end

function flag = isDistortion(Calibration)
    isRadial = sum(Calibration.k == [0 0 0 0])<4;
    isTangential = sum(Calibration.p == [0 0])<2;
    flag = isRadial | isTangential;
end

function cropImagesInFolder(dname, Calibration)
imNames = dirname([dname '/*.png']);
I = imread(imNames{1});
[height,width,~]=size(I);

if height ~= Calibration.height || width ~= Calibration.width
    for i=1:numel(imNames)
       fprintf('Cropping: %s\n',imNames{i});
       I = imread(imNames{i});
       Itrim = trimimage(I, Calibration.width, Calibration.height);
       imwrite(Itrim, imNames{i})
    end
else
    fprintf('No Cropping Needed... pincushion or no distortion\n');
end


end

function Itrim = trimimage(I,x,y)
    [m,n,~]=size(I);
    padx = floor((n-x)/2); % best practice is to keep this whole numbers
    pady = floor((m-y)/2);
    
    Itrim = I;
    Itrim(1:pady,:,:)=[];
    Itrim(end-pady+1:end,:,:)=[];
    Itrim(:,1:padx,:)=[];
    Itrim(:,end-padx+1:end,:)=[];
end

function savePixelXML(fname, Trajectory, Markers, Calibration)
    MarkerStruct=[];
    for iMarker=1:numel(Markers.names)
        MarkerStruct{iMarker}.id = sprintf('%i',iMarker-1);
        MarkerStruct{iMarker}.name = Markers.names{iMarker};
        markT = Markers.T(iMarker,:);
        MarkerStruct{iMarker}.T = markT;

        for iCamera = 1:numel(Trajectory.names)
            MarkerStruct{iMarker}.Cam{iCamera}.id = sprintf('%i',iCamera-1);
            MarkerStruct{iMarker}.Cam{iCamera}.name = Trajectory.names{iCamera};
            camT = Trajectory.T(iCamera,:);
            camR = Trajectory.R(iCamera,:);
            [xy, inframe] = calcXYZtoPixel(markT, camT, camR, Calibration);
            MarkerStruct{iMarker}.Cam{iCamera}.xy = xy;
            MarkerStruct{iMarker}.Cam{iCamera}.inframe = inframe;
        end
    end
    %write out XML
    fid = fopen(fname, 'w+t');
    fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid,'<document version="1.2.0">\n');
    fprintf(fid,'  <chunk>\n');
    fprintf(fid,'    <sensors>\n');
    fprintf(fid,'      <sensor id="0" label="BlenderRender" type="frame">\n');
    h = sprintf('%i',Calibration.height);
    w = sprintf('%i',Calibration.width);
    fprintf(fid,['        <resolution width="' w '" height="' h '"/>\n']);
    fprintf(fid,'      </sensor>\n');
    fprintf(fid,'    </sensors>\n');
    fprintf(fid,'    <cameras>\n');
    for iCamera = 1:numel(Trajectory.names)
        id = sprintf('%i',iCamera-1);
        lbl = Trajectory.names{iCamera};
        fprintf(fid,['      <camera id="' id '" label="' lbl '" sensor_id="0"/>\n']);
    end
    fprintf(fid,'    </cameras>\n');
    fprintf(fid,'    <markers>\n');
    for iMarker=1:numel(Markers.names)
        id = sprintf('%i',iMarker-1);
        name = Markers.names{iMarker};
        fprintf(fid,['      <marker id="' id '" label="' name '">\n']);
        X = sprintf('%f',Markers.T(iMarker,1));
        Y = sprintf('%f',Markers.T(iMarker,2));
        Z = sprintf('%f',Markers.T(iMarker,3));
        fprintf(fid,['        <reference x="' X '" y="' Y '" z="' Z '" enabled="true"/>\n']);
        fprintf(fid,'      </marker>\n');
    end
    fprintf(fid,'    </markers>\n');
    fprintf(fid,'    <frames>\n');
    fprintf(fid,'      <frame id="0">\n');
    fprintf(fid,'        <markers>\n');
    for iMarker=1:numel(MarkerStruct)
        id = sprintf('%i',iMarker-1);
        fprintf(fid,['          <marker marker_id="' id '">\n']);
        for iCam = 1:numel(Trajectory.names)
            x = sprintf('%.3f',MarkerStruct{iMarker}.Cam{iCam}.xy(1));
            y = sprintf('%.3f',MarkerStruct{iMarker}.Cam{iCam}.xy(2));
            inframe = MarkerStruct{iMarker}.Cam{iCam}.inframe;
            camid = sprintf('%i',iCam-1);
            if inframe
                fprintf(fid,['            <location camera_id="' camid '" pinned="true" x="' x '" y="' y '" />\n']);
            end
        end
        fprintf(fid,'          </marker>\n');
    end
    fprintf(fid,'        </markers>\n');
    fprintf(fid,'      </frame>\n');
    fprintf(fid,'    </frames>\n');
    fprintf(fid,'  </chunk>\n');
    fprintf(fid,'</document>');
    
    fclose(fid);
end

function addNoiseAndBlurFolder(dname, Calibration)
imNames = dirname([dname '/*.png']);
    rng('default');
    rng(Calibration.seed)
    for i = 1:numel(imNames)
        iName = imNames{i};
        I = imread(iName);
        fprintf('Adding Noise/Blur/etc to Image %i...%s\n',i,datestr(now));
        Iraw = I; % for debugging
        [m,n,p]=size(I);
        
        % Add Gaussian Blur
        sigma = Calibration.postproc.gaussblur;
        if sigma>0
            I = imgaussfilt(I,sigma);
        end
        % Add Gaussian Noise
        gaussmean = Calibration.postproc.gaussnoise.mean;
        gaussvar = Calibration.postproc.gaussnoise.var;
        if gaussmean ~=0 && gaussvar ~= 0
            I = imnoise(I, 'gauss',gaussmean,gaussvar);
        end
        % Add Salt Noise
        saltprob = Calibration.postproc.saltnoise;
        
        noise = rand(m,n);
        noise = repmat(noise,[1,1,p]);
        I(noise<saltprob)=255;
        
        % Add Pepper Noise
        pepperprob = Calibration.postproc.peppernoise;
        
        noise = rand(m,n);
        noise = repmat(noise,[1,1,p]);
        I(noise<pepperprob)=0;        
        
        % Add Vignetting
        [xu,yu]=meshgrid(1:n,1:m);
        xc = Calibration.cx;
        yc = Calibration.cy;
        r = sqrt((xu - xc) .^ 2 + (yu - yc) .^ 2);
        v = Calibration.postproc.vignetting;
        maxI = double(cast(inf,class(I)));
        v = v./[1 max(r(:)) max(r(:)).^2].*[1 maxI maxI];
        dI = v(1) + v(2)*r + v(3)*r.^2;
        
        dI = repmat(dI,[1,1,p]);
        
        I = double(I)-dI;
        I = cast(I,class(Iraw)); %ensure I is same type
                
        %write out new image
        imwrite(I,iName);
    end

end

function distortImagesInFolder(imDir, outDir, Calibration)
imNames = dirname([imDir '/*.png']);
fprintf('Generating Image Map for Distortion...%s\n',datestr(now));
I = imread(imNames{1});
[height,width,~]=size(I);
newMap = calcImageMap(Calibration, height, width);

for i = 1:numel(imNames)
    iName = imNames{i};
    [~,fname,ext] = fileparts(iName);
    fprintf(['Distorting : ' fname ext '...' datestr(now) '\n']) 
    newName = [outDir '/' fname ext];
    
    distortImage(iName, newName, newMap);
end

end

function newMap = calcImageMap(Calibration, height, width)
    
    m = height;
    n = width;
    
    [xu, yu] = meshgrid(1:n,1:m);
    xc = Calibration.cx + (n - Calibration.width)/2;
    yc = Calibration.cy + (m - Calibration.height)/2;
    k = Calibration.k;
    f = Calibration.fx;
    k = k./([f^2 f^4 f^6 f^8]);
    p = Calibration.p./f;
    % Distort Coordinates
    [xd, yd] = calcDistortedCoords(xu, yu, xc, yc, k, p);
    
    dx = xd-xu;
    dy = yd-yu;

    dx_backwards = roundgridfun(xd,yd,dx,xu,yu,@mean);
    dx_backwardsInterp = interpNan(dx_backwards);
    dy_backwards = roundgridfun(xd,yd,dy,xu,yu,@mean);
    dy_backwardsInterp = interpNan(dy_backwards);

    x_pixmap = xu - dx_backwardsInterp;
    x_pixmap(isnan(x_pixmap)) = -1;
    y_pixmap = yu - dy_backwardsInterp;
    y_pixmap(isnan(y_pixmap)) = -1;

    % Do Image Mapping
    newMap = cat(3,x_pixmap,y_pixmap);
    
end

function distortImage(iName, newName, newMap)
    I = imread(iName);
    resamp = makeresampler('linear','fill');

    Idistorted = tformarray(I,[],resamp,[2 1],[1 2],[],newMap,[]);
    
    imwrite(Idistorted,newName);
end
function addHomePath(flag)
homePath = getHomePath(flag);
addpath(genpath([homePath '/matlab']))
end

function homePath = getHomePath(flag)

curpath = pwd;
foldername = 1;
while ~isempty(foldername)
   [dirname, foldername, ~] = fileparts(curpath);
   if strcmp(foldername, flag)
      homePath = [dirname '/' foldername];
      break
   end
   curpath = dirname;
end
if isempty(foldername)
   error('cant find home path'); 
end
end