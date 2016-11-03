function [xd, yd] = calcDistortedCoords(xu, yu, xc, yc, k, p)
    % radial distortion
    r = sqrt((xu - xc) .^ 2 + (yu - yc) .^ 2);
    dx_radial = (xu - xc) .* (1 + (k(1) .* r .^ 2) + (k(2) .* r .^ 4) + (k(3) .* r .^ 6) + (k(4) .* r .^ 8));
    dy_radial = (yu - yc) .* (1 + (k(1) .* r .^ 2) + (k(2) .* r .^ 4) + (k(3) .* r .^ 6) + (k(4) .* r .^ 8));

    % tangential distortion
    dx_tangential = (p(1) .* (r.^2 + 2*(xu - xc).^2) + 2 .* p(2) .* (xu - xc) .* (yu - yc));
    dy_tangential = (p(2) .* (r.^2 + 2*(yu - yc).^2) + 2 .* p(1) .* (xu - xc) .* (yu - yc));

    % calculate distorted coordinate
    xd = xc + dx_radial + dx_tangential;
    yd = yc + dy_radial + dy_tangential;

end
