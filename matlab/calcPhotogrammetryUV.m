function [u,v,s] = calcPhotogrammetryUV(calibration, camR, camT, xyz)


fx = str2double(calibration.fx.Text);
fy = str2double(calibration.fy.Text);
cx = str2double(calibration.cx.Text);
cy = str2double(calibration.cy.Text);

RT = [1 0 0 -camT(1);
      0 -1 0 camT(2);
      0 0  -1 camT(3);];

O = RT * [0 0 0 1]';
Z = RT * [0 0 1 1]';
X = RT * [1 0 0 1]';
Y = RT * [0 1 0 1]';

fprintf('O = %.f,%.f,%.f\n',O)
fprintf('X = %.f,%.f,%.f\n',X)
fprintf('Y = %.f,%.f,%.f\n',Y)
fprintf('Z = %.f,%.f,%.f\n',Z)


K = [fx 0 cx; 0 fy cy; 0 0 1];

xyz1 = [xyz'; ones(1,size(xyz,1))];

uvs = K * RT * xyz1;

s = uvs(3,:);
u = uvs(1,:)./s;
v = uvs(2,:)./s;

end