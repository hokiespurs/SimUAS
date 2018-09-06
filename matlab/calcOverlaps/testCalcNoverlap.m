%% DEFINE BY NUMBER OF IMAGES
NIMAGES = 2:10;
OVERLAP = ((1-1./NIMAGES)*100);

%% DEFINE BY PERCENT OVERLAP
OVERLAP = 68; %comment out to use nimages;

[Ntotal,ncum] = calcNoverlap(OVERLAP,true);