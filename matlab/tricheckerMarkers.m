fid = fopen('trichecker.txt','w+t');

[x,y]=meshgrid(0:0.1:1,0:0.1:1);
z = zeros(size(x));
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[x,z]=meshgrid(0:0.1:1,0.1:0.1:1);
y = zeros(size(x));
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[y,z]=meshgrid(0.1:0.1:1,0.1:0.1:1);
x = zeros(size(y));
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

fclose(fid);

%% checkercube
fid = fopen('checkercube.txt','w+t');

[x,y]=meshgrid(0.1:0.1:0.9,0.1:0.1:0.9);
z = ones(size(x))*0;
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[x,z]=meshgrid(0.1:0.1:0.9,0.1:0.1:0.9);
y = ones(size(x))*0;
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[y,z]=meshgrid(0.1:0.1:0.9,0.1:0.1:0.9);
x = ones(size(x))*0;
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[x,y]=meshgrid(0.1:0.1:0.9,0.1:0.1:0.9);
z = ones(size(x))*1;
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[x,z]=meshgrid(0.1:0.1:0.9,0.1:0.1:0.9);
y = ones(size(x))*1;
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

[y,z]=meshgrid(0.1:0.1:0.9,0.1:0.1:0.9);
x = ones(size(x))*1;
fprintf(fid,'%.3f,%.3f,%.3f\n',[x(:) y(:) z(:)]');

fclose(fid);