function overlapPercent = calcOverlapPercent(fov,alt,dx)

footprintwidth = 2 * alt * tand(fov/2);

overlapPercent = 100 * (footprintwidth - dx) / footprintwidth;

end