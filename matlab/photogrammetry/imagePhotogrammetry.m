function imagePhotogrammetry(I)
[m,n,~]=size(I);
image((1:n)-0.5,(1:m)-0.5,I)
end