% Make Plots for Paper 1
clear
close all
clc
%% Read in las points
dname = ['C:\Users\Richie\Documents\GitHub\BlenderPythonTest' ...
    '\data\topofield2\proc\20160103_basicTest\clippoints\clip\'];

las_dense_lowest_agg_clip = lasdata([dname 'dense_lowest_aggressive_clip.las']);
las_dense_low_agg_clip = lasdata([dname 'dense_low_aggressive_clip.las']);
las_dense_med_agg_clip = lasdata([dname 'dense_medium_aggressive_clip.las']);
las_dense_high_agg_clip = lasdata([dname 'dense_high_aggressive_clip.las']);
las_dense_highest_agg_clip = lasdata([dname 'dense_ultrahigh_aggressive_clip.las']);

%% Read in Obj File
obj = loadawobj('C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\topofield2\output\model\obj\allmodel.obj');

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
cmap = jet(5);
p5 = plotlas3trim(las_dense_highest_agg_clip,XLIM,YLIM,ZLIM,'r',5);
p4 = plotlas3trim(las_dense_high_agg_clip,XLIM,YLIM,ZLIM,cmap(2,:),10);
p3 = plotlas3trim(las_dense_med_agg_clip,XLIM,YLIM,ZLIM,cmap(3,:),10);
p2 = plotlas3trim(las_dense_low_agg_clip,XLIM,YLIM,ZLIM,cmap(4,:),10);
p1 = plotlas3trim(las_dense_lowest_agg_clip,XLIM,YLIM,ZLIM,cmap(5,:),10);
% set(gca,'Color',[0.2 0.2 0.2]);

% make edge of cube visible even when clipped out
cubeV = [0 0 0 0 -1.5 -1.5 1.5 1.5;-1.5 -1.5 1.5 1.5 0 0 0 0;2 5 5 2 2 5 5 2];
cubeF = [1 2 3 4; 5 6 7 8];

% plot object faces
patch('Vertices',obj.v','Faces',obj.f4','FaceColor','k','FaceAlpha',0.2,'edgecolor','k','linewidth',3);
hold on
patch('Vertices',cubeV','Faces',cubeF,'FaceColor','k','FaceAlpha',0.3,'edgecolor','k','linewidth',3);

% axis
view(VIEWAZ,VIEWELE)
axis equal
xlim(XLIM)
ylim(YLIM)
zlim(ZLIM)

% labels
ylabel('Y Coordinate (m)','fontsize',20);
zlabel('Z Coordinate (m)','fontsize',20);

%legend


%% Make Dense Pcolor Plots
dnamecc = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\topofield2\proc\20160103_basicTest\CloudCompare\';

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
    % grid data
    fprintf('\tgridding...\n',ccnames{i});
    [zg,ng] = roundgridfun(x,y,z,xg,yg,@mean);
    ng(ng==0)=nan;
    dzg = roundgridfun(x,y,dz,xg,yg,@mean);
    dzstd = roundgridfun(x,y,dz,xg,yg,@std);
    %% make pcolor plot
    figure
    subplot 221
    pcolor(xg,yg,zg);shading flat
    caxis([-5 5])
    colorbar
    title({makeTitleStr(ccnames{i}),'zg'});
    
    subplot 222
    pcolor(xg,yg,dzg);shading flat
    caxis([-0.05 0.05])
    colorbar
    title('dzg');
    
    subplot 223
    pcolor(xg,yg,1./ng);shading flat
    stdcaxis(1./ng,2);
    colorbar
    title('numel');
    
    subplot 224
    pcolor(xg,yg,dzstd);shading flat
    caxis([0 0.02]);
    colorbar
    title('std of dz');
    
    %% make histogram
    figure
    h=histogram(dz(:),-0.1:0.001:0.1,'Normalization','probability');
    xh = h.BinEdges(1:end-1)+h.BinWidth/2;
    hvals(i,:)=h.Values;
    xlim([-std(dz(:))*3 std(dz(:))*3]);
    title({makeTitleStr(ccnames{i}),sprintf('Mean: %.3f\t std: %.3f',mean(dz(:)),std(dz(:)))});
    %%
    figure(100)
    plot(xh,hvals(i,:));
    hold on
    h1 = legend('lowest','low','medium','high','ultrahigh');
    xlabel('Pointcloud Signed Error (m)','fontsize',18)
    ylabel('Probability (%)','fontsize',18)
    title({'Pointcloud to Mesh Signed Error Probability', 'using different Dense Reconstruction Settings'},'fontsize',18);
    set(h1,'fontsize',16)   
    
    drawnow
   
end




