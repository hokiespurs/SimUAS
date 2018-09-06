%% consolidate data
REDO = false;
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\GPSQUALOVERLAP'; % Experiment Directory
PREFIX      = 'GPSQUALOVERLAP';                  % Experiment Prefix
SETTINGNUMS = 1:6;

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
            loopStatus(starttime,ind,numel(SETTINGNUMS)*nFolders);
        end
    end
end

%% Organize Data
for i=1:numel(data)
   YBias(i) = data{i}.dense.A.mean - data{i}.IV.seafloor;
   YStd(i) = data{i}.sparse.A.std;
   YFuzz(i) = nanmean(data{i}.dense.A.std(:));
   YNpts(i) = data{i}.sparse.A.npts;
   
   depth(i) = data{i}.IV.waterdepth;
   gpsacc(i) = data{i}.IV.gpsPSacc;
   gpsnoise(i) = data{i}.IV.gpsnoise;
   hfov(i) = data{i}.IV.hfov;
   camlock(i) = data{i}.IV.camlock;
   nOverlap(i) = data{i}.IV.nOverlap;
end

fprintf('UNIQUE VARIABLES\n')
printUniqueTable('depth',depth,6)
printUniqueTable('gpsacc',gpsacc,6)
printUniqueTable('gpsnoise',gpsnoise,6)
printUniqueTable('hfov',hfov,6)
printUniqueTable('camlock',camlock,6)
printUniqueTable('nOverlap',nOverlap,6)

%% Plot YBias as function of nOverlap
DEPTHS = 0:4;
LOCKEDCAM = true;
GPSNOISE = [0.01 0.03 0.05 0.1 0.5 1];
PSGPSACC = 10;
cmap = lines(numel(GPSNOISE));

figure(1);clf
for i=1:numel(DEPTHS)
    subplot(2,3,i)
    for ii=1:numel(GPSNOISE)
        ind = depth==DEPTHS(i) & camlock==LOCKEDCAM & gpsnoise==GPSNOISE(ii) & ...
            gpsacc == PSGPSACC;
        plot(nOverlap(ind),YBias(ind),'.-','color',cmap(ii,:));hold on
    end
    title(sprintf('DEPTH = %g',DEPTHS(i)),'fontsize',20,'interpreter','latex')
    xlim([1 6])
end
