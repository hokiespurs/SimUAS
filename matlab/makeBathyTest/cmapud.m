function cmap = cmapud(N)
if nargin==0
   N=256; 
end
C{1} = [0 0 1];
P(1) = 0;

C{2} = [1 1 1];
P(2) = 0.5;

C{3} = [1 0 0];
P(3) = 1;

P = P*(N-1)/max(P);

R = cellfun(@(x) x(1),C);
G = cellfun(@(x) x(2),C);
B = cellfun(@(x) x(3),C);

cmap = nan(N,3);
cmap(:,1) = interp1(P,R,0:N-1);
cmap(:,2) = interp1(P,G,0:N-1);
cmap(:,3) = interp1(P,B,0:N-1);

end