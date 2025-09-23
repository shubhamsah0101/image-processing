clc; clear; close all;

% Load and convert image
img = imread('cameraman.tif');
img = im2double(img);  % Normalize to [0,1]
[M, N] = size(img);

% Perform 2D FFT
F = fft2(img);

% Shift zero-frequency component to center
F_shifted = fftshift(F);

% Create Ideal Low Pass Filter Mask
D0 = 50;  

% Create meshgrid of frequency indices
u = 0:M-1;
v = 0:N-1;
u = u - floor(M/2);  % shift origin to center
v = v - floor(N/2);
[U, V] = meshgrid(v, u);

D = sqrt(U.^2 + V.^2);
H = double(D <= D0);  % Ideal low-pass filter

% Step 5: Apply filter in frequency domain
G = F_shifted .* H;

% Step 6: Inverse shift and compute inverse FFT
G_unshifted = ifftshift(G);
img_filtered = real(ifft2(G_unshifted));

% Step 7: Display Results
figure(1)
imshow(img)
title('Original Image')

figure(2)
imshow(log(1 + abs(F_shifted)), [])
title('Magnitude Spectrum')

figure(3)
imshow(H, [])
title('Ideal Low-Pass Filter Mask')

figure(4)
imshow(img_filtered, [])
title('Filtered Image')
