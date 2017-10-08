%% Compute Line Between Two Points Using Snells Law
% constants
P1ALLX = -10:2:10;
P1ALLY = 10*ones(size(P1ALLX));
P2 = [0,-1];
N1 = 1.00;
N2 = 1.33;
WATERLEVEL = 0;
AX = [P1ALLX(1)-1 P1ALLX(end)+1 P2(2)-1 max(P1ALLX)+1];
AX2 = [-0.7 0.7 -1.2 0.2];
cmap = [lines(ceil(numel(P1ALLX)/2)); flipud(lines(floor(numel(P1ALLX)/2)))];

% plot water
f = figure(1);clf;hold on
patch([AX(1) AX(1) AX(2) AX(2)],[AX(3) WATERLEVEL WATERLEVEL AX(3)],...
    'k','FaceColor',[0 0 0],'FaceAlpha',0.1);
% plot camera locations
plot(P1ALLX,P1ALLY,'k^','markersize',15)
for i=1:numel(P1ALLX)
    P1 = [P1ALLX(i) P1ALLY(i)];
    % solve for x using minimization of time (fermat )using numeric derivatives
    tcalc = @(P,x,N) N.*sqrt((P(1)-x).^2 + (P(2)-WATERLEVEL).^2);
    fermat = @(x) tcalc(P1,x,N1) + tcalc(P2,x,N2);
    
    xval = fmincon(fermat,P1(1));
    
    % plot correct ray
    plot([P1(1) xval],[P1(2) WATERLEVEL],'k-')
    hold on
    plot([P2(1) xval],[P2(2) WATERLEVEL],'k-')
    axis equal
    
    % compute bad point
    vec1 = -[P1(1)-xval, P1(2)-WATERLEVEL];
    eigvec1 = vec1./sqrt(sum(vec1.^2));
    dfullvec = (P2(2)-WATERLEVEL)/eigvec1(2);
    
    P3 = [xval WATERLEVEL] + eigvec1*dfullvec;
    
    % plot bad vector
    plot([xval P3(1)],[WATERLEVEL P3(2)],'color',cmap(i,:))
end
% Save Images
grid on

% save PNG
xlabel('X','fontsize',14,'interpreter','latex');
ylabel('Y','fontsize',18,'interpreter','latex');
title('Perceieved Location Based on Water Refraction','fontsize',24,'interpreter','latex');

axis(AX)
saveas(f,'fullrefrac.png');
axis(AX2);
saveas(f,'zoomrefrac.png');

% save PDF
xlabel('X','fontsize',12,'interpreter','latex');
ylabel('Y','fontsize',12,'interpreter','latex');
title('Perceieved Location Based on Water Refraction','fontsize',14,'interpreter','latex');

axis(AX)
print(f,'fullrefrac.pdf','-dpdf','-fillpage')
axis(AX2);
print(f,'zoomrefrac.pdf','-dpdf','-fillpage')