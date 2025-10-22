% without sharpning :

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

% Visualize components
figure;
subplot(2,4,1), imshow(LL_IR, []); title('IR LL');
subplot(2,4,2), imshow(LH_IR, []); title('IR LH');
subplot(2,4,3), imshow(HL_IR, []); title('IR HL');
subplot(2,4,4), imshow(HH_IR, []); title('IR HH');
subplot(2,4,5), imshow(LL_VIS, []); title('VIS LL');
subplot(2,4,6), imshow(LH_VIS, []); title('VIS LH');
subplot(2,4,7), imshow(HL_VIS, []); title('VIS HL');
subplot(2,4,8), imshow(HH_VIS, []); title('VIS HH');

% Step 5: Mask-Guided DWT Fusion
maskSmall = imresize(double(binaryMask), size(LL_IR));

% Fuse approximation coefficients using weighted mean guided by mask
LL_fused = maskSmall .* LL_IR + (1 - maskSmall) .* LL_VIS;

% Fuse detail coefficients using maximum absolute value rule
LH_fused = (abs(LH_IR) > abs(LH_VIS)) .* LH_IR + (abs(LH_IR) <= abs(LH_VIS)) .* LH_VIS;
HL_fused = (abs(HL_IR) > abs(HL_VIS)) .* HL_IR + (abs(HL_IR) <= abs(HL_VIS)) .* HL_VIS;
HH_fused = (abs(HH_IR) > abs(HH_VIS)) .* HH_IR + (abs(HH_IR) <= abs(HH_VIS)) .* HH_VIS;

% Step 6: Reconstruct the Fused Image via Inverse DWT
fusedWavelet = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');
fusedWavelet = mat2gray(fusedWavelet);

figure, imshow(fusedWavelet, []);
title('Wavelet Fused Image (IR + VIS via DWT)');

% Step 7: Simulated CNN-like Convolutional Enhancement
% Simulate light-weight convolutional refinement
conv1x1_1 = fusedWavelet;
conv3x3 = imgaussfilt(conv1x1_1, 1);   % Gaussian acts as 3x3 convolution
conv1x1_2 = conv3x3;
convEnhanced = 0.5 * fusedWavelet + 0.5 * conv1x1_2;

figure, imshow(convEnhanced, []);
title('Simulated Convolutional Enhancement');

% Step 8: Final Fusion with ROI Retention
VIS_resized = imresize(VIS, size(convEnhanced));
IR_resized = imresize(IR, size(convEnhanced));

% Blending enhanced DWT image with visible and IR inputs
fusedFinal = uint8(...
    0.4 * double(convEnhanced) + ...
    0.3 * double(rgb2gray(VIS_resized)) + ...
    0.3 * double(rgb2gray(IR_resized)));

figure, imshow(fusedFinal, []);
title('Final Fused Image (Enhancement + ROI Preservation)');

% Step 9: Fusion Quality Evaluation — SSIM and Gradient Loss
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

% Step 10: Output Visualization
figure;
subplot(1,2,1), imshow(IR, []), title('Infrared');
subplot(1,2,2), imshow(VIS, []), title('Visible');
figure
subplot(1,1,1), imshow(fusedFinal, []), title('Optimized Fused Result');