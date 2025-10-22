% image fusion using Wavelet :-

clc; clear all; close all;

% Read and preprocess images
IR = imread("manWalkIR.jpg");
VIS = imread("manWalkVB.jpg");

% Original images display
figure(1)
subplot(1,2,1); imshow(IR, []); title('Infrared Image');
subplot(1,2,2); imshow(VIS, []); title('Visible Image');

% Convert to grayscale if necessary
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

% Display wavelet components for infrared image
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

% Reconstruct fused image from fused coefficients
Fused = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');

% Display fused image
figure(4)
imshow(Fused, []);
title("Fused Image using Variance-based Fusion for Details")
