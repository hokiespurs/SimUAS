function makeAllDistortedChecker
NIMAGES = 500;
rng('default');
rng(5);
mkdir('warpImages');

for i=1:NIMAGES
    %% Generate Random Checkerboard Pattern
    x = round(10+rand(1)*10);        %random int between 10 and 20
    y = round(10+rand(1)*10);        %random int between 10 and 20
    npix = round(20 + rand(1) * 80);  %random int between 20  and 100
    whichDistort = floor(rand(1)*3.9999); %0,1,2,3
    
    switch whichDistort
        case 0 % rotate
            rz = rand(1)*2*pi;
            t = [cos(rz) -sin(rz) 0;sin(rz) cos(rz) 0; 0 0 1];
            fprintf('Rotate: %.0f\n',rz*180/pi);
        case 1 % affine skew
            disp b
            xshear = 0.25 + rand(1)*0.5;
            yshear = 0.25 + rand(1)*0.5;
            t = [1 xshear 0;yshear 1 0; 0 0 1];
            fprintf('Skew X: %.1f \t Skew Y: %.1f',xshear, yshear);
        case 2 % translate
            sx = 0.5+rand(1)*2.5;
            sy = 0.5+rand(1)*2.5;
            t = [sx 0 0;0 sy 0;0 0 1];
            fprintf('Scale X: %.1f \t Scale Y: %.01f\n',sx, sy);
        case 3 % scale
            tx = -50 + rand(1)*100;
            ty = -50 + rand(1)*100;
            t = [tx, ty];
            fprintf('Translate X: %.10f \t Translate Y: %.1f',tx,ty);
    end
    
    [Id,xy]=makeCheckerDist(x,y,npix,t, whichDistort);
    %% Draw result
    figure(101)
    clf
    imagePhotogrammetry(Id);
    hold on
    plot(xy(:,1),xy(:,2),'r.-');
    axis equal
    xlim([xy(1,1)-3 xy(1,1)+3]);
    ylim([xy(1,2)-3 xy(1,2)+3]);
    drawnow
    %% save image
    filename = ['warpimages/IMG_' num2str(i)];
    imwrite(Id,[filename '.png']);
    %% save xyz points
    fid = fopen([filename '.txt'],'w+t');
    fprintf(fid,'%.3f,%.3f\n',xy')
    fclose(fid);
    
end
end

function [Id,xy] = makeCheckerDist(x,y,npix,t, whichType)
%%
[I, xy] = makeChecker(x,y,npix);

switch whichType
    case 0
        tform = affine2d(t);
        
        [Id, W] = imwarp(I,tform);
        
        % Transform Coordinates
        xy(:,1) = xy(:,1)-W.XIntrinsicLimits(1);
        xy(:,2) = -xy(:,2)+W.YIntrinsicLimits(1);
        
        xyd1 = t * [xy ones(size(xy(:,1)))]';
        xyd1 = xyd1./repmat(xyd1(3,:),[3 1]);
        xyd = xyd1';
        
        xpts = xyd(:,1)- W.XWorldLimits(1)+1;
        ypts = -xyd(:,2)- W.YWorldLimits(1)+1;
        
        xy = [xpts ypts];
    case 1

        tform = affine2d(t);
        
        [Id, W] = imwarp(I,tform);
        
        % Transform Coordinates
        xy(:,1) = xy(:,1)-W.XIntrinsicLimits(1);
        xy(:,2) = xy(:,2)-W.YIntrinsicLimits(1);
        
        % 
        temp = t(1,2);
        t(1,2)=t(2,1);
        t(2,1)= temp;
        
        xyd1 = t * [xy ones(size(xy(:,1)))]';
        xyd1 = xyd1./repmat(xyd1(3,:),[3 1]);
        xyd = xyd1';
        
        xpts = xyd(:,1)- W.XWorldLimits(1)+1;
        ypts = xyd(:,2)- W.YWorldLimits(1)+1;
        
        xy = [xpts ypts];
    case 2
        tform = affine2d(t);
        
        [Id, W] = imwarp(I,tform);
        
        % Transform Coordinates
        xy(:,1) = xy(:,1)-W.XIntrinsicLimits(1);
        xy(:,2) = -xy(:,2)+W.YIntrinsicLimits(1);
        
        xyd1 = t * [xy ones(size(xy(:,1)))]';
        xyd1 = xyd1./repmat(xyd1(3,:),[3 1]);
        xyd = xyd1';
        
        xpts = xyd(:,1)- W.XWorldLimits(1)+1;
        ypts = -xyd(:,2)- W.YWorldLimits(1)+1;
        
        xy = [xpts ypts];
    case 3
        xy(:,1) = xy(:,1);
        xy(:,2) = xy(:,2);
        d=nan(size(I,1), size(I,2), 2);
        d(:,:,1) = t(1);
        d(:,:,2) = t(2);
        [Id, ~] = imwarp(I,d);
        xy(:,1) = xy(:,1) - t(1);
        xy(:,2) = xy(:,2) - t(2);
end
        xy(:,1) = xy(:,1) - 1;
        xy(:,2) = xy(:,2) - 1;
end