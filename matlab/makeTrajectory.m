function makeTrajectory(fname, tName, tx, ty, tz, rx, ry, rz, prefix, ndigits)
fid = fopen(fname,'w+t');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<extrinsics name = "%s">\n',tName);
for i=1:numel(tx)
    iName = [prefix sprintf(['%0' sprintf('%.0f',ndigits) '.0f'],i)];
    fprintf(fid,'\t<pose name = "%s">\n',iName);
    fprintf(fid,'\t\t<translation x = "%f" y = "%f" z = "%f" />\n',tx(i),ty(i),tz(i));
    fprintf(fid,'\t\t<rotation x = "%f" y = "%f" z = "%f" />\n',rx(i),ry(i),rz(i));
    fprintf(fid,'\t</pose>\n');
end
fprintf(fid,'</extrinsics>');
fclose(fid);

fprintf('<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf('<extrinsics name = "%s">\n',tName);
for i=1:numel(tx)
    iName = [prefix sprintf(['%0' sprintf('%.0f',ndigits) '.0f'],i)];
    fprintf('\t<pose name = "%s">\n',iName);
    fprintf('\t\t<translation x = "%f" y = "%f" z = "%f" />\n',tx(i),ty(i),tz(i));
    fprintf('\t\t<rotation x = "%f" y = "%f" z = "%f" />\n',rx(i),ry(i),rz(i));
    fprintf('\t</pose>\n');
end
fprintf('</extrinsics>');