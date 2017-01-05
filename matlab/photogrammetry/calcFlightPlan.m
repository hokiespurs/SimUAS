function [alt,gsd,doverlap,dsidelap]=calcFlightPlan(sensorfile,gsdoralt,sidelap,overlap,surveyregion,maketrajectory)
if nargin==4
    dosurveyregion = false;
else
    dosurveyregion = true;
end
if gsdoralt<2
    isalt = false;
else
    isalt = true;
end
if overlap<1
   isoverlappercent = true; 
else
   isoverlappercent = false;
end
if sidelap<1
   issidelappercent = true; 
else
   issidelappercent = false;
end


%% Read Sensor Data from File
indat = xml2struct(sensorfile);

sensorWidth = str2double(indat.sensor.physical.Attributes.sensorWidth);
focalLength = str2double(indat.sensor.physical.Attributes.focallength);
xpix = str2double(indat.sensor.resolution.Attributes.x);
ypix = str2double(indat.sensor.resolution.Attributes.y);

%% Calculate Altitude for GSD
hfov = calcfov(sensorWidth,focalLength);
vfov = hfov * ypix/xpix;
if isalt
    alt = gsdoralt;
    gsd = calcGSD(hfov,xpix,alt);
else
    alt = calcAltForGSD(hfov,xpix,gsdoralt);
    gsd = gsdoralt;
end
%% Calculate Overlap and Sidelap Distances
if isoverlappercent
    [doverlap, vwidth] = calcOverlapDistance(vfov,alt,overlap*100);
    overlapPercent = overlap*100;
else
    doverlap = overlap;
    overlapPercent = calcOverlapPercent(vfov,alt,overlap);
    vwidth = 2 * alt * tand(vfov/2);
end
if issidelappercent
    [dsidelap, hwidth] = calcOverlapDistance(hfov,alt,sidelap*100);
    sidelapPercent = sidelap * 100;
else
    dsidelap = sidelap;
    sidelapPercent = calcOverlapPercent(hfov,alt,sidelap);
    hwidth = 2 * alt * tand(hfov/2);
end



%% Calculate Survey Region
if dosurveyregion
    xmin = surveyregion(1);
    xmax = surveyregion(2);
    ymin = surveyregion(3);
    ymax = surveyregion(4);

    xi = xmin:dsidelap:xmax;
    yi = ymin:doverlap:ymax;
    
    [tx,ty]=meshgrid(xi,yi);
    tz = ones(size(tx))* alt;
    rx = zeros(size(tx));
    ry = zeros(size(tx));
    rz = zeros(size(tx));
    
    % ADD NOISEEEE
    tx = tx + randn(size(tx));
    ty = ty + randn(size(tx));
    tz = tz + randn(size(tx));
    rx = rx + 2*randn(size(tx));
    ry = ry + 2*randn(size(tx));
    rz = rz + 2*randn(size(tx));
    
    t = 1:numel(tx);
    clc
    fprintf('<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf('<trajectory name = "%s">\n','autogrid');
    for i=1:numel(tx)
        iName = ['IMG_' sprintf(['%0' sprintf('%.0f',4) '.0f'],i)];
        fprintf('\t<pose name = "%s" t = "%i">\n',iName, t(i));
        fprintf('\t\t<translation x = "%f" y = "%f" z = "%f" />\n',tx(i),ty(i),tz(i));
        fprintf('\t\t<rotation x = "%f" y = "%f" z = "%f" />\n',rx(i),ry(i),rz(i));
        fprintf('\t</pose>\n');
    end
    fprintf('</trajectory>\n');
    fprintf('\n----Survey Summary----\n');
    fprintf('\t N Flight Lines = %.0f \t (',numel(xi));
    fprintf('%.1f,',xi);
    fprintf(')\n');
    fprintf('\t pics per line  = %.0f \t (',numel(yi));
    fprintf('%.1f,',yi);
    fprintf(')\n');
    fprintf('\t Total Pictures = %.0f pictures \n',numel(xi) * numel(yi));
end
%% Print Summary
fprintf('----sensor----\n');
fprintf('\t hfov: %.1f degrees\n',hfov);
fprintf('\t vfov: %.1f degrees\n',vfov);
fprintf('\t hpix: %.0f\n',xpix);
fprintf('\t vpix: %.0f\n',ypix);
fprintf('----photogrammetry----\n');
fprintf('\t  alt: %.2fm\n',alt);
fprintf('\t  gsd: %.2fcm\n',gsd*100);
fprintf('footprint: %.1fm x %.1fm \t half: (%.1fm x %.1fm)\n',hwidth,vwidth,hwidth/2,vwidth/2);
fprintf(' doverlap: %.2fm \t = %.1f%%\n',doverlap,overlapPercent);
fprintf(' dsidelap: %.2fm \t = %.1f%%\n',dsidelap,sidelapPercent);

end