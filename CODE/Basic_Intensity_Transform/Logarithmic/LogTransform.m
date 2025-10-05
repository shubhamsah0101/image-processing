clc; clear all; close all;

% LOGARITHIMIC TRANSFORM OF GREY SCALE IMAGE:

% Original Image
img = imread("manWalkVB.jpg");
figure(1)
imshow(img)
title("Original Image")

% Transformed Image
% img = rgb2gray(img);
figure(2)
imshow(LN(img))
title("Transformed Image")
