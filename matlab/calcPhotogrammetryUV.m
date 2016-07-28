function [u,v,s] = calcPhotogrammetryUV(calibration, camR, camT, xyz)


fx = str2double(calibration.fx.Text);
fy = str2double(calibration.fy.Text);
cx = str2double(calibration.cx.Text);
cy = str2double(calibration.cy.Text);

camR = camR*pi/180;

Rblender = makehgtform('zrotate',camR(3),...
                'yrotate',camR(2),...
                'xrotate',camR(1));
Rblender2photogrammetry = diag([1 -1 -1 1]);

R = Rblender * Rblender2photogrammetry;
R = R(1:3,1:3);

RT = inv([(R) camT';0 0 0 1]);
RT = RT(1:3,:);

O = RT * [0 0 0 1]';
Z = RT * [0 0 1 1]';
X = RT * [1 0 0 1]';
Y = RT * [0 1 0 1]';

fprintf('O = %.2f,%.2f,%.2f\n',O)
fprintf('X = %.2f,%.2f,%.2f\n',X)
fprintf('Y = %.2f,%.2f,%.2f\n',Y)
fprintf('Z = %.2f,%.2f,%.2f\n',Z)

K = [fx 0 cx; 0 fy cy; 0 0 1];

xyz1 = [xyz'; ones(1,size(xyz,1))];

uvs = K * RT * xyz1;

K
RT
P = K*RT

s = uvs(3,:);
u = uvs(1,:)./s;
v = uvs(2,:)./s;

 u(s<0)=nan;
 v(s<0)=nan;
end