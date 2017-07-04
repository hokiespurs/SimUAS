function validatePhotogrammetry()
% must have run analyzeWarp and analyze Markers for each folder
homepath = getHomePath('SimUAS');
%% Get ValidateAcc* data
dnames = dirname([homepath '/data/validateAcc*'],1);

experiment.dx = [];
experiment.dy = [];
experiment.image_x = [];
experiment.image_y = [];
experiment.true_x = [];
experiment.true_y = [];
experiment.experimentIndex = [];
experiment.names = [];
for i=1:numel(dnames)
    experiment.names{i} = dnames{i};
    idat = load([dnames{i} '/proc/validatePhotogrammetry/rawdat2.mat']);
    close all;
    experiment.dx = [experiment.dx idat.dx(:)'];
    experiment.dy = [experiment.dy idat.dy(:)'];
    experiment.image_x = [experiment.dx idat.dx(:)'];
    experiment.image_y = [experiment.dy idat.dy(:)'];
    experiment.true_x = [experiment.dx idat.dx(:)'];
    experiment.true_y = [experiment.dy idat.dy(:)'];
    iInd = ones(size(idat.dy(:)')) * i;
    experiment.experimentIndex = [experiment.experimentIndex iInd];
    
    [~,fname,~]=fileparts(dnames{i});
    fprintf([fname '\n']);
%     fprintf('mean dX: \t %.4f\n',nanmean(idat.dx(:)));
%     fprintf('mean dY: \t %.4f\n',nanmean(idat.dy(:)));
%     fprintf('std dX: \t %.4f\n',nanstd(idat.dx(:)));
%     fprintf('std dY: \t %.4f\n',nanstd(idat.dy(:)));
%     fprintf('RMSE dX: \t %.4f\n',calcRmse(idat.dx));
%     fprintf('RMSE dY: \t %.4f\n',calcRmse(idat.dy));
%     fprintf('mean dR: \t %.4f\n',nanmean(idat.dr(:)));
%     fprintf('std dR: \t %.4f\n',nanstd(idat.dr(:)));  
%     fprintf('RMSE dR: \t %.4f\n',calcRmse(idat.dr));
    fprintf('%i \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \n',sum(~isnan(idat.dx(:))),...
        nanmean(idat.dx(:)),nanmean(idat.dy(:)),nanmean(idat.dr(:)),...
        nanstd(idat.dx(:)),nanstd(idat.dy(:)),nanstd(idat.dr(:)),...
        calcRmse(idat.dx(:)),calcRmse(idat.dy(:)),calcRmse(idat.dr(:)))
    fprintf('=============\n\n');
    DR{i} = idat.dr(:);
end

% %% Scatter plot All dx,dy 
% figure(11);clf;
% cmap = jet(numel(dnames));
% for i=1:numel(dnames)
%     ind = experiment.experimentIndex == i;
%     plot(experiment.dx(ind), experiment.dy(ind),'.','color',cmap(i,:));
%     hold on
% end

%% Get WarpImage Data
idat = load([homepath '/matlab/validatePhotogrammetry/warpImages/proc/data2.mat']);
close all
warp.dx = idat.dx;
warp.dy = idat.dy;
idat.dr = pythag(idat.dx,idat.dy);
    fprintf(['MyWarped\n']);
%     fprintf('mean dX: \t %.4f\n',nanmean(idat.dx(:)));
%     fprintf('mean dY: \t %.4f\n',nanmean(idat.dy(:)));
%     fprintf('std dX: \t %.4f\n',nanstd(idat.dx(:)));
%     fprintf('std dY: \t %.4f\n',nanstd(idat.dy(:)));
%     fprintf('RMSE dX: \t %.4f\n',calcRmse(idat.dx));
%     fprintf('RMSE dY: \t %.4f\n',calcRmse(idat.dy));
%     fprintf('mean dR: \t %.4f\n',nanmean(idat.dr(:)));
%     fprintf('std dR: \t %.4f\n',nanstd(idat.dr(:)));  
%     fprintf('RMSE dR: \t %.4f\n',calcRmse(idat.dr));
    fprintf('%i \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \t %.4f \n',sum(~isnan(idat.dx(:))),...
        nanmean(idat.dx(:)),nanmean(idat.dy(:)),nanmean(idat.dr(:)),...
        nanstd(idat.dx(:)),nanstd(idat.dy(:)),nanstd(idat.dr(:)),...
        calcRmse(idat.dx(:)),calcRmse(idat.dy(:)),calcRmse(idat.dr(:)))
    fprintf('=============\n\n');
    DRw = idat.dr(:);

%% KS Test
drall = [DR{1}; DR{3}; DR{5}; DR{7}; DR{10}];
[h,p] = kstest2(drall(~isnan(drall)),DRw(~isnan(DRw)),'Alpha',0.45);
    
%%
figure(10)
plot(experiment.dx,experiment.dy,'b.');
hold on
plot(warp.dx,warp.dy,'g.');
xlim([-1 1]);
ylim([-1 1]);

figure(11)
subplot 121
xgi = -1:0.05:1;dxgi = mean(diff(xgi));
ygi = -1:0.05:1;dygi = mean(diff(xgi));
H = heatmapscat(experiment.dx,experiment.dy,xgi,ygi);
npts = sum(~isnan(experiment.dx(:)));
pcolor(xgi-dxgi/2, ygi-dygi/2, H/npts*100);shading flat
axis equal;
h = colorbar;
caxis([0 10])
set(gca,'fontsize',14);
ylabel(h,'Percentage of Points in Bin','fontsize',20);
xlabel('Image X minus Projected X (pixels)','fontsize',18);
ylabel('Image Y minus Projected Y (pixels)','fontsize',18);
title({'Experiment Results','Heatmap of Image Points Minus Projected Points (pixels)'},'fontsize',20);

subplot 122
xgi = -1:0.05:1;dxgi = mean(diff(xgi));
ygi = -1:0.05:1;dygi = mean(diff(xgi));
H = heatmapscat(warp.dx,warp.dy,xgi,ygi);
npts = sum(~isnan(warp.dx(:)));
pcolor(xgi-dxgi/2, ygi-dygi/2, H/npts*100);shading flat
axis equal
h = colorbar;
caxis([0 10])
set(gca,'fontsize',14);
ylabel(h,'Percentage of Points in Bin','fontsize',20);
xlabel('Image X minus Projected X (pixels)','fontsize',18);
ylabel('Image Y minus Projected Y (pixels)','fontsize',18);
title({'Simulated Checkerboard Results','Heatmap of Image Points Minus Projected Points (pixels)'},'fontsize',20);

