im1 = imread('C:\Users\slocumr\github\SimUAS\data\topofield2b\output\images\pre\IMG_0001.png');
im2temp = imread('C:\Users\slocumr\github\SimUAS\data\topofield2b\output\images\IMG_0001.png');

% pad im2
d = size(im1)-size(im2temp);
im2 = zeros(size(im1),'uint8');
im2(d(1)/2+1:end-d(1)/2,d(2)/2+1:end-d(2)/2,:) = im2temp;

%%
im1b = insertText(im1,[10,10],'RAW','fontsize',200);
im2b = insertText(im2,[10,10],'POSTPROCESSED','fontsize',200);

im1z = im1(end-1900:end-1600,end-2900:end-2600,:);
im2z = im2(end-1900:end-1600,end-2900:end-2600,:);

im1zb = insertText(im1z,[10,10],'RAW','fontsize',28);
im2zb = insertText(im2z,[10,10],'POSTPROCESSED','fontsize',28);

imwrite(im1b,'raw.png');
imwrite(im2b,'post.png');
imwrite(im1zb,'rawz.png');
imwrite(im2zb,'postz.png');

%%
makeMovie({'raw.png','post.png'},'big.gif',0.5,1);
makeMovie({'rawz.png','postz.png'},'zoom.gif',0.5,1);
