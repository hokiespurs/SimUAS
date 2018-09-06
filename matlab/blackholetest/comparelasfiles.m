%%
DNAME = 'O:\simUAS\EXPERIMENTS\TOPOHOLE\TOPOFIELDHOLE\proc\results\setting02s\las\*.asc';
ORTHO = 'O:\simUAS\EXPERIMENTS\TOPOHOLE\TOPOFIELDHOLE\output\model\ortho\ortho1.tif';
XGI = -100:0.25:100;
YGI = -100:0.25:100;
ORDER = [16 13 14 15 8 5 6 7 4 1 2 3 12 9 10 11] ;
CAXLIM = [-0.055 0.055];
%%
fnames = dirname(DNAME);

CMAP = [ ...
    94    79   162
    50   136   189
    102   194   165
    171   221   164
    230   245   152
    255   255   191
    254   224   139
    253   174    97
    244   109    67
    213    62    79
    158     1    66  ] / 255;

starttime=now;
for i=1:numel(fnames)
    [~,fname,~] = fileparts(fnames{i});
    dat = importdata(fnames{i});
    [x,y,z,r,g,b,dz]=v2vars(dat.data(:,[1,2,3,4 5 6 10]),2);
    zg{i} = roundgridfun(x,y,dz,XGI,YGI,@mean);
    loopStatus(starttime,i,numel(fnames),1);
end


%%
figure(1);clf
axg = axgrid(4,4,0.05,0.05,0.1,0.9,0.1,0.85);
for i=1:numel(fnames)
    axg(ORDER(i));
    pcolor(XGI,YGI,zg{i});shading flat
    caxis(CAXLIM);
    colormap(CMAP);
    grid on
    
%     [~,fname,~] = fileparts(fnames{i});
%     x = strsplit(fname,'_');
%     fname = [x{2} '-' x{3}];
%     title(fname)
    
    axis equal;
    
    drawnow;
    xlim([-20 20]);
    ylim([-20 20]);
    set(gca,'fontsize',14)
    xticks([-20:10:20]);
    yticks([-20:10:20]);
end

%
axg(1)
title('Disabled','fontsize',30,'interpreter','latex')
axg(2)
title('Mild','fontsize',30,'interpreter','latex')
axg(3)
title('Moderate','fontsize',30,'interpreter','latex')
axg(4)
title('Aggresive','fontsize',30,'interpreter','latex')

axg(1)
ylabel('Lowest','fontsize',30,'interpreter','latex')
axg(5)
ylabel('Low','fontsize',30,'interpreter','latex')
axg(9)
ylabel('Medium','fontsize',30,'interpreter','latex')
axg(13)
ylabel('High','fontsize',30,'interpreter','latex')

bigcolorbar([0.875 0.1 0.05 0.8],'Signed Error (m)','fontsize',24,'interpreter','latex');
caxis(CAXLIM);

set(gca,'fontsize',16)

%% Make Gif
DOGIF = false;
if DOGIF
    SAVEXY = [-25 25];
    
    Iortho = flipud(imread(ORTHO));
    orthoxy = [-50 50];
    
    Idiff = zg{i};
    Idiffxy = [XGI(1) XGI(end)];
    %%
    for i=1:16
        f3 = figure(3);clf;
        axes('position',[0.1 0.1 0.75 0.75])
        image(orthoxy,orthoxy,Iortho(:,:,1:3));
        xlabel('Easting (m)','fontsize',24,'interpreter','latex');
        ylabel('Northing (m)','fontsize',24,'interpreter','latex');
        title('Groundtruth Orthophoto','fontsize',30,'interpreter','latex');
        grid on
        axis equal
        xlim([-25 25]);
        ylim([-25 25]);
        set(gca,'ydir','normal');
        pause(1)
        h = bigcolorbar([0.85 0.1 0.05 0.75],'Elevation Difference (m)','fontsize',16,'interpreter','latex');
        set(gca,'fontsize',14)
        caxis([-0.055 0.055]);
        colormap(CMAP)
        pause(1)
        saveas(f3,[x{2} x{3} '.png']);
        saveas(f3,'truth.png');
        %%
        clf
        axes('position',[0.1 0.1 0.75 0.75])
        
        [~,fname,~] = fileparts(fnames{i});
        x = strsplit(fname,'_');
        fname = [x{2} '-' x{3}];
        title(fname)
        
        val = num2ind(zg{i},[-0.055 0.055],11);
        RGBzg = ind2rgb(val,CMAP);
        
        indwhite = cat(3,isnan(zg{i}),isnan(zg{i}),isnan(zg{i}));
        RGBzg(indwhite)=255;
        
        image(Idiffxy,Idiffxy,RGBzg);
        xlabel('Easting (m)','fontsize',24,'interpreter','latex');
        ylabel('Northing (m)','fontsize',24,'interpreter','latex');
        title({['Dense: ' x{2}],['Filtering: ' x{3}]},'fontsize',30,'interpreter','latex');
        grid on
        axis equal
        xlim([-25 25]);
        ylim([-25 25]);
        set(gca,'ydir','normal');
        
        drawnow
        %%
        h = bigcolorbar([0.85 0.1 0.05 0.75],'Elevation Difference (m)','fontsize',16,'interpreter','latex');
        set(gca,'fontsize',14)
        caxis([-0.055 0.055]);
        colormap(CMAP)
        pause(1)
        saveas(f3,[x{2} x{3} '.png']);
        
        %% Make Gif
        makeMovie({'truth.png',[x{2} x{3} '.png']},[x{2} x{3} '.gif'],0.5,1);
    end
end




