clear all;

figure(3);
fimg = fopen('txtdata/img1b.txt','r');
fimg1 = textscan(fimg,'%s');
fclose(fimg);
img1list=char(fimg1{1});
img1list=uint8(bin2dec(img1list));
img1=reshape(img1list,[256,256])';
subplot(2,3,1);
imshow(img1);
title('原始图像');
text(128,256,'分辨率: 256x256','HorizontalAlignment','center','VerticalAlignment','top');


%自适应阈值窗口的半径
thres_length=[5 10 20 40 80];

l=length(thres_length);
img1b=uint8(zeros(l,256,256));
for i=1:l
    fimg = fopen(strcat('txtdata/img1_bin',num2str(thres_length(i)),'.txt'),'r');
    fimg1b = textscan(fimg,'%d');
    fclose(fimg);
    img1blist=fimg1b{1};
    img1blist(img1blist==1)=255;
    img1blist=uint8(img1blist);
    img1b(i,:,:)=reshape(img1blist,[256,256])';
    subplot(2,3,i+1);
    imshow(squeeze(img1b(i,:,:)));
    title('二值化图像');
    text(128,256,strcat('窗口大小:',num2str(2*thres_length(i)+1),'x',num2str(2*thres_length(i)+1)),'HorizontalAlignment','center','VerticalAlignment','top');
end








