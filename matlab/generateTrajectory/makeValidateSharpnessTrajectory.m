function makeValidateSharpnessTrajectory(seed)
if nargin==0    
    seed = 1;
end

rng('default');
rng(seed)

tz = 1:1:100;

ncams = numel(tz);
tx = zeros(1,ncams);
ty = zeros(1,ncams);
rx = zeros(1,ncams);
ry = zeros(1,ncams);
rz = zeros(1,ncams);

t = 1:ncams;
makeTrajectory('trajectory_sharpnessTest.xml', 'sharpnessTest', tx, ty, tz, rx, ry, rz, t, 'ImagesRising', 3)

end