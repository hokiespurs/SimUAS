% Python Code
% Rotate = Triplet(-70*pi/180, 10*pi/180, 20*pi/180)
% Translate = Triplet(5, 15, 9)
% Scale = Triplet(2, 4, 6)
% rawpts = Triplet([1, 0, 0, 0], [0, 0, 0, 1], [0, 0, 1, 1])
% newrawpts = RotatePoint(rawpts, Rotate, Translate, Scale)
% shouldbe = Triplet([6.9, 5.0, 3.4, 2.3], [15.7, 15.0, 20.4, 21.5], [8.7, 9.0, 11.0, 7.3])


r(1) = -70;
r(2) = 10;
r(3) = 20;

r = r*pi/180;

t(1) = 5;
t(2) = 15;
t(3) = 9;

s(1) = 2;
s(2) = 4;
s(3) = 6;

R = makehgtform('translate',[tx ty tz],...
                'xrotate',r(1),...
                'yrotate',r(2),...
                'zrotate',r(3));

xyz1 = [0; 0; 1; 1];    
act = [6.04; 20.55; 11.02; 1];

xyz1 = xyz1.* [s';1];

newPts = round(R*xyz1,2);

[act newPts]