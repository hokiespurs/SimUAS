%% consolidate data
REDO = false;
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\GPSQUALTEST'; % Experiment Directory
PREFIX      = 'GPSQUAL';                  % Experiment Prefix
SETTINGNUMS = 1:70;

if REDO || ~exist('data','var')
    [~,dnames] = dirname([EXPDIRNAME '/' PREFIX '*'],0);
    nFolders = numel(dnames);
    
    data = cell(1);
    ind=0;
    starttime = now;
    for i=1:numel(SETTINGNUMS)
        SETTING     = sprintf('setting%02g',i);
        for iname = 1:nFolders
            dname = dnames{iname};
            fprintf('%s...',[dname '\' SETTING]);
            matsavename = [dname '/proc/results/' SETTING '/pcproc.mat'];
            if exist(matsavename,'file')
                ind = ind+1;
                data{ind} = load(matsavename);
                data{ind}.sparse.grid = NaN;
                fprintf('loaded\n');
            else
                fprintf('doesnt exist\n')
            end
        end
        loopStatus(starttime,i,numel(SETTINGNUMS));
    end
end
%% Organize Data
for i=1:numel(data)
   YBias(i) = data{i}.sparse.A.mean - data{i}.IV.seafloor;
   YStd(i) = data{i}.sparse.A.std;

   depth(i) = data{i}.IV.waterdepth;
   gpsacc(i) = data{i}.IV.gpsacc;
end

%% Plot Data Colored by Accuracy, subplot for depths
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(8);
figure(1);clf
for i = 1:numel(DEPTHS)
    subplot(2,3,i);hold on
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        plot(gpsacc(ind),YBias(ind),'b.-','markersize',10)

    end
    title(sprintf('Water Depth = %.1f',DEPTHS(i)),'fontsize',18,'interpreter','latex');
    xlim([-0.5 2.5]);grid on
    xlabel('GPS Accuracy (m)','interpreter','latex','fontsize',16)
    ylabel('Z Bias (m)','interpreter','latex','fontsize',16)
end
bigtitle('Z Bias',0.5,0.95,'fontsize',32,'interpreter','latex');

%% Plot Data Based on STD of Surface for Each Simulation
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(8);
figure(2);clf
for i = 1:numel(DEPTHS)
    subplot(2,3,i);hold on
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        plot(gpsacc(ind),YStd(ind),'b.-','markersize',10)

    end
    title(sprintf('Water Depth = %.1f',DEPTHS(i)),'fontsize',18,'interpreter','latex');
    xlim([-0.5 2.5]);grid on
    xlabel('GPS Accuracy (m)','interpreter','latex','fontsize',16)
    ylabel('Z STD (m)','interpreter','latex','fontsize',16)
end
bigtitle('Z STD',0.5,0.95,'fontsize',32,'interpreter','latex')

%% Plot Data Based on STD of repeat noise to experiment
% eg. how much does the noise affect the bias
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(6);
figure(3);clf
for i = 1:numel(DEPTHS)
    stdofbias = nan(numel(GPSACC),1);
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        stdofbias(j) = std(YBias(ind));
    end
    plot(GPSACC,stdofbias,'.-','markersize',10,'color',cmap(i,:));hold on
    xlim([-0.5 2.5]);grid on
    xlabel('GPS Accuracy (m)','interpreter','latex','fontsize',16)
    ylabel('Z STD of Bias(m)','interpreter','latex','fontsize',16)
end
legend({'0','1','2','3','4'},'fontsize',16,'interpreter','latex')
bigtitle('Z STD of Bias for each noise level',0.5,0.95,'fontsize',32,'interpreter','latex')

%% Try Bar instad of line for bias
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(8);
figure(4);clf
for i = 1:numel(DEPTHS)
    subplot(2,3,i);hold on
    dat = nan(7,10);
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        dat(j,1:sum(ind)) = YBias(ind);
    end
    bar(dat);
    title(sprintf('Water Depth = %.1f',DEPTHS(i)),'fontsize',18,'interpreter','latex');
    grid on
    xticks([1 2 3 4 5 6 7]);
    xticklabels({'0','1','3','5','10','50','200'})
    xlabel('GPS Accuracy (cm)','interpreter','latex','fontsize',16)
    ylabel('Z Bias (m)','interpreter','latex','fontsize',16)
end
bigtitle('Z Bias',0.5,0.95,'fontsize',32,'interpreter','latex');

%% Plot Data Based on Mean Bias of experiment
% eg. how much does the noise affect the bias
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(6);
figure(5);clf
for i = 1:numel(DEPTHS)
    meanofbias = nan(numel(GPSACC),1);
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        meanofbias(j) = mean(YBias(ind));
    end
    plot(GPSACC,meanofbias,'.-','markersize',10,'color',cmap(i,:),...
        'linewidth',2,'markersize',15);
    hold on
    xlim([-0.5 2.5]);grid on
    xlabel('GPS Accuracy (m)','interpreter','latex','fontsize',16)
    ylabel('Mean Z Bias(m)','interpreter','latex','fontsize',16)
end
legend({'0','1','2','3','4'},'fontsize',16,'interpreter','latex')
bigtitle('Mean Z Bias',0.5,0.95,'fontsize',32,'interpreter','latex')
%% Plot Data Based on Mean Bias of experiment
% eg. how much does the noise affect the bias
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(6);
figure(6);clf
for i = 1:numel(DEPTHS)
    meanofbias = nan(numel(GPSACC),1);
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        meanofbias(j) = mean(YBias(ind));
    end
    plot(1:numel(GPSACC),meanofbias,'.-','markersize',10,'color',cmap(i,:),...
        'linewidth',2,'markersize',15);
    hold on
    xlim([0 8]);grid on
    xlabel('GPS Accuracy (cm)','interpreter','latex','fontsize',16)
    ylabel('Mean Z Bias(m)','interpreter','latex','fontsize',16)
end
xticks([1 2 3 4 5 6 7]);
xticklabels({'0','1','3','5','10','50','200'})
hleg = legend({'0','1','2','3','4'},'fontsize',20,'interpreter','latex',...
    'location','northeast');
title(hleg,'Water Depth','fontsize',20);
bigtitle('Mean Z Bias',0.5,0.92,'fontsize',32,'interpreter','latex')
%% Plot Data Based on Mean STD of experiment
% eg. how much does the noise affect the bias
DEPTHS = 0:4;
GPSACC = [0 0.01 0.03 0.05 0.1 0.5 2];

cmap = parula(6);
figure(7);clf
for i = 1:numel(DEPTHS)
    meanofstd = nan(numel(GPSACC),1);
    for j = 1:numel(GPSACC)
        ind = depth==DEPTHS(i) & gpsacc==GPSACC(j);
        meanofstd(j) = mean(YStd(ind));
    end
    plot(1:numel(GPSACC),meanofstd,'.-','markersize',10,'color',cmap(i,:),...
        'linewidth',2,'markersize',15);
    hold on
    set(gca,'fontsize',16,'TickLabelInterpreter','latex')
end
xlim([0 8]);grid on
xlabel('GPS Accuracy (cm)','interpreter','latex','fontsize',16)
ylabel('Mean Z Bias(m)','interpreter','latex','fontsize',16)
xticks([1 2 3 4 5 6 7]);
xticklabels({'0','1','3','5','10','50','200'})
hleg = legend({'0','1','2','3','4'},'fontsize',20,'interpreter','latex',...
    'location','northwest');
title(hleg,'Water Depth','fontsize',20);

bigtitle('Mean Z Std',0.5,0.92,'fontsize',32,'interpreter','latex')
