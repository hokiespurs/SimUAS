function alt = calcAltForGSD(hfov,hpix,gsd)

ifov = hfov/hpix;

alt = gsd/2/tand(ifov/2);

end