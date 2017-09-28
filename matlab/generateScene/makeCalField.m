%% make calfield
FNAME = 'C:\Users\slocumr.ONID\github\SimUAS\data\calfield\input\scene_calfield.xml';
SHAPESCALE = [0.02 0.05 0.1 0.2 0.4 0.6 0.8 1 2];
PIPEDIAM = [0.05 0.1 0.2 0.4 0.6 0.8 1];
GCPS = [0.05 0.1 0.25 0.5 1];
TRIBARS = fliplr([0.01 0.02 0.03 0.04 0.05 0.075 0.1 0.2]);
WIRES = 0.005:0.005:0.05;

%%
clc

z = zeros(size(SHAPESCALE));
p = zeros(size(SHAPESCALE));

for i=2:numel(SHAPESCALE)
    p(i) = SHAPESCALE(i)./tand(30) + SHAPESCALE(i)/2 + SHAPESCALE(i-1)/2;
end
xOff = round(cumsum(p),2);
ind = find(cumsum(p)>SHAPESCALE(end)/2,1);
yOff = round(SHAPESCALE(end)./tand(30) + SHAPESCALE(ind)/2 + SHAPESCALE(end)/2,2);
%% Open File
fid = fopen(FNAME,'w+t');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<scene name="calfield" objectdb="objects/beaverdb" version = "1.0">\n');
%% Make Plane
fprintf(fid,addObject(-10,0,0,0,0,0,60,50,50,'basic_plane','Plane',0));

%% Make Cube
fprintf(fid,addObject(xOff,z-yOff/2,z,z,z,z,SHAPESCALE,SHAPESCALE,SHAPESCALE,'basic_cube','Cube',0));

%% Make Cylinder
fprintf(fid,addObject(xOff(end)-xOff,z+yOff-yOff/2,z,z,z,z,SHAPESCALE,SHAPESCALE,SHAPESCALE,'basic_cylinder','Cylinder',0));

%% Make Pyramid
fprintf(fid,addObject(xOff,z+2*yOff-yOff/2,z,z,z,z,SHAPESCALE,SHAPESCALE,SHAPESCALE,'basic_pyramid','Pyramid',0));

%% Make Cone
fprintf(fid,addObject(xOff(end)-xOff,z-yOff-yOff/2,z,z,z,z,SHAPESCALE,SHAPESCALE,SHAPESCALE,'basic_cone','Cone',0));

%% Make SemiSphere
fprintf(fid,addObject(xOff,z-2*yOff-yOff/2,z-SHAPESCALE/2,z,z,z,SHAPESCALE,SHAPESCALE,SHAPESCALE,'basic_sphere','Sphere',0));

%% Make IcoSphere
fprintf(fid,addObject(xOff(end)-xOff,z+3*yOff-yOff/2,z-SHAPESCALE/2,z,z,z,SHAPESCALE,SHAPESCALE,SHAPESCALE,'basic_icosphere','Icosphere',0));

%% Make Pipes
pipelength = yOff*2;
pipeoff = round(SHAPESCALE(end)./tand(30) + PIPEDIAM(ind)/2 + SHAPESCALE(end)/2,2);
p2 = zeros(size(PIPEDIAM));
z2 = zeros(size(PIPEDIAM));
for i=2:numel(PIPEDIAM)
    p2(i) = PIPEDIAM(i)./tand(30) + PIPEDIAM(i)/2 + PIPEDIAM(i-1)/2;
end

pipexpos = -yOff - cumsum(p2);
pipeypos = z2 + yOff*1/2;
pipezpos = PIPEDIAM/2;
fprintf(fid,addObject(pipexpos,pipeypos,pipezpos,z2,z2+90,z2+90,PIPEDIAM,PIPEDIAM,z2+pipelength,'basic_cylinder','Pipe',0));

%% Make Wires
wirelength = 10;
wireypos = 2 * yOff - [0 cumsum(ones(size(WIRES(1:end-1))))*1];
wirexpos = pipexpos(end) - PIPEDIAM(end)*2 - zeros(size(wireypos));
z = zeros(size(wireypos));
fprintf(fid,addObject(wirexpos,wireypos,z-0.05,z,z+60,z+180,WIRES,WIRES,z+wirelength,'basic_cylinder','wire',0));

%% Make GCPs
gcpx = -yOff - cumsum(GCPS) -5;
z = zeros(size(gcpx));
gcpy = zeros(size(gcpx))-1.5;
gcpz = zeros(size(gcpx))+0.01;
fprintf(fid,addObject(gcpx,gcpy,gcpz,z,z,z,GCPS,GCPS,GCPS,'control_checker','GCP',0));

%% Make Tribar
tribarx = -6 - cumsum(TRIBARS*7)*2;
z = zeros(size(tribarx));
tribary = zeros(size(tribarx));
tribarz = zeros(size(tribarx))+0.01;
fprintf(fid,addObject(tribarx,tribary,tribarz,z,z,z+90,TRIBARS,TRIBARS,TRIBARS,'calibration_tribar2','tribar',0));

%% Make Seimens
fprintf(fid,addObject(-6,0,0.01,0,0,0,3,3,3,'calibration_seimens','seimens',0));

%% Make Splash
splashscale = 2*yOff;
splashx = -yOff-splashscale/2;
splashy = yOff*-3/2;
fprintf(fid,addObject(splashx,splashy,0,0,0,0,splashscale,splashscale,splashscale,'splash','Splash',0));

%% Close File
fprintf(fid,'</scene>\n');
fclose(fid);
