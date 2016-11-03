function addHomePath(flag)
homePath = getHomePath(flag);
addpath(genpath([homePath '/matlab']))
end
