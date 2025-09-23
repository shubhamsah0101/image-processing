clc; clear all; close all;

% High-pass Filter:

% Load image
img = imread('cameraman.tif');

% Apply LPF
filtered1 = ideal_highpass_filter(img, 40);
filtered2 = gaussian_highpass_filter(img, 40);
filtered3 = butterworth_highpass_filter(img, 40, 4);

% Show results
figure(1)
imshow(img)
title('Original');

figure(2)
imshow(filtered1)
title('Ideal High-Pass Filtered');

figure(3)
imshow(filtered2)
title('Gaussian High-Pass Filtered');

figure(4)
imshow(filtered3)
title('Butterworth High-Pass Filtered');

