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

% Salient and background grayscale masked images
greyI = rgb2gray(IR);
result1 = greyI .* uint8(binaryMask);
result2 = greyI .* uint8(~binaryMask);

figure, imshow(result1); title('Salient × Infrared');
figure, imshow(result2); title('Background × Infrared');

%% Step 5: Apply Single-Level DWT on Salient and Background
figure(1);
subplot(1,2,1); imshow(result1, []); title('Salient Region (IR × Mask)');
subplot(1,2,2); imshow(result2, []); title('Background Region (IR × ~Mask)');

R1 = im2double(result1);
R2 = im2double(result2);

[LL_R1, LH_R1, HL_R1, HH_R1] = dwt2(R1, 'db2');
[LL_R2, LH_R2, HL_R2, HH_R2] = dwt2(R2, 'db2');

figure(2);
subplot(2,2,1), imshow(LL_R1, []); title('R1 Approximation (LL)');
subplot(2,2,2), imshow(LH_R1, []); title('R1 Horizontal Detail (LH)');
subplot(2,2,3), imshow(HL_R1, []); title('R1 Vertical Detail (HL)');
subplot(2,2,4), imshow(HH_R1, []); title('R1 Diagonal Detail (HH)');

figure(3);
subplot(2,2,1), imshow(LL_R2, []); title('R2 Approximation (LL)');
subplot(2,2,2), imshow(LH_R2, []); title('R2 Horizontal Detail (LH)');
subplot(2,2,3), imshow(HL_R2, []); title('R2 Vertical Detail (HL)');
subplot(2,2,4), imshow(HH_R2, []); title('R2 Diagonal Detail (HH)');

%% Fusion: Weighted average fusion coefficients (original fusion rule)
F_LL = 0.6 * LL_R1 + 0.4 * LL_R2;
F_LH = 0.5 * LH_R1 + 0.5 * LH_R2;
F_HL = 0.5 * HL_R1 + 0.5 * HL_R2;
F_HH = 0.5 * HH_R1 + 0.5 * HH_R2;

%% Step 6: Reconstruct fused image using Inverse DWT
Fused_Result = idwt2(F_LL, F_LH, F_HL, F_HH, 'db2');
Fused_Result = mat2gray(Fused_Result);

%% Step 6.1: Post-fusion CLAHE for entropy enhancement
Fused_Result = adapthisteq(Fused_Result, 'ClipLimit', 0.02);

figure;
imshow(Fused_Result, []);
title('Enhanced Fused Image after CLAHE');

%% Step 7: Compute Entropy, SSIM, and PSNR
en = entropy(Fused_Result);

fusedUint8 = im2uint8(Fused_Result);
irGrayResized = imresize(rgb2gray(IR), size(fusedUint8));
irUint8 = im2uint8(irGrayResized);

ssimVal = ssim(fusedUint8, irUint8);
psnrVal = psnr(fusedUint8, irUint8);

fprintf('\n--- Fusion Quality Metrics ---\n');
fprintf('Entropy: %.4f\n', en);
fprintf('SSIM: %.4f\n', ssimVal);
fprintf('PSNR: %.4f dB\n', psnrVal);
