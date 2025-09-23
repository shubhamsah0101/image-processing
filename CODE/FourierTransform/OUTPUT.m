clc; clear all; close all;

img = imread("blurry_moon.tif");
figure(1)
imshow(img)
title("Original Image")

% % DFT:

F = manualDFT(img(1:128, 1:128));
 
% Display magnitude spectrum (for visualization)
magnitude_spectrum = log(abs(F) + 1);
figure(2)
imshow(mat2gray(magnitude_spectrum))
title('Magnitude Spectrum');



% Laplacian:

% lap_img = laplacian_frequency(img);
% 
% figure(2)
% imshow(mat2gray(lap_img))
% title('Laplacian Output');


