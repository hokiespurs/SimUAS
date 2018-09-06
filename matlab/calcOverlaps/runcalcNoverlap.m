NIMAGES = 2:10;
OVERLAP = ((1-1./NIMAGES)*100);

niter = numel(OVERLAP);

cmap = parula(niter);
ind = 0;
figure(2);clf

for i=(OVERLAP)
ind = ind+1;
[Ntotal,ncum] = calcNoverlap(i,1);
figure(2);

plot((1:numel(ncum))-numel(ncum)/2-1,ncum,'color',cmap(ind,:),'linewidth',5);hold on
pause(0.5)
end

legend({num2str(OVERLAP')},'fontsize',48)