Calibration.cx = 150;
Calibration.cy = 150;
Calibration.fx = 20;
Calibration.k = [-0.001 0 0 0];
Calibration.p=[0 0];
Calibration.width = 300;
Calibration.height = 300;
Calibration.postproc.vignetting = [10 0.4 0.2];
%make figure
Iraw = makeChecker(50,10);

Idist = addDistortion(I, Calibration);

Iv = addVignetting(Idistorted,Calibration);

Iblur = imgaussfilt(Iv,2);

Isaltpepper = addSaltPepper(Iblur,0.02,0.02);

Inoise = imnoise(Isaltpepper,'gaussian',0,0.02);

Itrim = trimimage(Inoise, Calibration.width, Calibration.height);
mkdir('demoImages');

f = figure(10);clf
subplot(2,7,1)
imshow(Iraw);title('Raw Image');
imwrite(Iraw,'A.png');
subplot(2,7,8);
imshow(trimimage(Iraw,20,20));
imwrite(trimimage(Iraw,20,20),'Azoom.png');

subplot(2,7,2)
imshow(Idist);title('Distortion');
imwrite(Idist,'B.png');
subplot(2,7,9);
imshow(trimimage(Idist,20,20));
imwrite(trimimage(Idist,20,20),'Bzoom.png');

subplot(2,7,3)
imshow(Iv);title('Vignetting');
imwrite(Iv,'C.png');
subplot(2,7,10);
imshow(trimimage(Iv,20,20));
imwrite(trimimage(Iv,20,20),'Czoom.png');

subplot(2,7,4)
imshow(Iblur);title('Gaussian Blur');
imwrite(Iblur,'D.png');
subplot(2,7,11);
imshow(trimimage(Iblur,20,20));
imwrite(trimimage(Iblur,20,20),'Dzoom.png');

subplot(2,7,5)
imshow(Isaltpepper);title('Salt/Pepper Noise');
imwrite(Isaltpepper,'E.png');
subplot(2,7,12);
imshow(trimimage(Isaltpepper,20,20));
imwrite(trimimage(Isaltpepper,20,20),'Ezoom.png');

subplot(2,7,6)
imshow(Inoise);title('Gaussian Noise');
imwrite(Inoise,'F.png');
subplot(2,7,13);
imshow(trimimage(Inoise,20,20));
imwrite(trimimage(Inoise,20,20),'Fzoom.png');

subplot(2,7,7)
imshow(Itrim);title('Crop');
imwrite(Itrim,'G.png');
subplot(2,7,14);
imshow(trimimage(Itrim,20,20));
imwrite(trimimage(Itrim,20,20),'Gzoom.png');


function Ichecker = makeChecker(pixPerChecker,nCheckers)
I = checker_board(pixPerChecker,nCheckers);
I = I*255;
Ichecker = uint8(I);

end

function Idist = addDistortion(I,Calibration)
    [height,width,~]=size(I);
    newMap = calcImageMap(Calibration, height, width);
    resamp = makeresampler('linear','fill');
    Idist = tformarray(I,[],resamp,[2 1],[1 2],[],newMap,[]);
end

function Isaltpepper = addSaltPepper(I,saltprob,pepperprob)
    [m,n,p]=size(I);

% Add Salt Noise
noise = rand(m,n);
noise = repmat(noise,[1,1,p]);
I(noise<saltprob)=255;

% Add Pepper Noise
noise = rand(m,n);
noise = repmat(noise,[1,1,p]);
I(noise<pepperprob)=0;

Isaltpepper = I;
end

function newMap = calcImageMap(Calibration, height, width)
    
    m = height;
    n = width;
    
    [xu, yu] = meshgrid(1:n,1:m);
    xc = Calibration.cx + (n - Calibration.width)/2;
    yc = Calibration.cy + (m - Calibration.height)/2;
    k = Calibration.k;
    f = Calibration.fx;
    k = k./([f^2 f^4 f^6 f^8]);
    p = Calibration.p./f;
    % Distort Coordinates
    [xd, yd] = calcDistortedCoords(xu, yu, xc, yc, k, p);
    
    dx = xd-xu;
    dy = yd-yu;

    dx_backwards = roundgridfun(xd,yd,dx,xu,yu,@mean);
    dx_backwardsInterp = interpNan(dx_backwards);
    dy_backwards = roundgridfun(xd,yd,dy,xu,yu,@mean);
    dy_backwardsInterp = interpNan(dy_backwards);

    x_pixmap = xu - dx_backwardsInterp;
    x_pixmap(isnan(x_pixmap)) = -1;
    y_pixmap = yu - dy_backwardsInterp;
    y_pixmap(isnan(y_pixmap)) = -1;

    % Do Image Mapping
    newMap = cat(3,x_pixmap,y_pixmap);
    
end

function Itrim = trimimage(I,x,y)
    [m,n,~]=size(I);
    padx = (n-x)/2;
    pady = (m-y)/2;
    
    Itrim = I;
    Itrim(1:pady,:,:)=[];
    Itrim(end-pady+1:end,:,:)=[];
    Itrim(:,1:padx,:)=[];
    Itrim(:,end-padx+1:end,:)=[];
end

function Ivignette = addVignetting(Iraw,Calibration)
        [m,n,p]=size(Iraw);
        padx = (n-Calibration.width)/2;
        pady = (m-Calibration.height)/2;
        I = Iraw;
        [xu,yu]=meshgrid(1:n,1:m);
        xc = Calibration.cx+padx;
        yc = Calibration.cy+pady;
        r = sqrt((xu - xc) .^ 2 + (yu - yc) .^ 2);
        v = Calibration.postproc.vignetting;
        maxI = double(cast(inf,class(I)));
        v = v./[1 max(r(:)) max(r(:)).^2].*[1 maxI maxI];
        dI = v(1) + v(2)*r + v(3)*r.^2;
        
        dI = repmat(dI,[1,1,p]);
        
        I = double(I)-dI;
        Ivignette = cast(I,class(Iraw)); %ensure I is same type

end