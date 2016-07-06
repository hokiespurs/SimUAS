xi = -10:2:10;
yi = -10:2:10;
alt = 10;
[xg,yg]=meshgrid(xi,yi);
zg = alt*ones(size(xg));
rx = zeros(size(xg));
ry = zeros(size(xg));
rz = zeros(size(xg));

makeTrajectory('test.xml', 'Test', xg, yg, zg, rx, ry, rz, 'ImTest', 4)

iTheta = rand(100,1)*360;
iPhi = rand(100,1)*180;
iRoll = rand(100,1)*360;
iRange = rand(100,1)*10;

x = iRange .* sind(iPhi) .* cosd(iTheta);
y = iRange .* sind(iPhi) .* sind(iTheta);
z = iRange .* cosd(iPhi);

rx = zeros(size(x));
ry = iPhi;
rz = iTheta;

makeTrajectory('test2.xml', 'Test', x, y, z, rx, ry, rz, 'ImTest2', 4)

