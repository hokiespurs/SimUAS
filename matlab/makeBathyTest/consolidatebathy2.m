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

%% Organize Data
S = [];
for i=1:numel(alldat)
   S(i).truedepth = alldat{i}.testdata.truedepth;
   S(i).altitude  = alldat{i}.testdata.altitude;
   S(i).hfov      = alldat{i}.testdata.hfov;
   S(i).poscamacc = alldat{i}.testdata.poscamacc;
   S(i).lockIO    = alldat{i}.testdata.lockIO;
   REGIONNAMES = {'RegionA','RegionB','RegionC'};
   for j = 1:numel(REGIONNAMES)
       S(i).error(j).sparse.u   = alldat{i}.sparse.(REGIONNAMES{j}).u;
       S(i).error(j).sparse.v   = alldat{i}.sparse.(REGIONNAMES{j}).v;
       S(i).error(j).sparse.r   = alldat{i}.sparse.(REGIONNAMES{j}).r;
       S(i).error(j).sparse.med = alldat{i}.sparse.(REGIONNAMES{j}).med;
       S(i).error(j).sparse.h   = alldat{i}.sparse.(REGIONNAMES{j}).h;
       S(i).error(j).sparse.hval= alldat{i}.sparse.(REGIONNAMES{j}).hval;
       S(i).error(j).sparse.npts= alldat{i}.sparse.(REGIONNAMES{j}).npts;

       S(i).error(j).dense.u   = alldat{i}.dense.(REGIONNAMES{j}).u;
       S(i).error(j).dense.v   = alldat{i}.dense.(REGIONNAMES{j}).v;
       S(i).error(j).dense.r   = alldat{i}.dense.(REGIONNAMES{j}).r;
       S(i).error(j).dense.med = alldat{i}.dense.(REGIONNAMES{j}).med;
       S(i).error(j).dense.h   = alldat{i}.dense.(REGIONNAMES{j}).h;
       S(i).error(j).dense.hval= alldat{i}.dense.(REGIONNAMES{j}).hval;
       S(i).error(j).dense.npts= alldat{i}.dense.(REGIONNAMES{j}).npts;
   end
end
clearvars -except S alldat
hfov       = round([S(:).hfov]);
poscamacc  = [S(:).poscamacc];
depthratio = [S(:).truedepth]./[S(:).altitude];
%% Make Plots
% Constants
REGION = [1 2 3];
SPARSEDENSE = 'sparse';
ERRORPERCENT = true;
FIXXLIM = [-50 50];

%
allfovs  = unique(hfov);
allratio = unique(depthratio);
allcamacc = [0.01 0.5 10];
allsparsedense = {'sparse','dense'};

nfov    = numel(allfovs);
nratio  = numel(allratio);
ncamacc = numel(allcamacc);

axg = axgrid(nfov,nratio,0.02/2,0.01/2);

cmap = lines(5);
cmap(3:4,:)=[];
for isparsedense = 1:2
    SPARSEDENSE = allsparsedense{isparsedense};
    for ifig = 1:ncamacc
        f = figure(100+ifig);clf
        CAMACC = allcamacc(ifig);
        for i=1:nfov
            for j=1:nratio
                axg(nfov+1-i,nratio+1-j);
                for k=1:numel(REGION)
                    ind = hfov == allfovs(i) & depthratio == allratio(j) & poscamacc==CAMACC;
                    h = S(ind).error(REGION(k)).(SPARSEDENSE).h;
                    hval = S(ind).error(REGION(k)).(SPARSEDENSE).hval;
                    
                    if ERRORPERCENT
                        hval = 100*hval./S(ind).truedepth;
                        grid on
                    end
                    
                    plot(hval,h,'.-','color',cmap(k,:));hold on
                    set(gca,'ytick',[])
                    axis tight
                    if ~isempty(FIXXLIM)
                        xlim(FIXXLIM);
                        xticks(linspace(FIXXLIM(1),FIXXLIM(2),11))
                        set(gca,'XTickLabel',cell(11,1));
                        plot([0,0],[0,max(get(gca,'ylim'))],'k')
                    end
                    
                    if j==nratio
                        ylabel(sprintf('%.0f',allfovs(i)));
                    end
                    if i==1
                        xlabel(sprintf('%.1f',1/allratio(j)));
                    end
                    drawnow
                end
            end
        end
        bigtitle(sprintf('%s Percent Error (EO Accuracy = %.2fm)',SPARSEDENSE, CAMACC),0.5,0.95,'fontsize',26,'interpreter','latex');
        saveas(f,sprintf('%sPercentError_%.2f.png',SPARSEDENSE, CAMACC));
    end
end