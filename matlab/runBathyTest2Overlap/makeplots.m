%% consolidate data
REDO = false;
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\OVERSIDEB'; % Experiment Directory
PREFIX      = 'BATHYOVERSIDE';                  % Experiment Prefix
SETTING     = 'setting02';

if REDO || ~exist('data','var')
    [~,dnames] = dirname([EXPDIRNAME '/' PREFIX '*'],0);
    nFolders = numel(dnames);
    
    data = cell(1);
    starttime = now;
    ind=0;
    for iname = 1:nFolders
        dname = dnames{iname};
        fprintf('%s...',dname);
        matsavename = [dname '/proc/results/' SETTING '/pcproc.mat'];
        if exist(matsavename,'file')
            ind = ind+1;
            data{ind} = load(matsavename);
            data{ind}.sparse.grid = NaN;
        end
        loopStatus(starttime,iname,nFolders,1);
    end
end
%% PLOT DATA COLORED BY HFOV
% Organize Data
Yvariable = nan(numel(data),1);
hfov = nan(numel(data),1);
depth = nan(numel(data),1);
overlap = nan(numel(data),1);
for i=1:numel(data)
%    Yvariable(i) = data{i}.sparse.C.mean - data{i}.IV.seafloor;
    Yvariable(i) = data{i}.sparse.A.std; YSTR = 'Standard Deviation of Error (Sparse A)';

   hfov(i) = data{i}.IV.hfov;
   depth(i) = data{i}.IV.waterdepth;
   overlap(i) = data{i}.IV.nOverlap;
end

% Plot Error with HFOV on x axis, colored by overlap
X_hfovs = 20:10:80;
SP_depths = 0:4;
legendstr = {'50.0%','66.6%','75.0%','80.0%','83.3%','85.7%','87.5%'};
nImages = 2:8;

figure(1);clf; hold on
cmap = flipud(parula(numel(X_hfovs)));
for j=1:numel(SP_depths)
    for i=1:numel(nImages)
        subplot(2,3,j);hold on
        ind = overlap==nImages(i) & depth==SP_depths(j);
        plot(hfov(ind),Yvariable(ind),'.-','color',cmap(i,:),'linewidth',3)
    end
    title(sprintf('Depth = %g',SP_depths(j)),'fontsize',20)
    xlabel('Horizontal Field of View','fontsize',20);
    ylabel('Sparse Error in AOI','fontsize',20);
end
hleg = legend(legendstr,'fontsize',30);
title(hleg,'Overlap/Sidelap','fontsize',30);

%% Plot Error with overlap on x axis, colored by hfov
X_hfovs = 20:10:80;
SP_depths = 0:4;
legendstr = {'20°','30°','40°','50°','60°','70°','80°'};
nImages = 2:8;

figure(2);clf; hold on
cmap = flipud(parula(numel(X_hfovs)));
for j=1:numel(SP_depths)
    for i=1:numel(X_hfovs)
        subplot(2,3,j);hold on
        ind = hfov==X_hfovs(i) & depth==SP_depths(j);
        plot(overlap(ind),Yvariable(ind),'.-','color',cmap(i,:),'linewidth',3)
    end
    title(sprintf('Depth = %g',SP_depths(j)),'fontsize',20)
    xlabel('Number of Overlap Images','fontsize',20);
    ylabel('Sparse Error in AOI','fontsize',20);
end
hleg = legend(fliplr(legendstr),'fontsize',30);
title(hleg,'HFOV','fontsize',30);

% %% Plot Error with HFOV on x axis, colored by overlap
% X_hfovs = 20:10:80;
% SP_depths = 0:4;
% legendstr = {'2=50%','3=66.6%','4=75%','5=80%','6=83.3%','7=85.7%','8=87.5%'};
% nImages = 2:8;
% 
% figure(4);clf; hold on
% cmap = parula(numel(X_hfovs));
% for j=1:numel(SP_depths)
%     for i=1:numel(nImages)
%         subplot(2,4,i)
%         ind = overlap==nImages(i) & depth==SP_depths(j);
%         depthalt = [];
%         for k = find(ind)'
%             depthalt(end+1) = depth(k)./data{k}.traj.T(2,3);
%         end
%         scatter(depthalt,Yvariable(ind),100,hfov(ind),'filled')
%         title(sprintf('nImages = %g',nImages(i)),'fontsize',20)
%     end
%     xlabel('Horizontal Field of View','fontsize',20);
%     ylabel('Sparse Error in AOI','fontsize',20);
%     colorbar
% end


