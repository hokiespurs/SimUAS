function Control = readcontrol(fname)
rawdata = importdata(fname);
if isstruct(rawdata)
    Control.names = rawdata.textdata(2:end,1);
    Control.T = rawdata.data(:,1:3);
else
    Control.names{1} = '';
    Control.T = [0 0 0];
    warning('No Control Data Found')
end
end
