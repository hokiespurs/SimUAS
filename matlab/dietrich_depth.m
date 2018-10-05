function znew = dietrich_depth(lasname,waterlevel,trajname,sensorname)
%% apply dietrich depth corrections

%% Constants
IOR = 1.33;
NSKIP = 1;
DODEBUG = false;
UPDATESTATUS = 100;
%%
laspts = lasdata(lasname);
xyz = [laspts.x laspts.y laspts.z];

cameras = readCameras(trajname);
sensor = readSensor(sensorname);

npoints = size(xyz,1);
ncameras = numel(cameras);

%% convert each point into depth
h_a = waterlevel-xyz(:,3);

%% Plot Cameras and Pointcloud
if DODEBUG
    figure(100);clf;
    for jcamera = 1:ncameras
        iK = sensor.K;
        iR = cameras(jcamera).R;
        iT = cameras(jcamera).T;
        pixx = sensor.pixx;
        pixy = sensor.pixy;
        plotCameraPyramid(iK,iR,iT,[pixx pixy],'s',10,...
            'optPatch',{'FaceColor',uint8(rand(3,1)*255)},...
            'optLine',{'LineWidth',1,'Color','k'});
        axis equal
    end
    scatter3(xyz(1:NSKIP:end,1),xyz(1:NSKIP:end,2),xyz(1:NSKIP:end,3),5,-h_a(1:NSKIP:end),'filled');
    caxis([nanmean(-h_a(1:NSKIP:end))-2*nanstd(-h_a(1:NSKIP:end)) nanmean(-h_a(1:NSKIP:end))+2*nanstd(-h_a(1:NSKIP:end))]);
    colorbar
    axis equal;
    grid on
    drawnow
end

%%
zNew = nan(npoints,1);
ncams = nan(npoints,1);
% For each point
starttime = now;
for ipoint = 1:NSKIP:npoints
    if h_a(ipoint)>0 % point is below water
        Zcorr = nan(ncameras,1);
        elevationangle = nan(ncameras,1);
        for jcamera = 1:ncameras
            iK = sensor.K;
            iR = cameras(jcamera).R;
            iT = cameras(jcamera).T;
            pixx = sensor.pixx;
            pixy = sensor.pixy;
            
            [~,~,~,isinframe]=isXYZinFrame(iK,iR,iT,xyz(ipoint,1),xyz(ipoint,2),xyz(ipoint,3),pixx,pixy);
            if isinframe %if camera sees the point
                % Compute angle relative to flat water (az-el)
                D = sqrt((cameras(jcamera).T(1)-xyz(ipoint,1))^2+(cameras(jcamera).T(2)-xyz(ipoint,2))^2);
                dH = cameras(jcamera).T(3)-xyz(ipoint,3);
                
                r = atan2(D,dH);
                
                elevationangle(jcamera)=r*180/pi; % just for debugging
                
                i = asin(1/IOR*sin(r));
                
                x = h_a(ipoint) * tan(r);
                
                h = x/tan(i);
                
                % Calculate Z_corr
                Zcorr(jcamera) = waterlevel - h;
            end
        end
    % average Z_corr
    zNew(ipoint) = nanmean(Zcorr);
    ncams(ipoint) = sum(~isnan(Zcorr));
    else
        zNew(ipoint)=waterlevel - h_a(ipoint);
        ncams(ipoint)=0;
    end
    loopStatus(starttime,ipoint,npoints,UPDATESTATUS);
end

if DODEBUG
    %%
    x = xyz(1:NSKIP:end,1)-min(xyz(1:NSKIP:end,1));
    y = xyz(1:NSKIP:end,2)-min(xyz(1:NSKIP:end,2));
    
    rawdepth = h_a(1:NSKIP:end);
    newdepth = waterlevel-zNew(1:NSKIP:end);
    depthchange = newdepth-rawdepth;
    ratio = newdepth./rawdepth;
    nviews = ncams(1:NSKIP:end);
    
    indgood = (rawdepth>0);
    x = x(indgood);
    y = y(indgood);
    rawdepth = rawdepth(indgood);
    depthchange = depthchange(indgood);
    ratio = ratio(indgood);
    nviews = nviews(indgood);
    
    figure(101);clf
    subplot(2,2,1);% raw depth
    scatter(x,y,5,rawdepth,'filled');
    title('Raw SfM Depth','interpreter','latex','fontsize',20);
    xlabel('Relative Easting(m)','interpreter','latex','fontsize',18);
    ylabel('Relative Northing(m)','interpreter','latex','fontsize',18);
    
    axis equal
    caxis([0 nanmean(rawdepth) + 2*nanstd(rawdepth)]);
    colorbar
    grid on
    
    subplot(2,2,2);% old depth - new depth
    scatter(x,y,5,depthchange,'filled');
    title('Dietrich Depth Difference','interpreter','latex','fontsize',20);
    xlabel('Relative Easting(m)','interpreter','latex','fontsize',18);
    ylabel('Relative Northing(m)','interpreter','latex','fontsize',18);

    axis equal
    caxis([0 nanmean(depthchange)+2*nanstd(depthchange)]);
    colorbar
    grid on
    
    subplot(2,2,3);%ratio
    scatter(x,y,5,ratio,'filled');
    title('Dietrich Depth Ratio','interpreter','latex','fontsize',20);
    xlabel('Relative Easting(m)','interpreter','latex','fontsize',18);
    ylabel('Relative Northing(m)','interpreter','latex','fontsize',18);
    axis equal
    caxis([nanmean(ratio)-2*nanstd(ratio) nanmean(ratio)+2*nanstd(ratio)]);
    colorbar
    grid on
    
    subplot(2,2,4);%nCams
    scatter(x,y,5,nviews,'filled');
    title('Number of Cameras Per Point','interpreter','latex','fontsize',20);
    xlabel('Relative Easting(m)','interpreter','latex','fontsize',18);
    ylabel('Relative Northing(m)','interpreter','latex','fontsize',18);
    axis equal
    caxis([nanmean(nviews)-2*nanstd(nviews) nanmean(nviews)+2*nanstd(nviews)]);
    colorbar
    grid on
    
end

end

function sensor = readSensor(fname)
% read sensor K parameters and pixx and pixy
rawdat = xml2struct(fname);
f = getsensorval(rawdat.calibration,'f',0);
cx = getsensorval(rawdat.calibration,'cx',0);
cy = getsensorval(rawdat.calibration,'cy',0);
sensor.pixx = getsensorval(rawdat.calibration,'width',0);
sensor.pixy = getsensorval(rawdat.calibration,'height',0);
sensor.K = [f 0 sensor.pixx/2+cx;0 f sensor.pixy/2+cy;0 0 1];

end

function val = getsensorval(calibration,strval,defaultval)

if isfield(calibration,strval)
    valtext = getfield(calibration,strval);
    val = str2double(valtext.Text);
else
    val = defaultval;
end

end

function cameras = readCameras(fname)
rawdata = importdata(fname);
for i=1:size(rawdata.data,1)
    cameras(i).name = rawdata.textdata(2+i,1);
    cameras(i).T = rawdata.data(i,1:3)';
    R = reshape(rawdata.data(i,7:end),3,3)';
    cameras(i).R = diag([1, -1, -1]) * R;
end

end

