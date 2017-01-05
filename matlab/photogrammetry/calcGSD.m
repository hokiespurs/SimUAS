function gsd = calcGSD(hfov,hpix,alt)

ifov = hfov/hpix;

gsd = 2 * alt * tand(ifov/2);

end