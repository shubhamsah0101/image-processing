% clc; clear all; close all;
% 
% % Read an image
% img = imread('cameraman.tif'); % or your own image
% img = im2double(img);
% 
% % Apply single-level 2D wavelet transform
% [LL, LH, HL, HH] = dwt2(img, 'haar'); % you can use 'db1', 'sym4', etc.
% 
% % Display results
% figure;
% subplot(2,3,1); imshow(img, []); title('Original Image');
% subplot(2,3,2); imshow(LL, []); title('Approximation (LL)');
% subplot(2,3,3); imshow(LH, []); title('Horizontal Detail (LH)');
% subplot(2,3,4); imshow(HL, []); title('Vertical Detail (HL)');
% subplot(2,3,5); imshow(HH, []); title('Diagonal Detail (HH)');
% 
% % Reconstruct the image
% reconstructed = idwt2(LL, LH, HL, HH, 'haar');
% subplot(2,3,6); imshow(reconstructed, []); title('Reconstructed Image');

clc; clear all; close all;

% Step 1: Read and preprocess images
IR = imread("manWalkIR.jpg");
VIS = imread("manWalkVB.jpg");

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
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(IR, 'db10');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db10');

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