%% PCOLOR EVERYTHING
figure(3);clf
DEPTH = 1;
CAX = [-0.025 0.025];
legendstrX = {'20','30','40','50','60','70','80'};
legendstrY = {'2=50%','3=66.6%','4=75%','5=80%','6=83.3%','7=85.7%','8=87.5%'};

axg = axgrid(7,7,0.01,0.01,0.05,0.9,0.05,0.9);

for i=1:numel(nImages)
    for j=1:numel(X_hfovs)
        ind = nImages(i)==overlap & X_hfovs(j)==hfov & depth==DEPTH;
        if sum(ind)
           axg(i,j);
%              dz = data{ind}.dense.grid.zgmean - data{ind}.IV.seafloor;
%               dz = data{ind}.dense.grid.zgstd;
              dz = data{ind}.dense.grid.zgmax- data{ind}.dense.grid.zgmin;
            pcolor(data{ind}.dense.grid.xg,data{ind}.dense.grid.yg,dz);
           caxis(CAX);
           shading flat
           hold on
           plotRect([0 0],[12.5 12.5],'r')
           plotRect([0 0],[25 25],'m')
           plot(data{ind}.traj.T(:,1),data{ind}.traj.T(:,2),'r.')
           xticks([]);
           yticks([]);
           alt = data{ind}.traj.T(2,3);
%            text(-60,35,sprintf('%.1f',alt),'fontsize',20);
           axis equal;
           drawnow
        end
        if j==1
            ylabel(legendstrY{i},'fontsize',20);
        end
        if i==7
            xlabel(legendstrX{j},'fontsize',20);
        end
        
    end
end
bigtitle('Mean Bias (Water Depth = 1m)',0.5,0.925,'fontsize',30);
bigcolorbar([0.925 0.05 0.025 0.85],'Mean Bias','fontsize',30);
caxis(CAX);

%% Error vs Depth and HFOV
% Organize Data
Yvariable = nan(numel(data),1);
hfov = nan(numel(data),1);
depth = nan(numel(data),1);
overlap = nan(numel(data),1);
for i=1:numel(data)
%    Yvariable(i) = data{i}.sparse.C.mean - data{i}.IV.seafloor;
    Yvariable(i) = data{i}.sparse.A.std; YSTR = 'Standard Deviation of Error (Sparse A)';

   hfov(i) = data{i}.IV.hfov;
   depth(i) = data{i}.IV.waterdepth;
   overlap(i) = data{i}.IV.nOverlap;
end

%
X_hfovs = 20:10:80;
SP_depths = 0:4;
legendstr = {'$20^\circ$','$30^\circ$','$40^\circ$','$50^\circ$',...
    '$60^\circ$','$70^\circ$','$80^\circ$'};
nImages = 5;

figure(5);clf; hold on
cmap = parula(numel(X_hfovs)+1);

for i=1:numel(X_hfovs)
    ind = overlap==nImages & hfov==X_hfovs(i);
    plot(depth(ind),Yvariable(ind),'.-','color',cmap(i,:),...
        'linewidth',3,'markersize',40)
end

xticks([0 1 2 3 4]);


set(gca,'fontsize',24,'TickLabelInterpreter','latex')

xlabel('Water Depth (m)','fontsize',40,'interpreter','latex');
ylabel('Standard Deviation of Z Error (m)','fontsize',40,'interpreter','latex');

hleg = legend(legendstr,'fontsize',30,'interpreter','latex','location','northwest');
title(hleg,'HFOV','fontsize',30,'interpreter','latex');

title('Standard Deviation of Z Error','fontsize',45,'interpreter','latex');
grid on
%% Error vs Depth and HFOV
% Organize Data
Yvariable = nan(numel(data),1);
hfov = nan(numel(data),1);
depth = nan(numel(data),1);
overlap = nan(numel(data),1);
for i=1:numel(data)
    Yvariable(i) = data{i}.sparse.A.mean - data{i}.IV.seafloor;
%     Yvariable(i) = data{i}.sparse.A.std; YSTR = 'Standard Deviation of Error (Sparse A)';

   hfov(i) = data{i}.IV.hfov;
   depth(i) = data{i}.IV.waterdepth;
   overlap(i) = data{i}.IV.nOverlap;
end

%
X_hfovs = 20:10:80;
SP_depths = 0:4;
legendstr = {'$20^\circ$','$30^\circ$','$40^\circ$','$50^\circ$',...
    '$60^\circ$','$70^\circ$','$80^\circ$'};
