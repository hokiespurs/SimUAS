[xg,yg]=meshgrid(-25:10:25,-25:10:25);

for i=1:numel(xg)
    fprintf('<object objname="gcp" name = "GCP%02.0f" isControl = "1" isFiducial = "1">\n',i)
    fprintf('\t<position>\n');
    fprintf('\t\t<translation x="%.0f" y="%.0f" z="%.0f"/>\n',xg(i),yg(i),0.01+rand(1)*10)
    fprintf('\t\t<rotation x="0" y="0" z="%.0f"/>\n',rand(1)*360);
    fprintf('\t\t<scale x="1" y="1" z="1"/>\n');
    fprintf('\t</position>\n');
    fprintf('</object>\n')
end

%% with xg,yg,zg
xi = [-40,-40,-40,-20,-20,20, 20, 40,40,40];
yi = [-40,  0, 40, 20,-20,20,-20,-40, 0,40];

F = scatteredInterpolant(xg(:),yg(:),zg(:));
zi = F(xi,yi)+0.25;
clc
for i=1:numel(xi)
    fprintf('<object objname="control_checker" name = "GCP%02.0f" isControl = "1" isFiducial = "1">\n',i)
    fprintf('\t<position>\n');
    fprintf('\t\t<translation x="%.0f" y="%.0f" z="%.1f"/>\n',xi(i),yi(i),zi(i))
    fprintf('\t\t<rotation x="0" y="0" z="%.0f"/>\n',0);
    fprintf('\t\t<scale x="1" y="1" z="1"/>\n');
    fprintf('\t</position>\n');
    fprintf('</object>\n')
end