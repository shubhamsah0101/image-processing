clc; clear all; close all;

% Read image
img = imread('image.tif');
figure(1)
imshow(img)
title("Original Image")

% Compute FFT and magnitude spectrum
[F_shifted, mag_spec] = computeFFT2D(img);

% Display magnitude spectrum
figure(2) 
imshow(mat2gray(mag_spec));
title('Magnitude Spectrum (Log Scale)');

% Reconstruct image from FFT
img_rec = reconstructImageIFFT(F_shifted);

% Display reconstructed image
figure(3)
imshow(uint8(img_rec));
title('Reconstructed Image from IFFT');
