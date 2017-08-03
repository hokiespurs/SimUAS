function [footprint,d]=calcFootprint(sensorfile,alt,overlap,sidelap)

%% Read Sensor Data from File
indat = xml2struct(sensorfile);

sensorWidth = str2double(indat.sensor.physical.Attributes.sensorWidth);
focalLength = str2double(indat.sensor.physical.Attributes.focallength);
xpix = str2double(indat.sensor.resolution.Attributes.x);
ypix = str2double(indat.sensor.resolution.Attributes.y);

hfov = calcfov(sensorWidth,focalLength);
vfov = hfov * ypix/xpix;

xgsd = calcGSD(hfov,xpix,alt);
ygsd = calcGSD(vfov,ypix,alt);

footprint = [xgsd ygsd].*[xpix ypix];

d = footprint.*[1-sidelap 1-overlap];

end