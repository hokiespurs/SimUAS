function makeSharpnessFigs
%% read images
Itruthcircle = imread('C:\Users\Richie\Documents\GitHub\SimUAS\data\validatePointTruth\output\images\TestImage1.png');
Itruthcirclehollow = imread('C:\Users\Richie\Documents\GitHub\SimUAS\data\validatePointTruth\output\images\TestImage2.png');

Inoanticircle = imread('C:\Users\Richie\Documents\GitHub\SimUAS\data\validatePointNoAnti\output\images\TestImage1.png');
Inoanticirclehollow = imread('C:\Users\Richie\Documents\GitHub\SimUAS\data\validatePointNoAnti\output\images\TestImage2.png');

Ianticircle = imread('C:\Users\Richie\Documents\GitHub\SimUAS\data\validatePoint\output\images\TestImage1.png');
Ianticirclehollow = imread('C:\Users\Richie\Documents\GitHub\SimUAS\data\validatePoint\output\images\TestImage2.png');

%% Calculate Area for Light and Dark Areas
% Circle
Abox = 1;
Acircle = pi * (0.5)^2;
Ahollow = pi * (0.5)^2 - pi * (0.05)^2;

Alight = Acircle;
Adark = Abox - Acircle;

pixelValueCircle = Alight * 255 + Adark * 128

%hollow
Alight2 = Ahollow;
Adark2 = Abox-Ahollow;

pixelValueHollow = Alight2 * 255 + Adark2 * 128
%% Plot Truth Circle
figure(10)
subplot 231
maketruthplot(Itruthcircle,'Truth Circle');
[xg,yg]=meshgrid(1:5,1:5);
plotjitter(xg,yg,'x','r',5)
plotjitter(3,3,'.','g',15)
plot(3,3,'bo','markersize',15)
%% Plot Truth Circle Hollow
subplot 234
maketruthplot(Itruthcirclehollow,'Truth Hollow Circle');
plotjitter(xg,yg,'x','r',5)
plotjitter(3,3,'.','g',15)
plot(3,3,'bo','markersize',15)

%% Plot Aliased 
subplot 232 
makedataplot(Inoanticircle,'No Antialiasing Circle');

subplot 235
makedataplot(Inoanticirclehollow,'No Antialiasing Circle hollow');

subplot 233
makedataplot(Ianticircle,'Antialiasing Circle');

subplot 236
makedataplot(Ianticirclehollow,'Antialiasing Circle hollow');
%% Paper Figure
figure(11);clf
subplot 131
maketruthplot(Itruthcircle,'Scene Imaged');
set(gca,'fontsize',14)
set(gca,'xtick',[1 2 3 4 5]);
set(gca,'ytick',[1 2 3 4 5]);
xlabel('Virtual X Coordinate (Pixels)','fontsize',22,'interpreter','latex');
ylabel('Virtual Y Coordinate (Pixels)','fontsize',22,'interpreter','latex');
title('Scene with Pixel Coordinates Overlaid','fontsize',26,'interpreter','latex');
colorbar off

subplot 132
makedataplot(Inoanticircle,'No Antialiasing Enabled');
set(gca,'fontsize',14)
set(gca,'xtick',[1 2 3 4 5]);
set(gca,'ytick',[1 2 3 4 5]);
xlabel('X Coordinate (Pixels)','fontsize',22,'interpreter','latex');
ylabel('Y Coordinate (Pixels)','fontsize',22,'interpreter','latex');
title('No Antialiasing Enabled','fontsize',26,'interpreter','latex');
colorbar off

subplot 133
makedataplot(Ianticircle,'8 sample Antialiasing Enabled');
set(gca,'fontsize',14)
set(gca,'xtick',[1 2 3 4 5]);
set(gca,'ytick',[1 2 3 4 5]);
xlabel('X Coordinate (Pixels)','fontsize',22,'interpreter','latex');
ylabel('Y Coordinate (Pixels)','fontsize',22,'interpreter','latex');
title('8 sample Antialiasing Enabled','fontsize',26,'interpreter','latex');
c = colorbar;
ylabel(c,'8 Bit Grayscale Digital Number','fontsize',20)
set(c,'ytick',[0 50 100 150 200 255])
set(c,'Position',[0.92 0.315 0.02 0.4])
end

function plotjitter(x,y,symb,c,s)
jitterX=[1.500,0.875,1.250,0.625,1.000,1.375,0.750,1.125]-1;
jitterY=[1.500,1.375,1.250,1.125,1.000,0.875,0.750,0.625]-1;

for i=1:numel(x)
    plot(jitterX+x(i),jitterY+y(i),symb,'color',c,'markersize',s);
end

end

function maketruthplot(I,titlestr)
hold off
imagesc(((1:5000)+500)/1000,((1:5000)+500)/1000,rgb2gray(I));
hold on
plot([1 1 2 2 3 3 4 4]+0.5,[0 5 5 0 0 5 5 0]+0.5,'k');
plot([0 5 5 0 0 5 5 0]+0.5,[1 1 2 2 3 3 4 4]+0.5,'k');
plot([0 0 5 5 0]+0.5,[0 5 5 0 0]+0.5,'k')

axis equal
ylim([0.5 5.5])
xlim([0.5 5.5]);

caxis([0 255])
colormap('gray');
colorbar

title(titlestr)

end

function makedataplot(I,titlestr)
hold off
image(I)
hold on
plot([1 1 2 2 3 3 4 4]+0.5,[0 5 5 0 0 5 5 0]+0.5,'k');
plot([0 5 5 0 0 5 5 0]+0.5,[1 1 2 2 3 3 4 4]+0.5,'k');
plot([0 0 5 5 0]+0.5,[0 5 5 0 0]+0.5,'k')

%add text
for x = 1:5
    for y=1:5
        val = I(y,x);
        text(x,y,sprintf('%.0f',val),'color','k',...
            'horizontalAlignment','center',...
            'fontsize',20);
    end
end

axis equal
ylim([0.5 5.5])
xlim([0.5 5.5]);

caxis([0 255])
colormap('gray');
colorbar

title(titlestr)
end