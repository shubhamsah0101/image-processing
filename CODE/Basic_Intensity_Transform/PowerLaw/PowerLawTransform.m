clc; clear all; close all;

% POWER-LAW TRANSFORM OF GREY SCALE IMAGE:

% Original Image
img = imread("manWalkVB.jpg");
figure(1)
imshow(img)
title("Original Image")

% img = rgb2gray(img);

% Transformed Image
figure(2)
i = PL(img, 0.3);
smoothedImage = imgaussfilt(i, 3);

imshow(i)
title("Transformed Image")
