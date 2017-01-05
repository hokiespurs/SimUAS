function [d,footprintwidth] = calcOverlapDistance(fov,alt,desiredPercent)

footprintwidth = 2 * alt * tand(fov/2);

d = -1 * (footprintwidth * (desiredPercent/100) - footprintwidth);

end