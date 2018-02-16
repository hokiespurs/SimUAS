function writeOutputTrajectory(fname,xg,yg,zg)
dname = fileparts(fname);
mkdir(dname);

fid = fopen(fname,'w+t');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'  <reference version="1.2.0">\n');
fprintf(fid,'    <cameras>\n');
for i=1:numel(xg)
    fprintf(fid,'      <camera label="%s">\n',sprintf('img%04.0f.png',i));
    fprintf(fid,'        <reference x="%f" y="%f" z="%f" enabled="true"/>\n',xg(i),yg(i),zg(i));
    fprintf(fid,'      </camera>');
end
fprintf(fid,'    </camera>\n');
fprintf(fid,'  </cameras>\n');
fprintf(fid,'</reference>\n');
fclose(fid);

end