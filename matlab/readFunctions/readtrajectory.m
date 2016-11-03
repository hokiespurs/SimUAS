function Trajectory = readtrajectory(fname)
rawdata = importdata(fname);
Trajectory.names = rawdata.textdata(2:end,1);
Trajectory.T = rawdata.data(:,1:3);
Trajectory.R = rawdata.data(:,4:6);

end
