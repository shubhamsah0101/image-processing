clc; clear; close all;

% Step 1: Load Input Images and Convert to Grayscale
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
grayIR = rgb2gray(IR);
grayVIS = rgb2gray(VIS);

figure, imshow(grayIR); title('Infrared Grayscale Image');
figure, imshow(grayVIS); title('Visible Grayscale Image');

% Step 2: Preprocess Infrared Image and Create Mask
smoothedIR = imgaussfilt(grayIR, 2);
level = graythresh(smoothedIR);
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);

binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));
binaryMask = bwareaopen(binaryMask, 100);

figure, imshow(binaryMask); title('Binary Foreground Mask');

% Step 3: Separate Foreground and Background Components
mask_double = im2double(binaryMask);
foregroundIR = double(grayIR) .* mask_double;
backgroundVIS = double(grayVIS) .* (1 - mask_double);

figure, imshow(foregroundIR, []); title('Foreground from IR');
figure, imshow(backgroundVIS, []); title('Background from VIS');

% Step 4: Apply Single-level DWT to Both Components
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(foregroundIR, 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(backgroundVIS, 'db2');

% Step 5: Resize Mask to LL size and Smooth
mask_LL = imresize(mask_double, size(LL_IR));
mask_LL = imgaussfilt(mask_LL, 2);  % Soft mask smoothing

% Step 6: Fuse Approximation Coefficients with Soft Mask
LL_fused = mask_LL .* LL_IR + (1 - mask_LL) .* LL_VIS;

% Step 7: Fuse Detail Coefficients Using Max Absolute Value Selection
LH_fused = (abs(LH_IR) >= abs(LH_VIS)) .* LH_IR + (abs(LH_IR) < abs(LH_VIS)) .* LH_VIS;
HL_fused = (abs(HL_IR) >= abs(HL_VIS)) .* HL_IR + (abs(HL_IR) < abs(HL_VIS)) .* HL_VIS;
HH_fused = (abs(HH_IR) >= abs(HH_VIS)) .* HH_IR + (abs(HH_IR) < abs(HH_VIS)) .* HH_VIS;

% Step 8: Reconstruct Fused Image Using Inverse DWT
fusedImage = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');

% Step 9: Normalize and Display Final Fused Image
fusedImage = mat2gray(fusedImage);
figure;
imshow(fusedImage, []);
title('Optimized Fused Infrared-Visible Image');