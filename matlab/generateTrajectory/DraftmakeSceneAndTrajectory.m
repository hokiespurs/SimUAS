
xi = -22.5:7.5:22.5;
yi = -22.5:7.5:22.5;
alt = 30;

[xg,yg]=meshgrid(xi,yi);

xg = xg + randn(size(xg))*1;
yg = yg + randn(size(xg))*1;
zg = alt*ones(size(xg))-randn(size(xg))*1;
rx = randn(size(xg))*5;
ry = randn(size(xg))*5;
rz = randn(size(xg))*5;
t = 1:numel(xg);

makeTrajectory('test.xml', 'Test', xg, yg, zg, rx, ry, rz, t, 'A', 4)

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