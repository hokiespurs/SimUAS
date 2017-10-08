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
CAMACC = 0.01;
REGION = [1 2 3];
SPARSEDENSE = 'sparse';
ERRORPERCENT = true;
%
allfovs  = [30 40 50 60 70 80 90 100 110 120];
allratio = [0.01 0.05 0.1 0.2 0.3 0.4 0.5];

allfovs  = unique(hfov);
allratio = unique(depthratio);


nfov = numel(allfovs);
nratio = numel(allratio);
f = figure(100);clf
axg = axgrid(nfov,nratio,0.03,0.01);

cmap = lines(5);
cmap(3:4,:)=[];

for i=1:nfov
    for j=1:nratio
        for k=1:numel(REGION)
            ind = hfov == allfovs(i) & depthratio == allratio(j) & poscamacc==CAMACC;
            h = S(ind).error(REGION(k)).(SPARSEDENSE).h;
            hval = S(ind).error(REGION(k)).(SPARSEDENSE).hval;
            
            if ERRORPERCENT
                hval = hval./S(ind).truedepth;
                xlim([0 0.6]);
                grid on
                xticks([0:0.1:0.6]);
            end
            
            axg(i,j);
            plot(hval,h,'.-','color',cmap(k,:));hold on
            set(gca,'ytick',[])
            axis tight
            drawnow
        end
    end
end
