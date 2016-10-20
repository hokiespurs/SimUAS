function testdistort
NX = 21;
NY = 21;

load('testdistortdata');
load('check20');
[m,n,~] = size(I);
Ic = round(linspace(1,n,NX));
Ir = round(linspace(1,m,NY));

[xu, yu] = meshgrid(1:n,1:m);
xc = Calibration.cx;
yc = Calibration.cy;
k = Calibration.k;
f = Calibration.fx;
k = k./([f^2 f^4 f^6 f^8]);
p = Calibration.p./f^2;
% Distort Coordinates
[xd, yd] = calcDistortedCoords(xu, yu, xc, yc, k, p);

dx = xd-xu;
dy = yd-yu;

%% Array Map dx and dy onto distorted coordinates

% fprintf('%s\n',datestr(now));tic
% F = scatteredInterpolant(xd(:),yd(:),dx(:));
% fprintf('%.1f seconds to make F\n',toc);tic
% dx_backwards = F(xu,yu);
% fprintf('%.1f seconds to evaluate for dx F\n',toc);tic
% F.Values = dy(:);
% fprintf('%.1f seconds to set new values F\n',toc);tic
% dy_backwards = F(xu,yu);
% fprintf('%.1f seconds to evaluate for dy F\n',toc);
dx_backwards = roundgridfun(xd,yd,dx,xu,yu,@mean);
dx_backwardsInterp = interpNan(dx_backwards);
dy_backwards = roundgridfun(xd,yd,dy,xu,yu,@mean);
dy_backwardsInterp = interpNan(dy_backwards);

x_pixmap = xu - dx_backwardsInterp;
x_pixmap(isnan(x_pixmap)) = -1;
y_pixmap = yu - dy_backwardsInterp;
y_pixmap(isnan(y_pixmap)) = -1;

% Do Image Mapping
resamp = makeresampler('linear','fill');
tmap_image = cat(3,x_pixmap,y_pixmap);
I2 = tformarray(I,[],resamp,[2 1],[1 2],[],tmap_image,[]);

%%
fig(1)
hold off
image(I)
hold on
plot(xu(Ir,Ic),yu(Ir,Ic),'g.-')
plot(xu(Ir,Ic)',yu(Ir,Ic)','g.-')

%sample mapping
fig(3:8)
hold off
image(I2)
hold on
plot(xd(Ir,Ic),yd(Ir,Ic),'g.-')
plot(xd(Ir,Ic)',yd(Ir,Ic)','g.-')

end

function [xd, yd] = calcDistortedCoords(xu, yu, xc, yc, k, p)
    % radial distortion
    r = sqrt((xu - xc) .^ 2 + (yu - yc) .^ 2);
    dx_radial = (xu - xc) .* (1 + (k(1) .* r .^ 2) + (k(2) .* r .^ 4) + (k(3) .* r .^ 6) + (k(4) .* r .^ 8));
    dy_radial = (yu - yc) .* (1 + (k(1) .* r .^ 2) + (k(2) .* r .^ 4) + (k(3) .* r .^ 6) + (k(4) .* r .^ 8));

    % tangential distortion
    dx_tangential = (p(1) .* (r.^2 + 2*(xu - xc).^2) + 2 .* p(2) .* (xu - xc) .* (yu - yc));
    dy_tangential = (p(2) .* (r.^2 + 2*(yu - yc).^2) + 2 .* p(1) .* (xu - xc) .* (yu - yc));

    % calculate distorted coordinate
    xd = xc + dx_radial + dx_tangential;
    yd = yc + dy_radial + dy_tangential;

end
