function procOverlap2Mats
%% CONSTANTS
EXPDIRNAME  = 'O:\simUAS\EXPERIMENTS\OVERSIDEB'; % Experiment Directory
PREFIX      = 'BATHYOVERSIDE';                  % Experiment Prefix
SETTING     = 'setting03';
REPROC      = false;
[~,dnames] = dirname([EXPDIRNAME '/' PREFIX '*'],0);
nFolders = numel(dnames);

starttime = now;
for iname = 1:nFolders
   dname = dnames{iname};
   fprintf('%s...',dname);
   
   meta = importdata([dname '/input/meta.txt']);
   IV.hfov = meta.data(1);
   IV.waterdepth = meta.data(2);
   
   %FIX THIS BY REPROCESSING... RIGHT NOW DEPTH=0 is actually -0.01;
   if IV.waterdepth==0
       IV.seafloor = 0.01;
   else
       IV.seafloor = 0-IV.waterdepth;
   end
   
   IV.nOverlap = meta.data(3);
   IV.overlapPercent = ((1-1./meta.data(3))*100);
   % process pointcloud data
   sparselasname = [dname '/proc/results/' SETTING '/sparse.las'];
   denselasname  = [dname '/proc/results/' SETTING '/dense.las'];
   if exist(sparselasname,'file') && exist(denselasname,'file')
       matsavename = [dname '/proc/results/' SETTING '/pcproc.mat'];
       if exist(matsavename,'file') && ~REPROC
           fprintf('...already exists\n');
       else
           sparse = analyzepc(sparselasname);
           dense = analyzepc(denselasname);
           traj = readtrajectory([dname '/output/Trajectory.csv']);
           save(matsavename,'IV','sparse','dense','traj');
           fprintf('...saved\n');
       end
   else
       fprintf('...not processed yet\n');
   end
   loopStatus(starttime,iname,nFolders,1);
end

end

function pc = analyzepc(fname)
    s = lasdata(fname);
    RA = 12.5;
    RB = 25;
    regionA = s.x>=-RA & s.x<=RA & s.y>=-RA & s.y<=RA;
    regionB = s.x>=-RB & s.x<=RB & s.y>=-RB & s.y<=RB;
    regionC = true(size(s.x));
    
    pc.A = calcZstats(s.z,regionA);
    pc.B = calcZstats(s.z,regionB);
    pc.C = calcZstats(s.z,regionC);
    
    % grid all the data
    xi = -40:0.10:40;
    [xg, yg] = meshgrid(xi,xi);
    
    pc.grid.xg = xg;
    pc.grid.yg = yg;
    pc.grid.zgmean = roundgridfun(s.x,s.y,s.z,xg,yg,@mean);
    pc.grid.zgstd = roundgridfun(s.x,s.y,s.z,xg,yg,@std);
    pc.grid.zgmin = roundgridfun(s.x,s.y,s.z,xg,yg,@min);
    pc.grid.zgmax = roundgridfun(s.x,s.y,s.z,xg,yg,@max);
    pc.grid.zgmedian = roundgridfun(s.x,s.y,s.z,xg,yg,@median);
       
end

function x = calcZstats(z,ind)
    x.mean = mean(z(ind));
    x.std = std(z(ind));
    x.min = min(z(ind));
    x.max = max(z(ind));
    x.median = median(z(ind));
    x.npts = sum(ind);
end