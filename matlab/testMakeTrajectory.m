xi = -10:2:10;
yi = -10:2:10;
alt = 10;

[xg,yg]=meshgrid(xi,yi);

zg = alt*ones(size(xg));
rx = zeros(size(xg));
ry = zeros(size(xg));
rz = zeros(size(xg));

makeTrajectory('test.xml', 'Test', xg, yg, zg, rx, ry, rz, 'ImTest', 4)

%%
NCAMS = 10;

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