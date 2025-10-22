clc; clear; close all;
% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

% Step 2: Preprocess IR Image and Create ROI Mask
grayIR = rgb2gray(IR);
smoothedIR = imgaussfilt(grayIR, 2);        % Gaussian smoothing for noise reduction
level = graythresh(smoothedIR);             % Otsu global thresholding
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);
binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5)); % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);           % Remove small regions
figure, imshow(binaryMask); title('Binary Mask from IR');

% Step 3: Masked Images for visualization
maskedIR = grayIR .* uint8(binaryMask);
maskedVIS = rgb2gray(VIS) .* uint8(~binaryMask);
figure, imshow(maskedIR, []); title('Masked IR (Target)');
figure, imshow(maskedVIS, []); title('Masked VIS (Background)');

% Step 4: DWT Decomposition on Masked Images
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(double(maskedIR), 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(double(maskedVIS), 'db2');

% Step 5: Compute Entropy of Approximation Coefficients and Weights
entropy_IR = entropy(uint8(mat2gray(LL_IR) * 255));
entropy_VIS = entropy(uint8(mat2gray(LL_VIS) * 255));
weight_IR = entropy_IR / (entropy_IR + entropy_VIS);
weight_VIS = entropy_VIS / (entropy_IR + entropy_VIS);
fprintf('Entropy IR: %.4f, Entropy VIS: %.4f, Weights IR: %.4f, VIS: %.4f\n', ...
    entropy_IR, entropy_VIS, weight_IR, weight_VIS);

% Step 6: Entropy-weighted fusion of approximation coefficients + max abs fusion of detail coeffs
maskSmall = imresize(double(binaryMask), size(LL_IR));
LL_fused = weight_IR * LL_IR + weight_VIS * LL_VIS;
LH_fused = (abs(LH_IR) > abs(LH_VIS)) .* LH_IR + (abs(LH_IR) <= abs(LH_VIS)) .* LH_VIS;
HL_fused = (abs(HL_IR) > abs(HL_VIS)) .* HL_IR + (abs(HL_IR) <= abs(HL_VIS)) .* HL_VIS;
HH_fused = (abs(HH_IR) > abs(HH_VIS)) .* HH_IR + (abs(HH_IR) <= abs(HH_VIS)) .* HH_VIS;

% Step 7: Inverse DWT reconstruction
fusedWavelet = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');
fusedWavelet = mat2gray(fusedWavelet);

% Step 8: Adaptive Histogram Equalization (CLAHE) for contrast enhancement
fusedEnhanced = adapthisteq(fusedWavelet, 'ClipLimit', 0.03);

% Step 9: Resize inputs for final blending
VIS_gray = rgb2gray(VIS);
VIS_resized = imresize(VIS_gray, size(fusedEnhanced));
IR_resized = imresize(grayIR, size(fusedEnhanced));

% Step 10: Create Soft Gaussian Mask for smooth blending
softMask = imgaussfilt(double(binaryMask), 5);
softMask = mat2gray(softMask);
softMaskCompl = 1 - softMask;

% Step 11: Soft-mask guided weighted blending balancing entropy and SSIM
% Blend fusedEnhanced & IR inside ROI, VIS outside ROI
alpha = 0.5;  % Weight for fused enhanced image inside ROI
beta = 0.3;   % Weight for IR image inside ROI
gamma = 0.7;  % Weight for VIS image outside ROI
fusedFinalDouble = ...
    (alpha * fusedEnhanced + beta * double(IR_resized) / 255) .* softMask + ...
    gamma * double(VIS_resized) / 255 .* softMaskCompl;
fusedFinalDouble = mat2gray(fusedFinalDouble);
fusedFinal = uint8(fusedFinalDouble * 255);

% Step 11.1: Selective Mild CLAHE only on Background to Boost Entropy
tempFused = im2double(fusedFinal);

% Apply CLAHE only on background using soft mask complement
roiPart = tempFused .* softMask;          % Keep ROI as is
backgroundPart = tempFused .* softMaskCompl;
backgroundEnhanced = adapthisteq(backgroundPart, 'ClipLimit', 0.005);

% Combine ROI and enhanced background
enhancedFusedSelective = roiPart + backgroundEnhanced;

% Normalize and convert back to uint8
enhancedFusedSelective = mat2gray(enhancedFusedSelective);
fusedFinal = im2uint8(enhancedFusedSelective);

% Step 12: Fusion quality evaluation - SSIM and gradient loss
ssimVal = ssim(fusedFinal, rgb2gray(imresize(VIS, size(fusedFinal))));
fusedGray = mat2gray(fusedFinal);
refGray = mat2gray(rgb2gray(imresize(VIS, size(fusedFinal))));
G_fused = imgradient(fusedGray, 'sobel');
G_ref = imgradient(refGray, 'sobel');
L_grad = mean(abs(G_fused - G_ref), 'all') / 255;
L_ssim = 1 - ssimVal;
L_total = L_ssim + L_grad;

fprintf('\n--- Fusion Performance Metrics ---\n');
fprintf('SSIM Loss      : %.4f\n', L_ssim);
fprintf('Gradient Loss  : %.4f\n', L_grad);
fprintf('Total Loss     : %.4f\n', L_total);
entropyVal = entropy(fusedFinal);
fprintf('Entropy        : %.4f\n', entropyVal);

% Step 13: Visualization
figure;
subplot(1,2,1), imshow(IR, []), title('Infrared');
subplot(1,2,2), imshow(VIS, []), title('Visible');
figure;
imshow(fusedFinal);
title(sprintf('Selective CLAHE Fusion (SSIM=%.4f, Entropy=%.4f)', ssimVal, entropyVal));