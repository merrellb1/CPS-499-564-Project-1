close all;
clear all;
clc;


%2 is wrong but everything else works will tweak things to make it more
%accurate

% reading images
n = "3"; % image number 1-10
img1r = im2double(imread("RGB Data\RGB Data\"+n+"_HW1_1.jpg"));
img1g = im2double(imread("RGB Data\RGB Data\"+n+"_HW1_2.jpg"));
img1b = im2double(imread("RGB Data\RGB Data\"+n+"_HW1_3.jpg"));

% displaying channels and histograms
[l,w] = size(img1r);
zero = zeros(l,w);
figure, imhist(img1r)
figure, imshow(combine_rgb(img1r,zero,zero));
figure, imhist(img1g)
figure, imshow(combine_rgb(zero,img1g,zero));
figure, imhist(img1b)
figure, imshow(combine_rgb(zero,zero,img1b));



[manipulated_channel conf] = detect_tampering(img1r,img1g,img1b);

if (manipulated_channel=='R')
    restored = restore_channel(img1r,img1g,img1b);
    figure,imshow(combine_rgb(restored,img1g,img1b));
elseif (manipulated_channel=='G')
    restored = restore_channel(img1g,img1r,img1b);
    figure,imshow(combine_rgb(img1r,restored,img1b));
elseif (manipulated_channel=='B')
    restored = restore_channel(img1b,img1g,img1r);
    figure,imshow(combine_rgb(img1r,img1g,restored));
else
    disp("HEY");
end