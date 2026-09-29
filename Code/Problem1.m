close all;
clear all;
clc;




% testing
R = imread('1_HW1_1.jpg');
G = imread('1_HW1_2.jpg');
B = imread('1_HW1_3.jpg');
figure,imshow(R);
figure,imshow(G);
figure,imshow(B);

img_rgb = cat(3,R,G,B);
figure,imshow(img_rgb);


function restored_channel = restore_channel(manipulated, ref1, ref2)
    % Use two good channels to restore the manipulated one
    dif1 = manipulated-ref1; % manipulated = dif1 + ref1
    dif2 = manipulated-ref2;

    
    % try gaussian filter to smooth out differences
    kernel_size = 5;
    gaussian_kernel = fspecial('gaussian',[kernel_size kernel_size],5);
    dif1_smooth = dif1*gaussian_kernel;
    dif2_smooth = dif2*gaussian_kernel;

    % solutions
    sol1 = dif1_smooth + ref1;
    sol2 = dif2_smooth + ref2;
    
    figure,imshow(dif1);
    figure,imshow(dif1_smooth);
    figure,imshow(sol1);


    restored_channel = manipulated;
end

function rgb = combine_rgb(R,G,B)
    rgb = cat(3,R,G,B);
end

