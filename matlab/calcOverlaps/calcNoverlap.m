function [ncum,Ntotal] = calcNoverlap(percent_overlap)

negativePercent = 100-percent_overlap;

N = 100/negativePercent;

Ntotal = 1 + ceil(N) * 2;

%% Debug Plot
TOT = zeros(1,ceil(Ntotal*negativePercent+100+negativePercent));

figure(1);clf;
% plot overlap regions
h1 = subplot(10,1,1:8);
hold on

for i=1:Ntotal
   plot([i*negativePercent  i*negativePercent+100],[i-ceil(N)-1 i-ceil(N)-1],'.-');
   plot(i*negativePercent+50,i-ceil(N)-1,'*');
   ind = ((1:numel(TOT))>=i*negativePercent) & ((1:numel(TOT))<i*negativePercent+100);
   TOT = TOT + ind;
end
grid on
ylim([-ceil(N)-1 ceil(N)+1]);
set(gca,'xtick',[negativePercent:negativePercent:negativePercent*(Ntotal+N)])

title(sprintf('Number of Overlap = %.0f',Ntotal));

%plot noverlap
h2 = subplot(10,1,9:10);
plot(TOT);
set(gca,'xtick',[negativePercent:negativePercent:negativePercent*(Ntotal+N)])
grid on

% link axes
linkaxes([h1 h2],'x');
xlim([1 Ntotal*negativePercent+100+negativePercent])

%% Normalize TOT
ncum = TOT;

end