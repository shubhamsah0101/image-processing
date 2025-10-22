% Sharpen :

clc; clear; close all;

% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

% Step 2: Preprocess Infrared Image and Create ROI Mask
grayIR = rgb2gray(IR);
smoothedIR = imgaussfilt(grayIR, 2);    % Gaussian smoothing for noise reduction
level = graythresh(smoothedIR);         % Otsu global thresholding
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);
binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove tiny regions
figure, imshow(binaryMask); title('Binary Mask from IR');

% Step 3: Apply Mask to IR and VIS Images
maskedIR = grayIR .* uint8(binaryMask);          % Highlight IR salient region
maskedVIS = rgb2gray(VIS) .* uint8(~binaryMask); % Retain VIS background region
figure, imshow(maskedIR, []); title('Masked IR (Target)');
figure, imshow(maskedVIS, []); title('Masked VIS (Background)');

% Step 4: Perform DWT Decomposition on Masked Images
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(double(maskedIR), 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(double(maskedVIS), 'db2');

% Step 5: Compute Entropy of Approximation Coefficients
entropy_IR = entropy(uint8(mat2gray(LL_IR)*255));
entropy_VIS = entropy(uint8(mat2gray(LL_VIS)*255));
weight_IR = entropy_IR / (entropy_IR + entropy_VIS);
weight_VIS = entropy_VIS / (entropy_IR + entropy_VIS);
% fprintf('Entropy IR: %.4f, Entropy VIS: %.4f, Weights IR: %.4f, VIS: %.4f\n', ...
%     entropy_IR, entropy_VIS, weight_IR, weight_VIS);

% Step 6: Mask-Guided Entropy Weighted DWT Fusion
maskSmall = imresize(double(binaryMask), size(LL_IR));
LL_fused = weight_IR * LL_IR + weight_VIS * LL_VIS; % Entropy-weighted fusion

% Fuse detail coefficients using maximum absolute value rule
LH_fused = (abs(LH_IR) > abs(LH_VIS)) .* LH_IR + (abs(LH_IR) <= abs(LH_VIS)) .* LH_VIS;
HL_fused = (abs(HL_IR) > abs(HL_VIS)) .* HL_IR + (abs(HL_IR) <= abs(HL_VIS)) .* HL_VIS;
HH_fused = (abs(HH_IR) > abs(HH_VIS)) .* HH_IR + (abs(HH_IR) <= abs(HH_VIS)) .* HH_VIS;

% Step 7: Reconstruct the Fused Image via Inverse DWT
fusedWavelet = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');
fusedWavelet = mat2gray(fusedWavelet);

% Step 8: Adaptive Histogram Equalization (CLAHE) for Contrast Enhancement
fusedEnhanced = adapthisteq(fusedWavelet, 'ClipLimit', 0.03);

% Step 9: Final Fusion with ROI Retention
VIS_resized = imresize(VIS, size(fusedEnhanced));
IR_resized = imresize(IR, size(fusedEnhanced));
fusedFinal = uint8(...
    0.4 * double(fusedEnhanced)*255 + ...
    0.3 * double(rgb2gray(VIS_resized)) + ...
    0.3 * double(rgb2gray(IR_resized)));

% Step 10: Fusion Quality Evaluation — SSIM and Gradient Loss
fusedGray = mat2gray(fusedFinal);
refGray = mat2gray(rgb2gray(VIS));     % Reference image chosen as visible

% SSIM-based loss
ssimVal = ssim(fusedGray, refGray);
L_ssim = 1 - ssimVal;

% Compute gradient loss (Sobel edge difference)
G_fused = imgradient(fusedGray, 'sobel');
G_ref   = imgradient(refGray, 'sobel');
L_grad = mean(abs(G_fused - G_ref), 'all') / 255;

% Final combined loss
L_total = L_ssim + L_grad;

fprintf('\n--- Fusion Performance Metrics ---\n');
fprintf('SSIM Loss      : %.4f\n', L_ssim);
fprintf('Gradient Loss  : %.4f\n', L_grad);
fprintf('Total Loss     : %.4f\n', L_total);

% Step 11: Output Visualization
figure;
subplot(1,2,1), imshow(IR, []), title('Infrared');
subplot(1,2,2), imshow(VIS, []), title('Visible');

figure
imshow(fusedFinal, []);
title('Entropy Optimized Final Fused Image');