function analyzeWarpFiducials(whichtype)

homedir = getHomePath('SimUAS');
outImDir = [homedir '/matlab/validatePhotogrammetry/warpImages'];

[~,~,~,~,dx,dy]=calcFiducial(outImDir,whichtype,0);

%% Delta Plots
close all

f1 = figure(1);
set(f1,'units','normalize','position',[0 0 1 1])
plot(dx,dy,'b.','markersize',10)
xlim([-1 1]);
ylim([-1 1]);
xlabel('Image X minus Projected X (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('Image Points Minus Projected Points (pixels)');

f2 = figure(2);
set(f2,'units','normalize','position',[0 0 1 1])
xgi = -1:0.05:1;dxgi = mean(diff(xgi));
ygi = -1:0.05:1;dygi = mean(diff(xgi));
H = heatmapscat(dx,dy,xgi,ygi);
npts = sum(~isnan(dx(:)));
pcolor(xgi-dxgi/2, ygi-dygi/2, H/npts*100);shading flat
h = colorbar;
ylabel(h,'Percentage of Points in Bin','fontsize',20);
xlabel('Image X minus Projected X (pixels)');
ylabel('Image Y minus Projected Y (pixels)');
title('Heatmap of Image Points Minus Projected Points (pixels)');

%% save images
mkdir([outImDir '\proc'])
saveas(f1,[outImDir '\proc\Points' num2str(whichtype) '.png']);
saveas(f2,[outImDir '\proc\Heatmap' num2str(whichtype) '.png']);
save([outImDir '\proc\data' num2str(whichtype) '.mat']);
end

function [proj_x,proj_y,image_x,image_y,dx,dy]=calcFiducial(outImDir,whichtype, dodebug)
if nargin==2
   dodebug = 0; 
end
imnames = dirname([outImDir '/*.png']);
txtnames = dirname([outImDir '/*.txt']);

proj_x = [];
proj_y = [];
image_x = [];
image_y = [];

startTime = now;
for iImage=1:numel(imnames)
    image_xy = detectFiducials(imnames{iImage},whichtype);
    true_xy = importdata(txtnames{iImage});
    if numel(image_xy)>0 && numel(true_xy)>0
        [IDX,D] = knnsearch(image_xy,true_xy);
        goodvals = false(size(IDX));
        goodvals(D<5)=1; % this turns bad values to nans on the next line
        
        proj_x = [proj_x true_xy(goodvals,1)'];
        proj_y = [proj_y true_xy(goodvals,2)'];
        image_x = [image_x image_xy(IDX(goodvals),1)'];
        image_y = [image_y image_xy(IDX(goodvals),2)'];
        if dodebug
           I = imread(imnames{iImage});
           figure(100)
           clf
           imagePhotogrammetry(I);
           hold on
           plot(true_xy(:,1),true_xy(:,2),'r.','markersize',10);
           plot(image_xy(:,1),image_xy(:,2),'g+','markersize',20);
           plot(true_xy(goodvals,1),true_xy(goodvals,2),'c.','markersize',10);
           drawnow
        end
    end
    loopStatus(startTime,iImage,numel(imnames),1)
end

dx = image_x - proj_x;
dy = image_y - proj_y;

end

