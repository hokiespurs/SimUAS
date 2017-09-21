%% 
DOSAVEIMAGES = true;
CAMACC = 10;
for CAMACC = [0.01 0.5 10]
%%
if ~exist('REPROC','var')
    REPROC = true;
    foldername = 'F:\bathytestdata2';
    [~, dnames] = dirname([foldername '/BATHY*']);
    alldat = {};
    starttime = now;
    for i=1:numel(dnames)
        procsettingfiles = dirname('proc/settings/setting*.xml',0,dnames{i});
        for j=1:numel(procsettingfiles)
            procsetting = xml2struct(procsettingfiles{j});
            d = fileparts(procsettingfiles{j});
            outfolder = [d '/' procsetting.procsettings.export.Attributes.rootname];
            matname = [outfolder '/matlab/results.mat'];
            if exist(matname,'file')
                alldat{end+1}=load(matname);
            end
        end
        loopStatus(starttime,i,numel(dnames),1);
    end
end
%%
x=cell2mat(alldat);
alltestdata = [x.testdata];

truedepth = [alltestdata.truedepth];
altitude = [alltestdata.altitude];
hfov = [alltestdata.hfov];
meanError = [alltestdata.accuracy];
poscamacc = [alltestdata.poscamacc];
lockIO = [alltestdata.lockIO];
loadIO = [alltestdata.loadIO];
solveb1b2 = [alltestdata.solveb1b2];
meanErrorPercent = 100*meanError./truedepth; %percentage of depth

%%

%%
f1 = figure(1);
indGood = poscamacc==CAMACC;
ind = indGood;
scatter(truedepth(ind)./altitude(ind),hfov(ind),300,meanError(ind),'filled');
set(gca,'fontsize',16)
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');

c = colorbar;
ylabel(c,'Mean Depth Error (m)','fontsize',20,'interpreter','latex');

ylim([20 130]);
xlim([0 0.55]);

