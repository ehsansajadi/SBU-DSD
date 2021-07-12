clc;
clear;
close all;
F=double(imread('bwduck.bmp'));
H=F;
I=F;
[rows cols]=size(F);
 A=[0,1,0;1,-4,1;0,1,0];
 B=[1,1,1;1,-8,1;1,1,1];
G1=zeros(3,3);
G2=zeros(3,3);
for i = 2:rows-1
    for j = 2:cols-1
    
    for k=-1:1
        for l=-1:1
        G1(k+2,l+2)=F(i+k,j+l)*A(k+2,l+2);
        G2(k+2,l+2)=F(i+k,j+l)*B(k+2,l+2);
        end
    end
    H(i,j)=sum(sum(G1));
    I(i,j)=sum(sum(G2));
    end
end
H = uint8(round(H - 1));
I = uint8(round(I - 1));
figure()
subplot(2,2,[1 2]);
imshow(uint8(F));
title('Input Image for Sharpening Filters');
subplot(2,2,3);
imshow(H);
title('Output Sharpened Image for kernel A=[0,1,0;1,-4,1;0,1,0]');
subplot(2,2,4);
imshow(I);
title('Output Sharpened Image for kernel  B=[1,1,1;1,-8,1;1,1,1]');
