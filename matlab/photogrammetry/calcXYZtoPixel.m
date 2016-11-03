function [xy, inframe] = calcXYZtoPixel(markT, camT, camR, Calibration)
    fx = Calibration.fx;
    fy = Calibration.fy;
    cx = Calibration.cx;
    cy = Calibration.cy;
    k = Calibration.k;
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
    
    if sum(inframe)>0
        x(:) = nan;
        y(:) = nan;
    end
    xy = [x y];
end
