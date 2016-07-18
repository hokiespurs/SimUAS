%test calcPhotogrammetry
calibration.fx.Text = '371.47';
calibration.fy.Text = '371.47';
calibration.cx.Text = '272.8';
calibration.cy.Text = '181.6';
camR = [0 0 0];
camT = [-40 -40 60];
xyz = [-50 -50 1];

% u = 210
% v = 244

[u,v] = calcPhotogrammetryUV(calibration, camR, camT, xyz);

fprintf('%.2f == %.2f\n',335, u)
fprintf('%.2f == %.2f\n',244, v)