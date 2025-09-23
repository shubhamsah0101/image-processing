clc; clear all; close all;

% Original Image
img = imread("cameraman.tif");
figure(1)
imshow(img)
title("Original Image")

% 1. Box Filter
figure(2)
imshow(BoxFilter(img, 3))
title("After applying Box Filter")

% 2. Gaussian Filter
figure(3)
imshow(Gaussian(img, 3, 30))
title("After applying Gaussian Filter")

% 3. Median Filter
% img = imread("ckt.tif");
% figure(1)
% imshow(img)
% title("Original Image")
% 
% figure(4)
% imshow(Median(img, 5))
% title("After applying Median Filter")