
xi = -40:10:40;
yi = -40:10:40;
alt = 40;

[xg,yg]=meshgrid(xi,yi);

xg = xg + randn(size(xg))*1;
yg = yg + randn(size(xg))*1;
zg = alt*ones(size(xg))-randn(size(xg))*1;
rx = randn(size(xg))*1;
ry = randn(size(xg))*1;
rz = randn(size(xg))*1;
t = 1:numel(xg);

makeTrajectory('grid40.xml', 'TestTopoField', xg, yg, zg, rx, ry, rz, t, 'IMG', 4)

%%
NCAMS = 100;

iTheta = rand(NCAMS,1)*360;
iPhi = rand(NCAMS,1)*180;
iRoll = rand(NCAMS,1)*360;
iRange = rand(NCAMS,1)*0+5;

x = iRange .* sind(iPhi) .* cosd(iTheta);
y = iRange .* sind(iPhi) .* sind(iTheta);
z = iRange .* cosd(iPhi);

rx = zeros(size(x));
ry = iPhi;
rz = iTheta;

makeTrajectory('trajectory_Test2.xml', 'Test', x, y, z, rx, ry, rz, 'CenterPoint', 3)

%%
NCAMS = 100;

iTheta = rand(NCAMS,1)*360;
iPhi = rand(NCAMS,1)*180;
iRoll = rand(NCAMS,1)*360;

x = (rand(NCAMS,1)*8)-4;
y = (rand(NCAMS,1)*8)-4;
z = (rand(NCAMS,1)*8)-4;

rx = iRoll;
ry = iPhi;
rz = iTheta;
t = 1:NCAMS;
makeTrajectory('trajectory_Test2.xml', 'TestCalRoom', x, y, z, rx, ry, rz, t, 'CenterPoint', 3)