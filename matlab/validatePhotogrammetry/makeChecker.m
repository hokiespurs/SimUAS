function [IcheckerRGB, xy] = makeChecker(x,y,npix)
%% 
maxdim = max([x,y]);
I = checkerboard(npix,ceil((maxdim+1)/2));
I = I(:,1:x*npix);
I = I(1:y*npix,:);

I(I>0.5)=255;

IcheckerRGB = uint8(repmat(I,[1,1,3]));

[xg, yg] = meshgrid(npix+1:npix:npix*(x-1)+1,npix+1:npix:npix*(y-1)+1);

xy = [xg(:) yg(:)];

% hold off
% [m,n,~]=size(IcheckerRGB);
% image((1:n)+0.5,(1:m)+0.5,IcheckerRGB);axis equal; drawnow;
% hold on
% plot(xy(:,1),xy(:,2),'g+','markersize',20);

end