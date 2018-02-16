function alt = calcAltForGSD(hfov,hpix,gsd)

% ifov = hfov/hpix;
% alt = gsd/2/tand(ifov/2);

alt = (gsd*hpix/2)/tand(hfov/2);

end