function t = timecalc(P1,P2,P3,N1,N2)
%Time of light ray traveling from
%  P1 to P2 through medium N1
%  +
%  P2 to P3 through medium N2
    t = N1 * distcalc(P1,P2) + N2 * distcalc(P2,P3);
end

function d = distcalc(P1,P2)
%pythagorean theorem
d = sqrt(sum((P1-P2).^2));
end