nImages = 5;

figure(6);clf;hold on
cmap = parula(numel(X_hfovs)+1);

for i=1:numel(X_hfovs)
    ind = overlap==nImages & hfov==X_hfovs(i);
    plot(depth(ind),-Yvariable(ind),'.-','color',cmap(i,:),...
        'linewidth',3,'markersize',40)
end
xticks([0 1 2 3 4]);

set(gca,'fontsize',24,'TickLabelInterpreter','latex')

xlabel('Water Depth (m)','fontsize',40,'interpreter','latex');
ylabel('Absolute Z Error (m)','fontsize',40,'interpreter','latex');

hleg = legend(legendstr,'fontsize',30,'interpreter','latex','location','northwest');
title(hleg,'HFOV','fontsize',30,'interpreter','latex');

title('Sparse Absolute Mean Z Error','fontsize',45,'interpreter','latex');
grid on
ylim([0 0.7])

%% SUBPLOT FIGURE
Yvariable = nan(numel(data),1);
hfov = nan(numel(data),1);
depth = nan(numel(data),1);
overlap = nan(numel(data),1);
for i=1:numel(data)
%    Yvariable(i) = data{i}.sparse.C.mean - data{i}.IV.seafloor;
    Yvariable(i) = data{i}.sparse.A.std; YSTR = 'Standard Deviation of Error (Sparse A)';

   hfov(i) = data{i}.IV.hfov;
   depth(i) = data{i}.IV.waterdepth;
   overlap(i) = data{i}.IV.nOverlap;
end

%
X_hfovs = 20:10:80;
SP_depths = 0:4;
legendstr = {'$20^\circ$','$30^\circ$','$40^\circ$','$50^\circ$',...
    '$60^\circ$','$70^\circ$','$80^\circ$'};
nImages = 5;

figure(7);clf;
axg = axgrid(2,1,0.075,0.05,0.1,0.9,0.125,0.95);
axg(2);hold on
cmap = parula(numel(X_hfovs)+1);

for i=1:numel(X_hfovs)
    ind = overlap==nImages & hfov==X_hfovs(i);
    plot(depth(ind),Yvariable(ind),'.-','color',cmap(i,:),...
        'linewidth',3,'markersize',30)
end

xticks([0 1 2 3 4]);


set(gca,'fontsize',24,'TickLabelInterpreter','latex')

h2 = ylabel('Standard Deviation (m)','fontsize',28,'interpreter','latex');

hleg = legend(legendstr,'fontsize',28,'interpreter','latex','location','northwest');
title(hleg,'HFOV','fontsize',28,'interpreter','latex');

grid on

%
% Organize Data
Yvariable = nan(numel(data),1);
hfov = nan(numel(data),1);
depth = nan(numel(data),1);
overlap = nan(numel(data),1);
for i=1:numel(data)
    Yvariable(i) = data{i}.sparse.A.mean - data{i}.IV.seafloor;
%     Yvariable(i) = data{i}.sparse.A.std; YSTR = 'Standard Deviation of Error (Sparse A)';

   hfov(i) = data{i}.IV.hfov;
   depth(i) = data{i}.IV.waterdepth;
   overlap(i) = data{i}.IV.nOverlap;
end

X_hfovs = 20:10:80;
SP_depths = 0:4;
legendstr = {'$20^\circ$','$30^\circ$','$40^\circ$','$50^\circ$',...
    '$60^\circ$','$70^\circ$','$80^\circ$'};
nImages = 5;
xlabel('Water Depth (m)','fontsize',28,'interpreter','latex');

axg(1);hold on
cmap = parula(numel(X_hfovs)+1);

for i=1:numel(X_hfovs)
    ind = overlap==nImages & hfov==X_hfovs(i);
    plot(depth(ind),-Yvariable(ind),'.-','color',cmap(i,:),...
        'linewidth',3,'markersize',30)
end
xticks([0 1 2 3 4]);

set(gca,'fontsize',24,'TickLabelInterpreter','latex')

h1 = ylabel('Absolute Bias (m)','fontsize',28,'interpreter','latex');
set(h1,'Position',[h2.Position(1) h1.Position(2) h1.Position(3)])
hleg = legend(legendstr,'fontsize',28,'interpreter','latex','location','northwest');
title(hleg,'HFOV','fontsize',28,'interpreter','latex');

grid on
ylim([0 0.7])

bigtitle('Sparse Pointcloud Z Error within AOI',0.5,0.925,'fontsize',40,...
    'interpreter','latex')