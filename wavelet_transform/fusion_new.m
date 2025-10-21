% Fusion of Infrared and Visible Image:

clc; clear all; close all;
% 1. Creating background Mask:

% Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');

figure(1)
subplot(1, 2, 1)
imshow(IR)
title('Infrared Image')
subplot(1, 2, 2)
imshow(VIS)
title('Visible Image')

% Preprocess Infrared Image
grayIR = rgb2gray(IR);
grayVIS = rgb2gray(VIS);

smoothedIR = imgaussfilt(grayIR, 2); % Gaussian smoothing
level = graythresh(smoothedIR); % Otsu threshold
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);

binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5)); % Fill gaps
binaryMask = bwareaopen(binaryMask, 100); % Remove small fragments
