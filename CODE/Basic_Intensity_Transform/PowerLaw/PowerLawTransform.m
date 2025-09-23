clc; clear all; close all;

% POWER-LAW TRANSFORM OF GREY SCALE IMAGE:

% Original Image
img = imread("Fig2.tif");
figure(1)
imshow(img)
title("Original Image")

% Transformed Image
figure(2)
imshow(PL(img, 0.3))
title("Transformed Image")
