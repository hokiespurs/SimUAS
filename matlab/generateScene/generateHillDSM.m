function [xg,yg,zg]=generateHillDSM(filename,ix,iy,zrange,meanz,filts,seed)
%% Open in Blender
% w - Remove Doubles
% tris to quads
% ctrl - alt - shift - M
% extrude down in z
% scale z 0
% grid fill bottom
% change view to uv 
% select all
% U - UV map basea  aad on view (bounds)
% Add default texture manually
% Save as Obj File
% Edit OBJ file to be named correctly
if nargin==6
   seed=1; 
end
%%
rng(seed);

[xg,yg]=meshgrid(ix,iy);
zg = rand(size(xg));
figure(10);hold off
surf(xg,yg,zg);
pause(2);
   
for i=1:numel(filts)
    h = ones(filts(i));
    n = conv2(ones(size(zg)),h,'same');
    zg = conv2(zg,h,'same')./n;
    zg = changeScale(zg,[min(zg(:)) max(zg(:))],[0,zrange]);
    
    figure(10);hold off
    surf(xg,yg,zg); axis equal;
    pause(2);
end


%%
zg = zg - mean(zg(:)) + meanz;
surf2stl(filename,xg,yg,zg);

end