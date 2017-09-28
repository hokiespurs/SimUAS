function str = addObject(x,y,z,rx,ry,rz,sx,sy,sz,objname,name,incrstart)
str = [];
TEXTURENAME = 'objects\\textures\\randomNoise.png';
for i=1:numel(x)
    str = [str sprintf('<object objname="%s" name = "%s%02.0f">\n',objname,name,incrstart+i)];
    str = [str sprintf('\t<position>\n')];
    str = [str sprintf('\t\t<translation x="%f" y="%f" z="%f"/>\n',x(i),y(i),z(i))];
    str = [str sprintf('\t\t<rotation x="%f" y="%f" z="%f"/>\n',rx(i),ry(i),rz(i))];
    str = [str sprintf('\t\t<scale x="%f" y="%f" z="%f"/>\n',sx(i),sy(i),sz(i))];
    str = [str sprintf('\t</position>\n')];
%     str = [str sprintf('\t<texture>\n')];
%     str = [str sprintf('\t\t<slot interpolate = "1" filename = "%s" infcolor="1"/>\n',TEXTURENAME)];
%     str = [str sprintf('\t</texture>\n')];
    str = [str sprintf('\t<material>\n')];
    str = [str sprintf('\t\t<shading shadeless="1" smooth="1"/>\n')];
    str = [str sprintf('\t</material>\n')];
    str = [str sprintf('</object>\n')];
end
fprintf(str);
end