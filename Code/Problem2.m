close all;
clear all;
clc;

% clear pre-existing data from the test results folder
outputFolder = '../Test Results/Problem2';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
%Deletes folder contents
delete('../Test Results/Problem2/*');

%load the images and depth maps into separate arrays
folderPath = 'RGBD Data/RGBD Data/';
filePattern = fullfile(folderPath, '*.png');
fileList = dir(filePattern, SortOrder="natural");

imgCell = cell(2,24);
depthImgCell = cell(2,24);

for i = 1:24
    baseFileName = fileList(i).name;
    fullFileName = fullfile(folderPath, baseFileName);
    if contains(baseFileName,'depth') == false
        img = imread(['RGBD Data/RGBD Data/' baseFileName]);
        imgCell{1,i} = img;
        imgCell{2,i} = baseFileName;
    else
        img = imread(['RGBD Data/RGBD Data/' baseFileName]);
        depthImgCell{1,i} = img;
        depthImgCell{2,i} = baseFileName;
    end
end

%Remove empty spaces within the arrays
keep = any(~cellfun('isempty',imgCell),1);
imgCell = imgCell(:,keep);
keep = any(~cellfun('isempty',depthImgCell),1);
depthImgCell = depthImgCell(:,keep);

%De-noising with the bilateral filter
img_results = zeros(size(imgCell{1}));
for i = 1:12
    for c = 1:3
        %The filter's adjusted to apply the kernels from the primary image
        %and apply them to the depth map
        img_results(:,:,c) = bilateralFilter(imgCell{1,i}(:,:,c), depthImgCell{1,i});
    end
    fullpath = fullfile(outputFolder,append('result_',imgCell{2,i}));
    imwrite(uint8(img_results),fullpath)
end
