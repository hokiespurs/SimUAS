function makeValidateAccuracyTrajectory(seed)
if nargin==0    
    seed = 1;
end

rng('default');
rng(seed)
NCAMS = 100;

doRandRoomTrajectory('trajectory_randCheckerRoom1.xml', NCAMS)
doRandRoomTrajectory('trajectory_randCheckerRoom2.xml', NCAMS)
doRandRoomTrajectory('trajectory_randCheckerRoom3.xml', NCAMS)
doRandRoomTrajectory('trajectory_randCheckerRoom4.xml', NCAMS)
doRandRoomTrajectory('trajectory_randCheckerRoom5.xml', NCAMS)

end

function doRandRoomTrajectory(fname, NCAMS)

iTheta = rand(NCAMS,1)*360;
iPhi = rand(NCAMS,1)*180;
iRoll = rand(NCAMS,1)*360;

x = (rand(NCAMS,1)*8)-4;
y = (rand(NCAMS,1)*8)-4;
z = (rand(NCAMS,1)*8)-4;

rx = iRoll;
ry = iPhi;
rz = iTheta;
t = 1:NCAMS;
makeTrajectory(fname, 'randomcalroom', x, y, z, rx, ry, rz, t, 'CheckerRoomImage', 3)



end