clc; clear all; close all;

% Read and preprocess images
IR = imread("IR_lake_g.bmp");
VIS = imread("VIS_lake_r.bmp");

% Show originals
figure(1)
subplot(1,2,1); imshow(IR, []); title('Infrared Image');
subplot(1,2,2); imshow(VIS, []); title('Visible Image');

% Convert to grayscale if necessary
if size(IR,3) == 3, IR = rgb2gray(IR); end
if size(VIS,3) == 3, VIS = rgb2gray(VIS); end

sz = size(VIS);

% Resize both to same target size
targetSize = [sz(1) sz(2)];

% Convert to double
IR = im2double(IR);
VIS = im2double(VIS);

% ------------- DWT -------------
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(IR, 'db2', 2);
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db2', 2);

% Fuse LL by averaging
LL_fused = (LL_IR + LL_VIS) / 2;

% Fuse detail coefficients by variance
LH_fused = LH_IR; if var(LH_VIS(:)) > var(LH_IR(:)), LH_fused = LH_VIS; end
HL_fused = HL_IR; if var(HL_VIS(:)) > var(HL_IR(:)), HL_fused = HL_VIS; end
HH_fused = HH_IR; if var(HH_VIS(:)) > var(HH_IR(:)), HH_fused = HH_VIS; end

% ------------- Reconstruct fused image -------------
Fused = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');
Fused = mat2gray(Fused);
fusedUint8 = im2uint8(Fused);

% ================= QUALITY METRICS =================

% -------- Ensure fused image matches IR size --------
Fused = imresize(Fused, size(IR));
fusedUint8 = im2uint8(Fused);

% 1. Entropy
EntropyVal = entropy(Fused);

% 2. Spatial Frequency
Fx = diff(Fused,1,2);
Fy = diff(Fused,1,1);
SF = sqrt(mean(Fx(:).^2) + mean(Fy(:).^2));

% 3. Standard Deviation
Deviation = std(Fused(:));

% 4. PSNR
PSNRval = psnr(fusedUint8, im2uint8(IR));

% 5. SSIM
SSIMval = ssim(fusedUint8, im2uint8(IR));

% 6. correlation coefficient
c = corr2(fusedUint8, Fused);

% Print results
fprintf('\n=== FUSION METRICS ===\n');
fprintf('Entropy          : %.4f\n', EntropyVal);
fprintf('Spatial Frequency: %.4f\n', SF);
fprintf('PSNR             : %.4f dB\n', PSNRval);
fprintf('Std Deviation    : %.4f\n', Deviation);
fprintf('SSIM             : %.4f\n\n', SSIMval);
fprintf('CC             : %.4f\n\n', c);

% Show fused image
figure(2)
imshow(Fused, []);
title("Fused Image (Variance-based DWT)");
