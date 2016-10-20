function imnames=dirname(foldername,returnFolders)
%% This function returns a cell array of files using the dir command
% This just makes it easier so you dont have to write a for loop to extract
% the filenames into a cell array
if nargin==1
    returnFolders=0;
end

fnames=dir(foldername);
[directortName,~,~]=fileparts(foldername);
imnames=[];
numgoodfiles=0;
for i=1:numel(fnames)
    if isdir([directortName '/' fnames(i).name]) && returnFolders && ~strcmp(fnames(i).name,'.') && ~strcmp(fnames(i).name,'..')
        numgoodfiles=numgoodfiles+1;
        imnames{numgoodfiles}=[directortName '/' fnames(i).name];
    elseif ~isdir([directortName '/' fnames(i).name]) && ~returnFolders
        numgoodfiles=numgoodfiles+1;
        imnames{numgoodfiles}=[directortName '/' fnames(i).name];
    end
end


end