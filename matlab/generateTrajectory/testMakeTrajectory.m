xi = -100:20:100;
yi = -100:15:100;
alt = 80;

[xg,yg]=meshgrid(xi,yi);

zg = alt*ones(size(xg));
rx = zeros(size(xg));
ry = zeros(size(xg));
rz = zeros(size(xg));

makeTrajectory('trajectory_test.xml', 'Test', xg, yg, zg, rx, ry, rz,1:numel(xg), 'ImTest', 4)
%% Random Angles Pointing at 0,0,0 with constant Roll = 0
NCAMS = 100;

iTheta = rand(NCAMS,1)*360;
iPhi = rand(NCAMS,1)*180;
iRoll = rand(NCAMS,1)*360;
iRange = rand(NCAMS,1)*10;

x = iRange .* sind(iPhi) .* cosd(iTheta);
y = iRange .* sind(iPhi) .* sind(iTheta);
z = iRange .* cosd(iPhi);

rx = zeros(size(x));
ry = iPhi;
rz = iTheta;

makeTrajectory('trajectory_Test2.xml', 'Test', x, y, z, rx, ry, rz, 'CenterPoint', 3)

%% Random position and RPY in a cube
NCAMS = 100;

iRoll = rand(NCAMS,1)*360;
iPitch = rand(NCAMS,1)*360;
iYaw = rand(NCAMS,1)*360;
iX = rand(NCAMS,1)*1;
iY = rand(NCAMS,1)*1;
iZ = rand(NCAMS,1)*1;
makeTrajectory('trajectory_randomCube.xml', 'randomCubeAngles', iX, iY, iZ, iRoll, iPitch, iYaw, 'Image', 3)

