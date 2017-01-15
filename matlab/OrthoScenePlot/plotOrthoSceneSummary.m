%%
ORTHO = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\topofield2\output\model\ortho\whole.tif';
TRAJECTORY = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\topofield2\output\Trajectory.csv';
GCP = 'C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\topofield2\output\xyzcontrol.csv';
%%
I = imread(ORTHO);
I(:,:,4)=[];

control = readcontrol(GCP);
trajectory = readtrajectory(TRAJECTORY);
%%
figure(1);clf
image(-100:0.02:100,-100:0.02:100,I);
hold on
rectangle('Position',[-50 -50 100 100],'edgeColor','k','linewidth',3);
plot(inf,inf,'ks','markersize',20,'linewidth',3);
plot(control.T(:,1),control.T(:,2),'ks','markersize',10,'markerFaceColor','r')
plot(trajectory.T(:,1),trajectory.T(:,2),'ko','markersize',10,'markerFaceColor','y')
ind = [1:11 22:-1:12 23:33 44:-1:34 45:55 66:-1:56 67:77];
plot(trajectory.T(ind,1),trajectory.T(ind,2),'y','linewidth',3)
plot(trajectory.T(:,1),trajectory.T(:,2),'ko','markersize',10,'markerFaceColor','y')
axis equal
xlim([-75 75]);
ylim([-75 75]);

set(gca,'fontsize',16)
xlabel('X Coordinate(m)','fontsize',18);
ylabel('Y Coordinate(m)','fontsize',18);
title('Experiment Camera and GCP Positions','fontsize',24)


[h1,icons]= legend('Area of Interest','Ground Control Points','Camera Locations');

set(h1,'fontsize',16)
for i=1:3
   icons(i).FontSize = 16; 
end