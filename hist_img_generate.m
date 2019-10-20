clear all;
fimg = fopen('txtdata/img1.txt','r');
fimg1 = textscan(fimg,'%s');
fclose(fimg);
img1list=char(fimg1{1});
img1list=uint8(bin2dec(img1list));
img1=reshape(img1list,[256,256])';
img1 = imresize(img1,0.5);

fimg = fopen('txtdata/img1_eqlzed.txt','r');
fimg1e = textscan(fimg,'%s');
fclose(fimg);
img1elist=char(fimg1e{1});
img1elist=uint8(str2num(img1elist));
img1e=reshape(img1elist,[256,256])';
img1e = imresize(img1e,0.5);

fhist = fopen('txtdata/img1_origin_hist.txt','r');
fhist1o = textscan(fhist,'%s');
fclose(fhist);
hist1o=str2num(char(fhist1o{1}))/65536;

fhist = fopen('txtdata/img1_eqlzed_hist.txt','r');
fhist1e = textscan(fhist,'%s');
fclose(fhist);
hist1e=str2num(char(fhist1e{1}))/65536;

hist1o1=sum(reshape(hist1o,2,128),1)';
hist1e1=sum(reshape(hist1e,2,128),1)';

imghisto=zeros(128);
for i=1:128
    imghisto(1:floor(128-3*128*hist1o1(i)),i)=255;
end
imghisto=uint8(imghisto);

imghiste=zeros(128);
for i=1:128
    imghiste(1:floor(128-3*128*hist1e1(i)),i)=255;
end
imghiste=uint8(imghiste);


subplot(321)
imshow(img1);
subplot(322)
imshow(img1e);
subplot(323)
bar(hist1o1);
subplot(324)
bar(hist1e1);
subplot(325)
imshow(imghisto);
subplot(326)
imshow(imghiste);

imwrite(img1,'origin.jpg')
imwrite(img1e,'eqlzed.jpg')
imwrite(imghisto,'historigin.jpg')
imwrite(imghiste,'histeqlzed.jpg')
