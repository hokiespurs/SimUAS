function homePath = getHomePath(flag)

curpath = pwd;
foldername = 1;
while ~isempty(foldername)
   [dirname, foldername, ~] = fileparts(curpath);
   if strcmp(foldername, flag)
      homePath = [dirname '/' foldername];
      break
   end
   curpath = dirname;
end
if isempty(foldername)
   error('cant find home path'); 
end
end