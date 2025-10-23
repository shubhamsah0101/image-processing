clc; clear; close all;

% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

% Step 2: Preprocess Infrared Image
grayIR = rgb2gray(IR);
figure, imhist(grayIR); title('Histogram of Infrared Grayscale Image');

smoothedIR = imgaussfilt(grayIR, 2);  % Gaussian smoothing
level = graythresh(smoothedIR);      % Otsu threshold
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);

binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove small fragments

% Step 3: Apply Mask to IR Image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
figure; imshow(maskedIR); title('Masked IR Image (Auto ROI)');

% Step 4: Create STM and BM Masks
stm = uint8(binaryMask) * 255;
bm = uint8(~binaryMask) * 255;

% s-i, b-v
IR = stm .* IR;
VIS = bm .* VIS;

% Step 5: Applying DWT for Image Fusion
figure(1)
subplot(1,2,1); imshow(IR, []); title('Target (IR) Image');
subplot(1,2,2); imshow(VIS, []); title('Background (Visible) Image');

if size(IR,3) == 3
    IR = rgb2gray(IR);
end
if size(VIS,3) == 3
    VIS = rgb2gray(VIS);
end

% Resize visible image to match IR dimensions
[rows, cols] = size(IR);
VIS = imresize(VIS, [rows cols]);

% Convert to double precision for processing
IR = im2double(IR);
VIS = im2double(VIS);

% Apply single-level DWT
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(IR, 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db2');

% Display wavelet components for IR image
figure(2)
subplot(2,2,1); imshow(LL_IR, []); title('Approximation (LL) IR');
subplot(2,2,2); imshow(LH_IR, []); title('Horizontal Detail (LH) IR');
subplot(2,2,3); imshow(HL_IR, []); title('Vertical Detail (HL) IR');
subplot(2,2,4); imshow(HH_IR, []); title('Diagonal Detail (HH) IR');

% Display wavelet components for visible image
figure(3)
subplot(2,2,1); imshow(LL_VIS, []); title('Approximation (LL) VIS');
subplot(2,2,2); imshow(LH_VIS, []); title('Horizontal Detail (LH) VIS');
subplot(2,2,3); imshow(HL_VIS, []); title('Vertical Detail (HL) VIS');
subplot(2,2,4); imshow(HH_VIS, []); title('Diagonal Detail (HH) VIS');

% Perform simple average fusion
F_LL = 0.5 * LL_IR + 0.5 * LL_VIS;
F_LH = 0.5 * LH_IR + 0.5 * LH_VIS;
F_HL = 0.5 * HL_IR + 0.5 * HL_VIS;
F_HH = 0.5 * HH_IR + 0.5 * HH_VIS;

% Reconstruct fused image
Fused = idwt2(F_LL, F_LH, F_HL, F_HH, 'db2');

figure;
imshow(Fused, []);
title('Fused Image using Average Wavelet Fusion');

% Simulated Convolutional Enhancement
conv1x1_1 = Fused;                     % Simulated 1×1 conv
conv3x3 = imgaussfilt(conv1x1_1, 1);        % Simulated 3×3 conv
conv1x1_2 = conv3x3;                        % Simulated 1×1 conv

convEnhanced = uint8(0.5 * double(Fused) + 0.5 * double(conv1x1_2));
figure;
imshow(convEnhanced); title('Simulated Convolutional Enhancement Output');
