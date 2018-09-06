function [Ntotal,ncum] = calcNoverlap(percent_overlap,dodebug)

negativePercent = 100-percent_overlap;

N = 100/negativePercent;

Ntotal = 1 + ceil(N) * 2;

TOT=0; % only works when debug is on
if nargin>1
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
    
    title(sprintf('Number of Total Images = %.0f',Ntotal));
    ylabel('Image Number');
    %plot noverlap
    h2 = subplot(10,1,9:10);
    plot(TOT);
    set(gca,'xtick',[negativePercent:negativePercent:negativePercent*(Ntotal+N)])
    grid on
    
    % link axes
    linkaxes([h1 h2],'x');
    xlim([1 Ntotal*negativePercent+100+negativePercent])
    xlabel('Image Location');
    ylabel('Number of Overlaps');
end
%% Normalize TOT
ncum = TOT;

end