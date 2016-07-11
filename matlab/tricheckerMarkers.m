fid = fopen('trichecker.txt','w+t');

[x,y]=meshgrid(0:0.1:1,0:0.1:1);
z = zeros(size(x));
fprintf(fid,'%.1f,%.1f,%.1f\n',[x(:) y(:) z(:)]');

[x,z]=meshgrid(0:0.1:1,0:0.1:1);
y = zeros(size(x));
fprintf(fid,'%.1f,%.1f,%.1f\n',[x(:) y(:) z(:)]');

[y,z]=meshgrid(0:0.1:1,0:0.1:1);
x = zeros(size(y));
fprintf(fid,'%.1f,%.1f,%.1f\n',[x(:) y(:) z(:)]');

fclose(fid);