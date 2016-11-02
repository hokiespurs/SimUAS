function postProcFolder(foldername)
dbstop if error

%% paths to folders
imDir = [foldername '/output/images/pre'];
outImDir = [foldername '/output/images'];
trajectoryFilename = [foldername '/output/trajectory.csv'];
fiducialFilename = [foldername '/output/xyzfiducial.csv'];
fiducialSavename = [foldername '/output/pixelfiducial.xml'];
controlFilename = [foldername '/output/xyzcontrol.csv'];
controlSavename = [foldername '/output/pixelcontrol.xml'];
intrinsicFilename = [foldername '/output/sensor.xml'];
foo = dirname([foldername '/input/sensor*.xml']);
inputSensorFilename = foo{1};

%% read input data
Trajectory = readtrajectory(trajectoryFilename);
Fiducials = readfiducials(fiducialFilename);
Control = readcontrol(controlFilename);
Calibration = readsensor(intrinsicFilename, inputSensorFilename);

%% Add Distortion to all Images
distortImagesInFolder(imDir, outImDir, Calibration)

%% Crop image if need be
cropImagesInFolder(outImDir, Calibration);

%% Add Noise and Blur to Images
addNoiseAndBlurFolder(outImDir, Calibration)

%% Calculate Pixel Coords for Control + Save pixelControl.xml
savePixelXML(controlSavename, Trajectory, Control, Calibration);

%% Calculate Pixel Coords for Fiducial + Save pixelFiducial.xml
savePixelXML(fiducialSavename, Trajectory, Fiducials, Calibration);

end

function cropImagesInFolder(dname, Calibration)
imNames = dirname([dname '/*.png']);
I = imread(imNames{1});
[height,width,~]=size(I);

if height ~= Calibration.height || width ~= Calibration.width
    for i=1:numel(imNames)
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
    padx = (n-x)/2;
    pady = (m-y)/2;
    
    Itrim = I;
    Itrim(1:pady,:,:)=[];
    Itrim(end-pady+1:end,:,:)=[];
    Itrim(:,1:padx,:)=[];
    Itrim(:,end-padx+1:end,:)=[];
end

function savePixelXML(fname, Trajectory, Markers, Calibration)

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

