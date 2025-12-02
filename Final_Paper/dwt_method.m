clc; clear all; close all;

% Read and preprocess images
IR = imread("IR_lake_g.bmp");
VIS = imread("VIS_lake_r.bmp");

% Original images display
figure(1)
subplot(1,2,1); imshow(IR, []); title('Infrared Image');
subplot(1,2,2); imshow(VIS, []); title('Visible Image');

% Convert to grayscale if required
if size(IR,3) == 3
    IR = rgb2gray(IR);
end
if size(VIS,3) == 3
    VIS = rgb2gray(VIS);
end

% Resize VIS image to match IR
[rows, cols] = size(IR);
VIS = imresize(VIS, [rows cols]);

% Convert to double
IR  = im2double(IR);
VIS = im2double(VIS);

% ---- DWT Decomposition ----
[LL_IR, LH_IR, HL_IR, HH_IR]   = dwt2(IR , 'db2');
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db2');

% ---- Fusion Rules ----

% Approximation – averaging rule
LL_fused = (LL_IR + LL_VIS) / 2;

% Variance-based detail coefficient fusion
LH_fused = LH_IR; if var(LH_VIS(:)) > var(LH_IR(:)), LH_fused = LH_VIS; end
HL_fused = HL_IR; if var(HL_VIS(:)) > var(HL_IR(:)), HL_fused = HL_VIS; end
HH_fused = HH_IR; if var(HH_VIS(:)) > var(HH_IR(:)), HH_fused = HH_VIS; end

% ---- IDWT Reconstruction ----
fused = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');
fused = imresize(fused, size(IR));
fused = mat2gray(fused);
fusedUint8 = im2uint8(fused);

% =============================
% Metrics Calculation
% =============================

% Entropy
entropy_fused = entropy(fused);

% deviation (your function must exist as deviation_1.m)
dev = deviation_1(VIS, fused);

% PSNR
% psnr_ir = psnr(fusedUint8, im2uint8(IR));
psnr_vi = psnr(fusedUint8, im2uint8(VIS));

% Spatial Frequency (SF)
RF = sqrt(mean(diff(fused,1,1).^2,'all'));
CF = sqrt(mean(diff(fused,1,2).^2,'all'));
SF = sqrt(RF^2 + CF^2);

% SSIM
% ssim_ir = ssim(fusedUint8, im2uint8(IR));
ssim_vi = ssim(fusedUint8, im2uint8(VIS));

% Correlation coefficient
corr_vi = corr2(fused, VIS);

% =============================
% Display Metrics
% =============================
fprintf('\n----- Fusion Performance Metrics -----\n');


fprintf('PSNR (fused vs Visible): %.4f dB\n', psnr_vi);
fprintf('Entropy: %.4f\n', entropy_fused);
fprintf('Spatial Frequency: %.4f\n', SF);
fprintf('SSIM (fused vs Visible): %.4f\n', ssim_vi);
fprintf('Correlation Coefficient (fused vs IR): %.4f\n', corr_vi);
fprintf('Deviation: %.4f\n', dev);
% =============================
% Visualization
% =============================
figure('Color','w');
tiledlayout(2,2,'TileSpacing','compact');

nexttile; imshow(IR, []); title('Infrared Image');
nexttile; imshow(VIS, []); title('Visible Image');
nexttile; imshow(fused, []); title('Fused Image (Variance + Average Rule)');
