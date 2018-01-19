NIMAGES = 2:10;
OVERLAP = ((1-1./NIMAGES)*100);

niter = numel(OVERLAP);

cmap = parula(niter);
ind = 0;
figure(2);clf

for i=(OVERLAP)
ind = ind+1;
[ncum,Ntotal] = calcNoverlap(i);
figure(2);
plot(ncum,'color',cmap(ind,:),'linewidth',5);hold on
end

legend({num2str(OVERLAP')},'fontsize',48)