function [xy, inframe] = calcXYZtoPixel(markT, camT, camR, Calibration)
    fx = Calibration.fx;
    fy = Calibration.fy;
    cx = Calibration.cx;
    cy = Calibration.cy;
    k = Calibration.k;
    p = Calibration.p;
    f = Calibration.fx;
    k = k./([f^2 f^4 f^6 f^8]);
    p = Calibration.p./f^2;
    
    camR = camR*pi/180;

    Rblender = makehgtform('zrotate',camR(3),...
                'yrotate',camR(2),...
                'xrotate',camR(1));
    Rblender2photogrammetry = diag([1 -1 -1 1]);

    R = Rblender * Rblender2photogrammetry;
    R = R(1:3,1:3);

    RT = inv([(R) camT';0 0 0 1]);
    RT = RT(1:3,:);
    
    K = [fx 0 cx; 0 fy cy; 0 0 1];

    xyz1 = [markT'; ones(1,size(markT,1))];

    uvs = K * RT * xyz1;

    s = uvs(3,:);
    u = uvs(1,:)./s;
    v = uvs(2,:)./s;

    [x, y] = calcDistortedCoords(u, v, cx, cy, k, p);
    
    inframePre = u>0 & v>0 & u<Calibration.width & v<Calibration.height;
    inframePost = s>0 & x>0 & y>0 & x<Calibration.width & y<Calibration.height;
    inframe = inframePre & inframePost;
    
    if inframe
        xy = [x y];
    else
        xy = [nan, nan];        
    end
    
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
fprintf('Generating Image Map...%s\n',datestr(now));
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
    p = Calibration.p./f^2;
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

function [xd, yd] = calcDistortedCoords(xu, yu, xc, yc, k, p)
    % radial distortion
    r = sqrt((xu - xc) .^ 2 + (yu - yc) .^ 2);
    dx_radial = (xu - xc) .* (1 + (k(1) .* r .^ 2) + (k(2) .* r .^ 4) + (k(3) .* r .^ 6) + (k(4) .* r .^ 8));
    dy_radial = (yu - yc) .* (1 + (k(1) .* r .^ 2) + (k(2) .* r .^ 4) + (k(3) .* r .^ 6) + (k(4) .* r .^ 8));

    % tangential distortion
    dx_tangential = (p(1) .* (r.^2 + 2*(xu - xc).^2) + 2 .* p(2) .* (xu - xc) .* (yu - yc));
    dy_tangential = (p(2) .* (r.^2 + 2*(yu - yc).^2) + 2 .* p(1) .* (xu - xc) .* (yu - yc));

    % calculate distorted coordinate
    xd = xc + dx_radial + dx_tangential;
    yd = yc + dy_radial + dy_tangential;

end

function Trajectory = readtrajectory(fname)
rawdata = importdata(fname);
Trajectory.names = rawdata.textdata(2:end,1);
Trajectory.T = rawdata.data(:,1:3);
Trajectory.R = rawdata.data(:,4:6);

end

function Fiducials = readfiducials(fname)
rawdata = importdata(fname);
Fiducials.names = rawdata.textdata(2:end,1);
Fiducials.T = rawdata.data(:,1:3);
end

function Control = readcontrol(fname)
rawdata = importdata(fname);
if isstruct(rawdata)
    Control.names = rawdata.textdata(2:end,1);
    Control.T = rawdata.data(:,1:3);
else
    Control.names{1} = '';
    Control.T = [0 0 0];
    error('why did this happen?')
end
end

function Cal = readsensor(outsensor, insensor)
    indata = xml2struct(insensor);
    outdata = xml2struct(outsensor);
    oc = outdata.calibration;
    isp = indata.sensor.postprocessing;
    
    Cal.width = str2double(oc.width.Text);
    Cal.height = str2double(oc.height.Text);
    Cal.fx = str2double(oc.f.Text);
    Cal.fy = str2double(oc.f.Text);
    Cal.cx = str2double(oc.cx.Text);
    Cal.cy = str2double(oc.cy.Text);
    Cal.k = [str2double(oc.k1.Text),...
                     str2double(oc.k2.Text),...
                     str2double(oc.k3.Text),...
                     str2double(oc.k4.Text)];
    Cal.p = [str2double(oc.p1.Text),...
                     str2double(oc.p2.Text)];
    
    Cal.postproc.vignetting = [str2double(isp.vignetting.Attributes.v1),...
                             str2double(isp.vignetting.Attributes.v2),...
                             str2double(isp.vignetting.Attributes.v3)];
    Cal.postproc.saltnoise = str2double(isp.saltnoise.Attributes.prob);
    Cal.postproc.peppernoise = str2double(isp.peppernoise.Attributes.prob);
    Cal.postproc.gaussnoise.mean = ...
        str2double(isp.gaussiannoise.Attributes.mean);
    Cal.postproc.gaussnoise.var = ...
        str2double(isp.gaussiannoise.Attributes.variance);
    Cal.postproc.gaussblur = str2double(isp.gaussianblur.Attributes.sigma); 
    Cal.seed = str2double(isp.Attributes.seed);
end

function imnames=dirname(foldername,returnFolders)
%% This function returns a cell array of files using the dir command
% This just makes it easier so you dont have to write a for loop to extract
% the filenames into a cell array
if nargin==1
    returnFolders=0;
end

fnames=dir(foldername);
[directortName,~,~]=fileparts(foldername);
imnames=[];
numgoodfiles=0;
for i=1:numel(fnames)
    if isdir([directortName '/' fnames(i).name]) && returnFolders && ~strcmp(fnames(i).name,'.') && ~strcmp(fnames(i).name,'..')
        numgoodfiles=numgoodfiles+1;
        imnames{numgoodfiles}=[directortName '/' fnames(i).name];
    elseif ~isdir([directortName '/' fnames(i).name]) && ~returnFolders
        numgoodfiles=numgoodfiles+1;
        imnames{numgoodfiles}=[directortName '/' fnames(i).name];
    end
end


end

function Y = interpNan(X)

[r,c]=size(X);
Xa = nan(size(X));
for i=1:r
    val = X(i,:);
    ind = find(~isnan(val));
    if numel(ind)>2
        Xa(i,:) = interp1(ind,val(ind),1:numel(val),'linear');
    end
end

Xb = nan(size(X));
for i=1:c
    val = X(:,i);
    ind = find(~isnan(val));
    if numel(ind)>2
        Xb(:,i) = interp1(ind,val(ind),1:numel(val),'linear');
    end
end

T = ~isnan(Xa)+~isnan(Xb);
Xa(isnan(Xa))=0;
Xb(isnan(Xb))=0;
Y = (Xa + Xb) ./ T;

end