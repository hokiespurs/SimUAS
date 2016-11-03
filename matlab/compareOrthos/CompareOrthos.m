%compare orthos
%% Load Data
I1 = imread('C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\demobeaver\proc\Ortho1.tif');
I2 = imread('C:\Users\Richie\Documents\GitHub\BlenderPythonTest\data\demobeaver\proc\dummy_bad.tif');
I1 = I1(:,:,1:3);
I2 = I2(:,:,1:3);
I1 = gpuArray(I1);
I2 = gpuArray(I2);
[D, moving_reg] = imregdemons(rgb2gray(I2(:,:,1:3)),rgb2gray(I1(:,:,1:3)));

%%
cmap(:,1) = (interp1([0,127,255],[0, 1, 1],0:255));
cmap(:,2) = (interp1([0,127,255],[0, 1, 0],0:255));
cmap(:,3) = (interp1([0,127,255],[1, 1, 0],0:255));

figure(2)
% Plot Truth Orthophoto
ax1 = subplot(2,2,1);
image(I1);
title('Truth Image')

% Plot Image 2 from Photoscan
ax2 = subplot(2,2,2);
image(I2);
title('Photoscan Generated Image');

% Plot Calculated X Shift
ax3 = subplot(2,2,3);
pcolor(D(:,:,1));shading flat
caxis([-20 20])
colorbar
colormap(cmap)
title('X Shift');

% Plot Calculated Y Shift
ax4 = subplot(2,2,4);
pcolor(D(:,:,2));shading flat
caxis([-20 20])
colorbar
colormap(cmap)
title('Y Shift');

%Link axes
linkaxes([ax1,ax2,ax3,ax4])