function makeRunSimUASFiles(dname,prefixname,numiter)
% makeRunSimUASFiles('R:\\simUASdata\\bathytest','BATHY',3)
for iNum=1:numiter
    makeFile(dname,prefixname,iNum,numiter)
end

end

function makeFile(dname,prefixname,iNum,niter)

fid = fopen(sprintf('runSimUAS_%s_%.0f.bat',prefixname,iNum),'w+t');

fprintf(fid,'SET DNAME=%s\n\n',dname);

[~,allfolders] = dirname([prefixname '*'],0,dname);
for i=iNum:niter:numel(allfolders)
    [~,fname,~]=fileparts(allfolders{i});
    fprintf(fid,'SET EXPERIMENTNAME=%s\n',fname);
    fprintf(fid,'cd ../python\n');
    fprintf(fid,'blender --background --python renderblender.py -- %%EXPERIMENTNAME%% %%DNAME%%\n');
    fprintf(fid,'cd ../matlab/postprocess\n');
    fprintf(fid,'matlab -r postProcFolder(''%%EXPERIMENTNAME%%'',1,''%%DNAME%%'')\n');
    fprintf(fid,'cd ../../runSimUAS\n\n');
end

fclose(fid);

end