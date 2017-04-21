load paper1fig.mat
%% Make Paper 1 Figure
figure(1);clf
a1=axes('Position',[0.07 0.05 0.5184 0.9]);
image(I);axis equal
set(a1,'fontsize',20)

ylim([1 3456])
rectangle('Position',[1907 453 160 160],'edgecolor','g','linewidth',5)
hold on
plot(-100,-100,'gs','linewidth',5,'markersize',20)
l1 = legend('Zoom');
set(l1,'fontsize',30);
ylabel('Y Coordinate (pixels)','interpreter','latex','fontsize',32)
xlabel('X Coordinate (pixels)','interpreter','latex','fontsize',32)

a2=axes('Position',[0.05+0.5184+0.025+0.03 0.05 0.3456 0.9]);
image(I);axis equal
set(a2,'fontsize',20)

hold on
plot(proj_x(:,ind),proj_y(:,ind),'g+','markersize',20,'linewidth',3);
plot(image_x(:,ind),image_y(:,ind),'r.','markersize',40);
xlim([1977 1987]);
ylim([523 533]);
l = legend('Photogrammetric Coordinate','Harris Corner Coordinate');
set(l,'fontsize',30)
xlabel('X Coordinate (pixels)','interpreter','latex','fontsize',32)

ax3 = axes('Position',[0 0 1 1]);
set(ax3,'visible','off');
t = title('Projected and Harris Corner Points','fontsize',40,'interpreter','latex');
set(t,'visible','on');
set(t,'Position',[0.5 0.84 0])