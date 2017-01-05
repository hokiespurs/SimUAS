function p = plotlas3trim(laspts,XLIM,YLIM,ZLIM,c,s)

ind = isinrange(laspts.x,XLIM) & ...
    isinrange(laspts.y,YLIM) & ...
    isinrange(laspts.z,ZLIM);

p = plot3(laspts.x(ind),laspts.y(ind),laspts.z(ind),'.','color',c,'markersize',s);

end