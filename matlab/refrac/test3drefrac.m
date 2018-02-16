%% test 3d refrac
function test3drefrac(P1,Z,P3,N1,N2)
% CONSTANTS
[P1x,P1y] = meshgrid(-10:2:10,-10:2:10);
P1x = P1x(:);P1y = P1y(:);
P1z = 5*ones(size(P1x));

P1 = [P1x(:) P1y(:) P1z(:)];
P3 = [0,0,-4];
Z = 0;
N1 = 1.00;
N2 = 1.33;
%%
npts = size(P1,1);
f = figure(1);clf;hold on;
for i=1:npts
   P2 = numericalminfun(P1(i,:),P3,N1,N2,Z);
   P3p = calcPerceivedP3(P1(i,:),P2,P3);

   plotsegment3(P1(i,:),P2,'k-');
   hold on
   plotsegment3(P2,P3,'b-');
   plotsegment3(P2,P3p,'r-');
   view(90,0)
end
grid on
axis equal
patch([min(P1x) min(P1x) max(P1x) max(P1x)],...
      [min(P1y) max(P1y) max(P1y) min(P1y)],...
      [Z Z Z Z],'k','facecolor',[0 0 0],'faceAlpha',0.1);
axis([-2 2 -2 2 -6 2])
%% Save Movie
mov = VideoWriter('3drefrac.gif');
open(mov);
for i=1:90
    view(i,30)
   writeVideo(mov,getframe(f)); 
   saveas(f,sprintf('vid3d_%02.0f.png',i));
end
close(mov)
fnames = dirname('vid3d*');
makeMovie(fnames,'vid3d.gif',10,1);
end

function P2=numericalminfun(P1,P3,N1,N2,Z)
%% Compute the x,y, coordinates that minimize the timecalc function using
% numerical partial differentiation
THRESH =1e-8;
COUNTTHRESH = 5000;
STEP = eps^(1/3);
dtdx = inf;
dtdy = inf;
GAIN = .5;
P2 = calcIntersectZ(P1,P3,Z);
count = 1;
while (abs(dtdx)>THRESH || abs(dtdy)>THRESH) && count<COUNTTHRESH
    %%
    tx = [timecalc(P1,[P2(1)-STEP P2(2) P2(3)],P3,N1,N2),...
          timecalc(P1,[P2(1)+STEP P2(2) P2(3)],P3,N1,N2)];
    ty = [timecalc(P1,[P2(1) P2(2)-STEP P2(3)],P3,N1,N2), ...
          timecalc(P1,[P2(1) P2(2)+STEP P2(3)],P3,N1,N2)];
      
      dtdx  = diff(tx)/STEP;
      dtdy  = diff(ty)/STEP;
      
      P2(1)=P2(1)-dtdx*GAIN;
      P2(2)=P2(2)-dtdy*GAIN;

      % debug
%       figure(1)
%       subplot 121
%       plot(count,P2(1),'b.');hold on
%       subplot 122
%       plot(count,P2(2),'b.');hold on
      
      count = count+1;
end
if count>COUNTTHRESH
   error('didnt converge'); 
end

end

function plotsegment3(P1,P2,varargin)
plot3([P1(1) P2(1)],[P1(2) P2(2)],[P1(3) P2(3)],varargin{:})
end

function P3p = calcPerceivedP3(P1,P2,P3)
%%
eigenVec = (P1-P2)./sqrt(sum((P1-P2).^2));
distZ = P2(3)-P3(3);

scaleP2toP3p = -distZ/eigenVec(3);

P3p = P2 + eigenVec * scaleP2toP3p;
end