function img_results = bilateralFilter(img, depthImg)
%BILATERALFILTER Summary of this function goes here
%   Detailed explanation goes here

kernel_size = 5;
gaussian_kernel = fspecial('gaussian',[kernel_size kernel_size],5);
 
%Preparation for BF
indent = (kernel_size-1)/2;
[height, width] = size(img);
img_results = zeros(height, width);
img = double(img);
sigma_range = 25;

for i = indent + 1:height-indent
    for j = indent + 1:width-indent
        range_kernel = createRangeKernel(img,i,j,kernel_size,sigma_range);
        kernel = (range_kernel.*gaussian_kernel);
        normalization = 1/sum(kernel(:));
        temp = (kernel.*double(depthImg(i-indent:i+indent,j-indent:j+indent)))*normalization;
        img_results(i,j) = sum(temp(:));
    end
end
