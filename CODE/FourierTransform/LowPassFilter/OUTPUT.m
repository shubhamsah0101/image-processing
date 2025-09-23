clc; clear all; close all;

% Low-pass Filter:

% Load image
img = imread('cameraman.tif');

% Apply LPF
filtered1 = ideal_lowpass_filter(img, 40);
filtered2 = gaussian_lowpass_filter(img, 40);
filtered3 = butterworth_lowpass_filter(img, 40, 4);

% Show results
figure(1)
imshow(img)
title('Original');

figure(2)
imshow(filtered1)
title('Ideal Low-Pass Filtered');

figure(3)
imshow(filtered2)
title('Gaussian Low-Pass Filtered');

figure(4)
imshow(filtered3)
title('Butterworth Low-Pass Filtered');

