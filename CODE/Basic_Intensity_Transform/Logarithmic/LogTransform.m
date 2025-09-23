clc; clear all; close all;

% LOGARITHIMIC TRANSFORM OF GREY SCALE IMAGE:

% Original Image
img = imread("cameraman.tif");
figure(1)
imshow(img)
title("Original Image")

% Transformed Image
figure(2)
imshow(LN(img))
title("Transformed Image")
