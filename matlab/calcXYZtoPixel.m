function [xy, inframe] = calcXYZtoPixel(markT, camT, camR, Calibration)
    fx = Calibration.fx;
    fy = Calibration.fy;
    cx = Calibration.cx;
    cy = Calibration.cy;
    k = Calibration.k;
    p = Calibration.p;
    f = Calibration.fx;
    k = k./([f^2 f^4 f^6 f^8]);
    p = Calibration.p./f;
    
    camR = camR*pi/180;

    Rblender = makehgtform('zrotate',camR(3),...
                'yrotate',camR(2),...
                'xrotate',camR(1));
    Rblender2photogrammetry = diag([1 -1 -1 1]);

    R = Rblender * Rblender2photogrammetry;
    R = R(1:3,1:3);

    RT = inv([(R) camT';0 0 0 1]);
    RT = RT(1:3,:);
    
    K = [fx 0 cx; 0 fy cy; 0 0 1];

    xyz1 = [markT'; ones(1,size(markT,1))];

    uvs = K * RT * xyz1;

    s = uvs(3,:);
    u = uvs(1,:)./s;
    v = uvs(2,:)./s;

    [x, y] = calcDistortedCoords(u, v, cx, cy, k, p);
    
    inframePre = u>0 & v>0 & u<Calibration.width & v<Calibration.height;
    inframePost = s>0 & x>0 & y>0 & x<Calibration.width & y<Calibration.height;
    inframe = inframePre & inframePost;
    
    x = x(inframe);
    y = y(inframe);
    
    if sum(inframe)
        xy = [x' y'];
    else
        xy = [nan, nan];        
    end
    
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
