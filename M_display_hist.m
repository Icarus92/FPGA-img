clear all;

fimg = fopen('txtdata/img1.txt','r');
fimg1 = textscan(fimg,'%s');
fclose(fimg);
img1list=char(fimg1{1});
img1list=uint8(bin2dec(img1list));
img1=reshape(img1list,[256,256])';

fimg = fopen('txtdata/img1_eqlzed.txt','r');
fimg1e = textscan(fimg,'%s');
fclose(fimg);
img1elist=char(fimg1e{1});
img1elist=uint8(str2num(img1elist));
img1e=reshape(img1elist,[256,256])';

fhist = fopen('txtdata/img1_origin_hist.txt','r');
fhist1o = textscan(fhist,'%s');
fclose(fhist);
hist1olist=char(fhist1o{1});
hist1o=str2num(hist1olist)/65536;

fhist = fopen('txtdata/img1_eqlzed_hist.txt','r');
fhist1e = textscan(fhist,'%s');
fclose(fhist);
hist1elist=char(fhist1e{1});
hist1e=str2num(hist1elist)/65536;

gray_scale=0:255;

figure(2);
subplot(221);
imshow(img1);
title('原始图像');

subplot(223);
imshow(img1e);
title('均衡后图像');

subplot(222);
bar(gray_scale,hist1o);
xlim([0,256]);
title('原始直方图');

subplot(224);
bar(gray_scale,hist1e);
xlim([0,256]);
title('均衡后直方图');