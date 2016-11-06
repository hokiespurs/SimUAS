function xy = detectFiducials(imname, method)
I = imread(imname);

if method==1
    [xy,~] = detectCheckerboardPoints(I);
else
    xy=myDetectCorner(I);    
end
xy = xy - 0.5;

end