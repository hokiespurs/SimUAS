function [x,y,z]=getlasptsTrim(laspts,XLIM,YLIM,ZLIM)

ind = isinrange(laspts.x,XLIM) & ...
    isinrange(laspts.y,YLIM) & ...
    isinrange(laspts.z,ZLIM);

x = laspts.x(ind);
y = laspts.y(ind);
z = laspts.z(ind);

end