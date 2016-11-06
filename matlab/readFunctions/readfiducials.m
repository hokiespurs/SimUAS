function Fiducials = readfiducials(fname)
rawdata = importdata(fname);
try
   Fiducials.names = rawdata.textdata(2:end,1);
   Fiducials.T = rawdata.data(:,1:3);
catch
   Fiducials.names = [];
   Fiducials.T = [];
end

end
