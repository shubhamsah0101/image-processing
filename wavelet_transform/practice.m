clc; clear; close all;

% Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure(1)
imshow(IR); title('Original Infrared Image');

% Preprocess Infrared Image
grayIR = rgb2gray(IR);
figure(2)
imhist(grayIR); title('Histogram of Infrared Grayscale Image');

smoothedIR = imgaussfilt(grayIR, 2);  % Gaussian smoothing
level = graythresh(smoothedIR);      % Otsu threshold
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);

binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove small fragments

% Apply Mask to IR Image and VIS Image
maskedIR = IR;
maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
figure(3)
imshow(maskedIR); title('Masked IR Image (Auto ROI)');

maskedVIS = VIS;
maskedVIS(repmat(~binaryMask, [1 1 3])) = 0;
figure(4)
imshow(maskedVIS); title('Masked VIS Image (Auto ROI)');

figure(5)
imshow(binaryMask); title('Binary Mask');

% apply dwt:

% Convert to double precision for processing
IR = im2double(IR);
VIS = im2double(VIS);

% Apply single-level DWT
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(IR, 'db2', 2);
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db2', 2);

% Fuse approximation coefficients as average
LL_fused = (0.6*LL_IR + 0.4*LL_VIS);

% Compute variances of detail coefficients
var_LH_IR = var(LH_IR(:));
var_LH_VIS = var(LH_VIS(:));
var_HL_IR = var(HL_IR(:));
var_HL_VIS = var(HL_VIS(:));
var_HH_IR = var(HH_IR(:));
var_HH_VIS = var(HH_VIS(:));

% Fuse detail coefficients by selecting based on higher variance
if var_LH_IR > var_LH_VIS
    LH_fused = LH_IR;
else
    LH_fused = LH_VIS;
end

if var_HL_IR > var_HL_VIS
    HL_fused = HL_IR;
else
    HL_fused = HL_VIS;
end

if var_HH_IR > var_HH_VIS
    HH_fused = HH_IR;
else
    HH_fused = HH_VIS;
end

