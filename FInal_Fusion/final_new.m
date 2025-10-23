clc; clear; close all;
%% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

%% Step 2: Preprocess Infrared Image
grayIR = rgb2gray(IR);
figure, imhist(grayIR); title('Histogram of Infrared Grayscale Image');
smoothedIR = imgaussfilt(grayIR, 2);  % Gaussian smoothing
level = graythresh(smoothedIR);      % Otsu threshold
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);
binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove small fragments

%% Step 3: Apply Mask to IR Image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
figure, imshow(maskedIR); title('Masked IR Image (Auto ROI)');

%% Step 4: Create STM and BM Masks
stm = uint8(binaryMask) * 255;
bm = uint8(~binaryMask) * 255;
figure;
subplot(1,2,1); imshow(stm); title('Salient Target Mask');
subplot(1,2,2); imshow(bm); title('Background Mask');

greyI = rgb2gray(IR);
result1 = greyI .* uint8(binaryMask);
figure, imshow(result1); title('Salient × Infrared');
greyI = rgb2gray(VIS);
result2 = greyI .* uint8(~binaryMask);
figure, imshow(result2); title('Background × Infrared');

%% Step 5: Apply DWT on Salient (result1) and Background (result2)
figure(1);
subplot(1,2,1); imshow(result1, []); title('Salient Region (IR × Mask)');
subplot(1,2,2); imshow(result2, []); title('Background Region (IR × ~Mask)');

% Convert to double for computation
R1 = im2double(result1);
R2 = im2double(result2);

% % Perform single-level DWT on both
% [LL_R1, LH_R1, HL_R1, HH_R1] = dwt2(R1, 'db2');
% [LL_R2, LH_R2, HL_R2, HH_R2] = dwt2(R2, 'db2');
%% 3 level dwt
% Level 1 DWT
[LL_R1_L1, LH_R1_L1, HL_R1_L1, HH_R1_L1] = dwt2(R1, 'db2');
[LL_R2_L1, LH_R2_L1, HL_R2_L1, HH_R2_L1] = dwt2(R2, 'db2');

% Display DWT components for Salient Region
figure(2);
subplot(2,2,1), imshow(LL_R1_L1, []); title('R1 Approximation (LL)');
subplot(2,2,2), imshow(LH_R1_L1, []); title('R1 Horizontal Detail (LH)');
subplot(2,2,3), imshow(HL_R1_L1, []); title('R1 Vertical Detail (HL)');
subplot(2,2,4), imshow(HH_R1_L1, []); title('R1 Diagonal Detail (HH)');

% Display DWT components for Background Region
figure(3);
subplot(2,2,1), imshow(LL_R2_L1, []); title('R2 Approximation (LL)');
subplot(2,2,2), imshow(LH_R2_L1, []); title('R2 Horizontal Detail (LH)');
subplot(2,2,3), imshow(HL_R2_L1, []); title('R2 Vertical Detail (HL)');
subplot(2,2,4), imshow(HH_R2_L1, []); title('R2 Diagonal Detail (HH)');

% Fuse the coefficients (Weighted more from salient region)
F_LL = 0.6 * LL_R1_L1 + 0.4 * LL_R2_L1; % Prioritize salient target region
F_LH = 0.5 * LH_R1_L1 + 0.5 * LH_R2_L1;
F_HL = 0.5 * HL_R1_L1 + 0.5 * HL_R2_L1;
F_HH = 0.5 * HH_R1_L1 + 0.5 * HH_R2_L1;

% Reconstruct fused image using Inverse DWT
Fused_Result = idwt2(F_LL, F_LH, F_HL, F_HH, 'db2');
Fused_Result = mat2gray(Fused_Result);

figure;
imshow(Fused_Result, []);
title('Fused Image from Salient and Background Regions using DWT');
%% Step 6: Compute Entropy and SSIM
en = entropy(Fused_Result);

% Safe grayscale conversion for both gray and RGB images
fusedGray = im2gray(uint8(Fused_Result));
refGray = im2gray(result1);  % Compatible with both grayscale and RGB images

% Compute SSIM between fused and reference images
refGrayResized = imresize(refGray, size(fusedGray)); % Resize reference image
ssimVal = ssim(fusedGray, refGrayResized);


fprintf('\n--- Fusion Quality Metrics ---\n');
fprintf('Entropy: %.4f\n', en);
fprintf('SSIM: %.4f\n', ssimVal);