title(sprintf('Refraction Induced SfM Error (Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')
grid on
%%
f2 = figure(2);clf;hold on
fovvals = 30:10:120;
cmap = jet(numel(fovvals));
for i = 1:numel(fovvals)
   ind = round(hfov)==fovvals(i) & indGood; 
   plot(truedepth(ind)./altitude(ind),meanError(ind),'.-','color',cmap(i,:),'linewidth',3,'markersize',20)
end
set(gca,'fontsize',16)

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Mean Depth Error (m)','fontsize',20,'interpreter','latex');
ylim([-4 16])
title(sprintf('Refraction Induced SfM Error (Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')

c = colorbar;
colormap(jet(10));
caxis([30 120]);
ylabel(c,'Horizontal Field of View (degrees)','fontsize',20,'interpreter','latex');
grid on
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

%%
f3 = figure(3);clf;hold on
ratiovals = [0.01 0.05:0.05:0.5];
cmap = jet(numel(ratiovals));
for i = 1:numel(ratiovals)
   ind = truedepth./altitude==ratiovals(i) & indGood; 
   plot(hfov(ind),meanError(ind),'.-','color',cmap(i,:),'linewidth',3,'markersize',20)
end
set(gca,'fontsize',16)

ylabel('Mean Depth Error (m)','fontsize',20,'interpreter','latex');
xlabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');
ylim([-4 16])

xlim([20 130]);

title(sprintf('Refraction Induced SfM Error (Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')

c = colorbar;
colormap(jet(11));
caxis([0 .5]);
ylabel(c,'Depth/Altitude','fontsize',20,'interpreter','latex');
grid on
%%
f7 = figure(7);clf
ind = indGood;
y = hfov(ind);
x = truedepth(ind)./altitude(ind);
z = meanError(ind);
sf = fit([x(:), y(:)],z(:),'poly32');
[xg,yg]=meshgrid(0:0.005:0.55,20:.5:130);
zg = feval(sf,[xg(:) yg(:)]);
pcolor(xg,yg,reshape(zg,size(xg)));shading flat
colorbar
hold on
plot(x,y,'k.','markersize',10)
plot(x,y,'o','markersize',8,...
    'MarkerFaceColor','k','MarkerEdgeColor','w','LineWidth',2);
contour(xg,yg,reshape(zg,size(xg)),[-1:0.5:20],'color',[0.1 0.1 0.1]);shading flat

set(gca,'fontsize',16)
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');

c = colorbar;
ylabel(c,'Mean Depth Error (m)','fontsize',20,'interpreter','latex');

ylim([20 130]);
xlim([0 0.55]);

txtstr = '$C1x^3 + C2x^2y + C3xy^2 + C4x^2 +C5y^2 + C6xy + C7x + C8y + C9$';
title(sprintf('Refraction Induced SfM Error Fit (Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')
bigtitle(txtstr,0.5,0.87,'fontsize',24,'interpreter','latex','BackgroundColor','w');
grid on

%% 
f8 = figure(8);clf
%
ax1 = axes;
ind = indGood;
y = hfov(ind);
x = truedepth(ind)./altitude(ind);
z = meanError(ind);
sf = fit([x(:), y(:)],z(:),'poly32');
[xg,yg]=meshgrid(0:0.005:0.55,20:.5:130);
zg = feval(sf,[xg(:) yg(:)]);
pcolor(xg,yg,reshape(zg,size(xg)));shading flat

hold on
plot(x,y,'k.','markersize',10)
plot(x,y,'o','markersize',8,...
    'MarkerFaceColor','k','MarkerEdgeColor','w','LineWidth',2);
contour(xg,yg,reshape(zg,size(xg)),[-1:0.5:20],'color',[0.1 0.1 0.1]);shading flat

set(gca,'fontsize',16)
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');

ylim([20 130]);
xlim([0 0.55]);

ax2 = axes;
zinterp = feval(sf,[x(:) y(:)]);
scatter(x(:),y(:),300,z(:)-zinterp(:),'filled');
caxis([-0.5 0.5])

set(gca,'fontsize',16)
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');

ylim([20 130]);
xlim([0 0.55]);

linkaxes([ax1,ax2])
% Hide the top axes
ax2.Visible = 'off';
ax2.XTick = [];
ax2.YTick = [];
% Give each one its own colormap
colormap(ax1,flipud(gray(256)))
colormap(ax2,'jet')
% Then add colorbars and get everything lined up
set([ax1,ax2],'Position',[.12 .11 .685 .815]);
cb2 = colorbar(ax2,'Position',[.83 .11 .03 .815]);
title(ax1,sprintf('Refraction Induced SfM Error Fit Residuals(Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')
ylabel(cb2,'Fit Residuals (m)','fontsize',20,'interpreter','latex');

%%
f4 = figure(4);
ind = indGood;
scatter(truedepth(ind)./altitude(ind),hfov(ind),300,meanErrorPercent(ind),'filled');
set(gca,'fontsize',16)
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');

c = colorbar;
ylabel(c,'Percent Depth Error (%)','fontsize',20,'interpreter','latex');

ylim([20 130]);
xlim([0 0.55]);
caxis([-10 60]);

title(sprintf('Refraction Induced SfM Error Percent(Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')
grid on
%%
f5 = figure(5);clf;hold on
fovvals = 30:10:120;
cmap = jet(numel(fovvals));
for i = 1:numel(fovvals)
   ind = round(hfov)==fovvals(i) & indGood; 
   plot(truedepth(ind)./altitude(ind),meanErrorPercent(ind),'.-','color',cmap(i,:),'linewidth',3,'markersize',20)
end
set(gca,'fontsize',16)

xlabel('Depth/Altitude','fontsize',20,'interpreter','latex');
ylabel('Percent Depth Error (%)','fontsize',20,'interpreter','latex');
ylim([-20 70])

title(sprintf('Refraction Induced SfM Error Percent(Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')

c = colorbar;
colormap(jet(10));
caxis([30 120]);
ylabel(c,'Horizontal Field of View (degrees)','fontsize',20,'interpreter','latex');
grid on
set(gca,'Xtick',[0.01 0.05:0.05:0.55])

%%
f6 = figure(6);clf;hold on
ratiovals = [0.01 0.05:0.05:0.5];
cmap = jet(numel(ratiovals));
for i = 1:numel(ratiovals)
   ind = truedepth./altitude==ratiovals(i) & indGood; 
   plot(hfov(ind),meanErrorPercent(ind),'.-','color',cmap(i,:),'linewidth',3,'markersize',20)
end
set(gca,'fontsize',16)

ylabel('Percent Depth Error (%)','fontsize',20,'interpreter','latex');
xlabel('Horizontal FOV (degrees)','fontsize',20,'interpreter','latex');
ylim([-20 70])

xlim([20 130]);

title(sprintf('Refraction Induced SfM Error Percent(Camera Acc = %04.2f)',CAMACC),'fontsize',26,'interpreter','latex')

c = colorbar;
colormap(jet(11));
caxis([0 .5]);
ylabel(c,'Depth/Altitude','fontsize',20,'interpreter','latex');
grid on

%% Save em
fall = [f1 f2 f3 f4 f5 f6 f7 f8];
savenames = {'scattererror','ratioerror','foverror',...
    'scattererrorPercent','ratioerrorPercent','foverrorPercent',...
    'scattererrorpcolor','scattererrorresiduals'};

for i=1:numel(fall)
    set(fall(i),'Units','Normalize','Position',[0.1 0.1 0.8 0.8]);
    if DOSAVEIMAGES
        saveas(fall(i),[savenames{i} sprintf('_%04.2f.png',CAMACC)]);
    end
end
end
