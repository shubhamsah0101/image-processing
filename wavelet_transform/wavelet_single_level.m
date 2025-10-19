% image fusion using Wavelet :-

clc; clear all; close all;

% Step 1: Read and preprocess images
IR = imread("sniper_IR.bmp");
VIS = imread("sniper_vis.bmp");

% Convert to grayscale if necessary
if size(IR,3)==3
    IR = rgb2gray(IR);
end
if size(VIS,3)==3
    VIS = rgb2gray(VIS);
end

% Resize to same size
[rows, cols] = size(IR);
VIS = imresize(VIS, [rows cols]);

% Convert to double
IR = im2double(IR);
VIS = im2double(VIS);

% Step 2: Apply single-level DWT
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(IR, 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db2');

% Step 3: Fuse coefficients
LL_fused = (LL_IR + LL_VIS) / 2;           % average of approximations
LH_fused = max(LH_IR, LH_VIS);             % max for detail coefficients
HL_fused = max(HL_IR, HL_VIS);
HH_fused = max(HH_IR, HH_VIS);

% Step 4: Reconstruct fused image
Fused = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');

% Step 5: Display results
figure(1)
subplot(1,2,1); imshow(IR, []); title('Infrared Image');
subplot(1,2,2); imshow(VIS, []); title('Visible Image');
% subplot(2,2,3); imshow(Fused, []); title('Fused Image');

figure(2)
imshow(Fused, [])
title("Fused Image")