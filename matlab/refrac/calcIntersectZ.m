function P2 = calcIntersectZ(P1,P3,Z)
% compute the point along the line between P1 and P3 at elevation Z
eigenVec = (P3-P1)./sqrt(sum((P3-P1).^2));
dP1toZ = Z-P1(3);

P1toP2 = eigenVec .* (dP1toZ/eigenVec(3));

P2 = P1 + P1toP2;

end