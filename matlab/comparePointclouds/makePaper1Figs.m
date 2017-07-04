% Make Plots for Paper 1
clear
close all
clc
%% Read in las points
dname = ['C:\Users\Richie\Documents\GitHub\SimUAS' ...
    '\data\topofield2\proc\20160103_basicTest\clippoints\clip\'];

las_dense_lowest_agg_clip = lasdata([dname 'dense_lowest_aggressive_clip.las']);
las_dense_low_agg_clip = lasdata([dname 'dense_low_aggressive_clip.las']);
las_dense_med_agg_clip = lasdata([dname 'dense_medium_aggressive_clip.las']);
las_dense_high_agg_clip = lasdata([dname 'dense_high_aggressive_clip.las']);
las_dense_highest_agg_clip = lasdata([dname 'dense_ultrahigh_aggressive_clip.las']);
%% Make Colormap
cmap = lines(6);
cmap = cmap(2:end,:);
%% Read in Obj File
obj = loadawobj('C:\Users\Richie\Documents\GitHub\SimUAS\data\topofield2\output\model\obj\clipobj.obj');

%% Compare Cube Edges
XLIM = [-0.25 0.25];
YLIM = [-3 3];
ZLIM = [1 6];
VIEWAZ = 90;
VIEWELE = 0;
% make figure
f1 = figure;
hold on

% plot points
p5 = plotlas3trim(las_dense_highest_agg_clip,XLIM,YLIM,ZLIM,cmap(1,:),20);
p4 = plotlas3trim(las_dense_high_agg_clip,XLIM,YLIM,ZLIM,cmap(2,:),20);
p3 = plotlas3trim(las_dense_med_agg_clip,XLIM,YLIM,ZLIM,cmap(3,:),20);
p2 = plotlas3trim(las_dense_low_agg_clip,XLIM,YLIM,ZLIM,cmap(4,:),20);
p1 = plotlas3trim(las_dense_lowest_agg_clip,XLIM,YLIM,ZLIM,cmap(5,:),20);
% set(gca,'Color',[0.2 0.2 0.2]);

% make edge of cube visible even when clipped out
cubeV = [0 0 0 0 -1.5 -1.5 1.5 1.5;-1.5 -1.5 1.5 1.5 0 0 0 0;2 5 5 2 2 5 5 2];
cubeF = [1 2 3 4; 5 6 7 8];

% plot object faces
patch('Vertices',obj.v','Faces',obj.f4','FaceColor','k','FaceAlpha',0.2,'edgecolor','k','linewidth',2);
hold on
patch('Vertices',obj.v','Faces',obj.f3','FaceColor','k','FaceAlpha',0.05,'edgecolor','none');
% patch('Vertices',cubeV','Faces',cubeF,'FaceColor','k','FaceAlpha',0.3,'edgecolor','k','linewidth',3);

% axis
view(VIEWAZ,VIEWELE)
axis equal
xlim(XLIM)
ylim(YLIM)
zlim(ZLIM)

% labels
set(gca,'fontsize',20)
ylabel('Y Coordinate (m)','fontsize',34,'interpreter','latex');
zlabel('Z Coordinate (m)','fontsize',34,'interpreter','latex');
title({'50cm Wide Profile of Pointcloud Data from Different'...
       'Dense Reconstruction Settings Across a 3m Cube'},'fontsize',40,...
       'interpreter','latex');
%legend
[h1,icons]= legend('ultrahigh','high','medium','low','lowest');
set(h1,'fontsize',24)
for i=1:5
   icons(i).FontSize = 20; 
end
for i=7:2:15
   icons(i).MarkerSize = 40; 
end
set(h1,'location','best')
%% Compare Cube Side
XLIM = [-1.75 -1.25];
YLIM = [-2 2];
ZLIM = [1.5 5.5];
VIEWAZ = 90;
VIEWELE = 0;
% make figure
f1 = figure;
hold on

% plot points
p5 = plotlas3trim(las_dense_highest_agg_clip,XLIM,YLIM,ZLIM,cmap(1,:),5);
p4 = plotlas3trim(las_dense_high_agg_clip,XLIM,YLIM,ZLIM,cmap(2,:),10);
p3 = plotlas3trim(las_dense_med_agg_clip,XLIM,YLIM,ZLIM,cmap(3,:),10);
p2 = plotlas3trim(las_dense_low_agg_clip,XLIM,YLIM,ZLIM,cmap(4,:),10);
p1 = plotlas3trim(las_dense_lowest_agg_clip,XLIM,YLIM,ZLIM,cmap(5,:),10);
% set(gca,'Color',[0.2 0.2 0.2]);

% make edge of cube visible even when clipped out
cubeV = [0 0 0 0 -1.5 -1.5 1.5 1.5;-1.5 -1.5 1.5 1.5 0 0 0 0;2 5 5 2 2 5 5 2];
cubeF = [1 2 3 4; 5 6 7 8];

% plot object faces
patch('Vertices',obj.v','Faces',obj.f4','FaceColor','k','FaceAlpha',0.2,'edgecolor','k','linewidth',2);
hold on
patch('Vertices',obj.v','Faces',obj.f3','FaceColor','k','FaceAlpha',0.05,'edgecolor','none');
% patch('Vertices',cubeV','Faces',cubeF,'FaceColor','k','FaceAlpha',0.3,'edgecolor','k','linewidth',3);

% axis
view(VIEWAZ,VIEWELE)
axis equal
xlim(XLIM)
ylim(YLIM)
zlim(ZLIM)

% labels
set(gca,'fontsize',16)
ylabel('Y Coordinate (m)','fontsize',20,'interpreter','latex');
zlabel('Z Coordinate (m)','fontsize',20,'interpreter','latex');
title({'50cm Wide Profile of Pointcloud Data from Different'...
       'Dense Reconstruction Settings Across a 3m Cube'},'fontsize',24,...
       'interpreter','latex');
%legend
[h1,icons]= legend('ultrahigh','high','medium','low','lowest');
set(h1,'fontsize',16)
for i=1:5
   icons(i).FontSize = 16; 
end
for i=7:2:15
   icons(i).MarkerSize = 25; 
end
set(h1,'location','best')

figure
xg = YLIM(1):0.05:YLIM(2);
yg = ZLIM(1):0.05:ZLIM(2);

[x5,y5,z5]=getlasptsTrim(las_dense_highest_agg_clip,XLIM,YLIM,ZLIM);
[x4,y4,z4]=getlasptsTrim(las_dense_high_agg_clip,XLIM,YLIM,ZLIM);
[x3,y3,z3]=getlasptsTrim(las_dense_med_agg_clip,XLIM,YLIM,ZLIM);
[x2,y2,z2]=getlasptsTrim(las_dense_low_agg_clip,XLIM,YLIM,ZLIM);
[x1,y1,z1]=getlasptsTrim(las_dense_lowest_agg_clip,XLIM,YLIM,ZLIM);
x6 = [x4; x5];y6 = [y4; y5];z6 = [z4; z5];


[ig6,npts] = roundgridfun(y6,z6,x6-(mean(XLIM)),xg,yg,@mean);
[ig5,npts] = roundgridfun(y5,z5,x5-(mean(XLIM)),xg,yg,@mean);
[ig4,npts] = roundgridfun(y4,z4,x4-(mean(XLIM)),xg,yg,@mean);
[ig3,npts] = roundgridfun(y3,z3,x3-(mean(XLIM)),xg,yg,@mean);
[ig2,npts] = roundgridfun(y2,z2,x2-(mean(XLIM)),xg,yg,@mean);
[ig1,npts] = roundgridfun(y1,z1,x1-(mean(XLIM)),xg,yg,@mean);

% p(:,1) = [0.05

subplot 231
pcolor(xg,yg,ig1);shading flat;caxis([-0.05 0.05])
set(gca,'fontsize',14);
title('Lowest','fontsize',20,'interpreter','latex')
set(gca,'xdir','reverse')
ylabel('Z Coordinate (m)','fontsize',20,'interpreter','latex');
axis equal
xlim(YLIM)
ylim(ZLIM)

subplot 232
pcolor(xg,yg,ig2);shading flat;caxis([-0.05 0.05])
set(gca,'fontsize',14);
title('Low','fontsize',20,'interpreter','latex')
set(gca,'xdir','reverse')
axis equal
xlim(YLIM)
ylim(ZLIM)

subplot 233
pcolor(xg,yg,ig3);shading flat;caxis([-0.05 0.05])
set(gca,'fontsize',14);
c = colorbar;
title('Medium','fontsize',20,'interpreter','latex')
set(gca,'xdir','reverse')
ylabel(c,'X Error (cm)','fontsize',20,'interpreter','latex');
axis equal
xlim(YLIM)
ylim(ZLIM)
set(c,'Position',[0.92 0.1 0.02 0.83])

subplot 234
pcolor(xg,yg,ig4);shading flat;caxis([-0.05 0.05])
set(gca,'fontsize',14);
title('High','fontsize',20,'interpreter','latex')
set(gca,'xdir','reverse')
xlabel('Y Coordinate (m)','fontsize',20,'interpreter','latex');
ylabel('Z Coordinate (m)','fontsize',20,'interpreter','latex');
axis equal
xlim(YLIM)
ylim(ZLIM)


subplot 235
pcolor(xg,yg,ig5);shading flat;caxis([-0.05 0.05])
set(gca,'fontsize',14);
title('UltraHigh','fontsize',20,'interpreter','latex')
set(gca,'xdir','reverse')
xlabel('Y Coordinate (m)','fontsize',20,'interpreter','latex');
axis equal
xlim(YLIM)
ylim(ZLIM)


subplot 236
image(-3:1:3,6:-1:1,imread('orthocubeside.png'))
set(gca,'fontsize',14);
set(gca,'ydir','normal')
title('Actual Image','fontsize',20,'interpreter','latex')
axis equal
xlim(YLIM)
ylim(ZLIM)
xlabel('Y Coordinate (m)','fontsize',20,'interpreter','latex');


colormap('jet')
    
%% Make Dense Pcolor Plots
dnamecc = 'C:\Users\Richie\Documents\GitHub\SimUAS\data\topofield2\proc\20160103_basicTest\CloudCompare\';

ccnames = {'dense_lowest_aggressive - Cloud.txt',...
           'dense_low_aggressive - Cloud.txt',...
           'dense_medium_aggressive - Cloud.txt',...
           'dense_high_aggressive - Cloud.txt',...
           'dense_ultrahigh_aggressive - Cloud.txt'};

% make grid
ix = -100:0.5:100;
iy = -100:0.5:100;
[xg,yg]=meshgrid(ix,iy);
       
for i = 1:numel(ccnames)
    fprintf('Reading: %s\n',ccnames{i});
    %read data
    rawdat = importdata([dnamecc ccnames{i}]);
    x = rawdat.data(:,1);
    y = rawdat.data(:,2);
    z = rawdat.data(:,3);
    dz = rawdat.data(:,10);
    udz = nanmean(dz(:));
    stddz = nanstd(dz(:));
    rmsedz = sqrt(sum((dz(:)).^2)/numel(dz));
    fprintf('Mean: %.4f\t STD: %.4f\t RMSE: %.4f\n',udz,stddz,rmsedz);
    % grid data
    fprintf('\tgridding...\n');
    [zg,ng] = roundgridfun(x,y,z,xg,yg,@mean);
    ng(ng==0)=nan;
    dzg = roundgridfun(x,y,dz,xg,yg,@mean);
    dzstd = roundgridfun(x,y,dz,xg,yg,@std);
    %% make pcolor plot
    figure
    subplot 221
    pcolor(xg,yg,zg);shading flat
    caxis([-5 5])
    c = colorbar;
    title('Elevation');
    axis equal
    xlim([-100 100]);
    ylim([-100 100]);
    set(gca,'fontsize',14)
    xlabel('X (m)','fontsize',16);
    ylabel('Y (m)','fontsize',16);
    ylabel(c,'Z (m)','fontsize',16);
    
    subplot 222
    pcolor(xg,yg,dzg*100);shading flat
    caxis([-5 5])
    c = colorbar;
    title('Error');
    axis equal
    xlim([-100 100]);
    ylim([-100 100]);
    set(gca,'fontsize',14)
    xlabel('X (m)','fontsize',16);
    ylabel('Y (m)','fontsize',16);
    ylabel(c,'Error (cm)','fontsize',16);
    
    subplot 223
    pcolor(xg,yg,ng);shading flat
    stdcaxis(ng,2);
    c = colorbar;
    title('Points Per Grid Cell');
    axis equal
    xlim([-100 100]);
    ylim([-100 100]);
    set(gca,'fontsize',14)
    xlabel('X (m)','fontsize',16);
    ylabel('Y (m)','fontsize',16);
    ylabel(c,'Points Per Grid Cell','fontsize',16);
    
    subplot 224
    pcolor(xg,yg,dzstd*100);shading flat
    caxis([0 2]);
    c = colorbar;
    title('Standard Deviation of Error');
    axis equal
    xlim([-100 100]);
    ylim([-100 100]);
    set(gca,'fontsize',14)
    xlabel('X (m)','fontsize',16);
    ylabel('Y (m)','fontsize',16);
    ylabel(c,'Standard Deviation of Error (cm)','fontsize',16);
    
    %% make histogram
    figure
    h=histogram(dz(:),-0.1:0.0005:0.1,'Normalization','probability');
    xh = h.BinEdges(1:end-1)+h.BinWidth/2;
    hvals=h.Values;
    title({makeTitleStr(ccnames{i}),sprintf('Mean: %.3f\t std: %.3f',mean(dz(:)),std(dz(:)))});
    %%
    figure(100)
    plot(xh,hvals,'color',cmap(i,:),'linewidth',3);
    hold on
    h1 = legend('lowest','low','medium','high','ultrahigh');
    xlabel('Pointcloud Signed Error (m)','fontsize',30,'interpreter','latex')
    ylabel('Probability (\%)','fontsize',30,'interpreter','latex')
    title({'Pointcloud to Mesh Signed Error Probability', 'using different Dense Reconstruction Settings'},'fontsize',34,'interpreter','latex');
    set(h1,'fontsize',16)   
    XH{i} = xh;
    H{i} = hvals;
    %% Combo histogram
    figure(200)
    plot(xh,hvals,'--','color',cmap(i,:));
    hold on
    xlabel('Pointcloud Signed Error (m)','fontsize',18)
    ylabel('Probability (%)','fontsize',18)
    %% Cropped Histogram
    ind = isinrange(x,[-50 50]) & isinrange(y,[-50 50]);
    figure
    h=histogram(dz(ind),-0.1:0.0005:0.1,'Normalization','probability');
    title({[makeTitleStr(ccnames{i}) '(AOI)'],sprintf('Mean: %.3f\t std: %.3f',mean(dz(ind)),std(dz(ind)))});

    figure(101);
    xh = h.BinEdges(1:end-1)+h.BinWidth/2;
    hvals2=h.Values;
    plot(xh,hvals2,'color',cmap(i,:));
    hold on
    h1 = legend('lowest','low','medium','high','ultrahigh');
    xlabel('Pointcloud Signed Error (m)','fontsize',18)
    ylabel('Probability','fontsize',18)
    title({'Pointcloud to Mesh Signed Error Probability (Only AOI)', 'using different Dense Reconstruction Settings'},'fontsize',18);
    set(h1,'fontsize',16)
    %% combo2
    figure(200)
    plot(xh,hvals2,'color',cmap(i,:));
    
    %% Grid histogram
    ind = isinrange(xg(:),[-50 50]) & isinrange(yg(:),[-50 50]);
    figure
    h=histogram(dzg(ind),-0.1:0.001:0.1,'Normalization','probability');
    title({[makeTitleStr(ccnames{i}) '(AOI ZG)'],sprintf('Mean: %.3f\t std: %.3f',mean(dzg(ind)),std(dzg(ind)))});

    figure(102);
    xh = h.BinEdges(1:end-1)+h.BinWidth/2;
    hvals2=h.Values;
    plot(xh,hvals2,'color',cmap(i,:));
    hold on
    h1 = legend('lowest','low','medium','high','ultrahigh');
    xlabel('Pointcloud Signed Error (m)','fontsize',18)
    ylabel('Probability','fontsize',18)
    title({'Pointcloud to Mesh Signed Error Probability (Only ZG AOI)', 'using different Dense Reconstruction Settings'},'fontsize',18);
    set(h1,'fontsize',16)


    drawnow
end




