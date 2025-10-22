% high SSIM : 

clc; clear; close all;
% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

% Step 2: Preprocess IR Image and Create ROI Mask
grayIR = rgb2gray(IR);
smoothedIR = imgaussfilt(grayIR, 2);    % Noise reduction
level = graythresh(smoothedIR);         % Otsu thresholding
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);
binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove small regions
figure, imshow(binaryMask); title('Binary Mask from IR');

% Step 3: Masked Images
maskedIR = grayIR .* uint8(binaryMask);
maskedVIS = rgb2gray(VIS) .* uint8(~binaryMask);
figure, imshow(maskedIR, []); title('Masked IR (Target)');
figure, imshow(maskedVIS, []); title('Masked VIS (Background)');

% Step 4: DWT Decomposition
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(double(maskedIR), 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(double(maskedVIS), 'db2');

% Step 5: ROI-Guided Fusion of Approximation and Detail Coefficients
maskSmall = imresize(double(binaryMask), size(LL_IR));
LL_fused = maskSmall .* LL_IR + (1 - maskSmall) .* LL_VIS;
LH_fused = maskSmall .* LH_IR + (1 - maskSmall) .* LH_VIS;
HL_fused = maskSmall .* HL_IR + (1 - maskSmall) .* HL_VIS;
HH_fused = maskSmall .* HH_IR + (1 - maskSmall) .* HH_VIS;

% Step 6: Inverse DWT Reconstruction
fusedWavelet = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');
fusedWavelet = mat2gray(fusedWavelet);

% Step 7: Selective Sharpening in ROI
sharpened = imsharpen(fusedWavelet, 'Radius', 2, 'Amount', 1);
fusedWavelet(binaryMask) = sharpened(binaryMask);

% Step 8: Gamma Correction to Brighten ROI
gamma_val = 0.7;
fusedWavelet(binaryMask) = imadjust(fusedWavelet(binaryMask), [], [], gamma_val);

% Step 9: Resize Inputs for Blending
VIS_resized = imresize(rgb2gray(VIS), size(fusedWavelet));
IR_resized = imresize(grayIR, size(fusedWavelet));

% Step 10: Create Soft Mask for Smooth Blending
softMask = imgaussfilt(double(binaryMask), 5);
softMask = mat2gray(softMask);
softMaskCompl = 1 - softMask;

% Step 11: Soft-Mask Guided Weighted Blending
alpha = 0.5;   % fused + IR weight inside ROI
beta = 0.3;    % IR weight inside ROI
gamma = 0.7;   % VIS weight outside ROI

fusedFinalDouble = ...
    (alpha * fusedWavelet + beta * double(IR_resized) / 255) .* softMask + ...
    gamma * double(VIS_resized) / 255 .* softMaskCompl;

fusedFinalDouble = mat2gray(fusedFinalDouble);
fusedFinal = uint8(fusedFinalDouble * 255);

% Step 12: Quality Metrics Calculation
ssimVal = ssim(fusedFinal, rgb2gray(imresize(VIS, size(fusedFinal))));
entropyVal = entropy(fusedFinal);

fprintf('\n--- Final Fusion Quality ---\nSSIM : %.4f\nEntropy : %.4f\n', ssimVal, entropyVal);

% Step 13: Visualization
figure;
subplot(1,2,1), imshow(IR, []), title('Infrared');
subplot(1,2,2), imshow(VIS, []), title('Visible');

figure;
imshow(fusedFinal);
title(sprintf('Soft Mask Fusion (SSIM=%.4f, Entropy=%.4f)', ssimVal, entropyVal));