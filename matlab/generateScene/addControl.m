[xg,yg]=meshgrid(-25:10:25,-25:10:25);

for i=1:numel(xg)
    fprintf('<object objname="gcp" name = "GCP%02.0f" isControl = "1" isFiducial = "1">\n',i)
    fprintf('\t<translation x="%.0f" y="%.0f" z="%.0f"/>\n',xg(i),yg(i),0.01+rand(1)*10)
    fprintf('\t<rotation x="0" y="0" z="%.0f"/>\n',rand(1)*360);
    fprintf('\t<scale x="1" y="1" z="1"/>\n');
    fprintf('</object>\n')
end