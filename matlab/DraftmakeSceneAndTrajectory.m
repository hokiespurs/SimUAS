[xg,yg]=meshgrid(-25:10:25,-25:10:25);

for i=1:numel(xg)
    fprintf('<object objname="gcp" name = "GCP%02.0f" isControl = "1" isMarker = "1">\n',i)
    fprintf('\t<translation x="%.0f" y="%.0f" z="%.0f"/>\n',xg(i),yg(i),1)
    fprintf('\t<rotation x="0" y="0" z="0"/>\n');
    fprintf('\t<scale x="1" y="1" z="1"/>\n');
    fprintf('</object>\n')
end

xi = -20:5:20;
yi = -20:5:20;
alt = 40;

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