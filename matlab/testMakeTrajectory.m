xi = -10:2:10;
yi = -10:2:10;
alt = 10;
[xg,yg]=meshgrid(xi,yi);
zg = alt*ones(size(xg));
rx = zeros(size(xg));
ry = zeros(size(xg));
rz = zeros(size(xg));

makeTrajectory('test.xml', 'Test', xg, yg, zg, rx, ry, rz, 'ImTest', 4)