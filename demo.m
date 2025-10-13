% Visible and Infrared Image Fusion

clc; clear all; close all;

% input images
visible_image = imread("manWalkVB.jpg");
infrared_image = imread("manWalkIR.jpg");

% display of original image
subplot(1, 2, 1)
imshow(visible_image)
title("Original Visible Image")
subplot(1, 2, 2)
imshow(infrared_image)
title("Original Infrared Image")

