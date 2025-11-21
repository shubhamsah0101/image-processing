% hybrid_std_dwt_fusion.m
% Hybrid STD + DWT fusion: STD for masks, apply to images, DWT on masked images, STD subband fusion, IDWT

clear; clc; close all;

% ----------------------------
% Load images
% ----------------------------
ir = im2double(imread('manWalkIR.jpg'));        % infrared image
vi = im2double(imread('manWalkVB.jpg'));        % visible image

% Convert both to grayscale if RGB
if size(ir,3) > 1
    ir_gray = rgb2gray(ir);
else
    ir_gray = ir;
end

if size(vi,3) > 1
    vi_gray = rgb2gray(vi);
else
    vi_gray = vi;
end

% Resize both to same target size
targetSize = [256 256];
ir_gray = imresize(ir_gray, targetSize);
vi_gray = imresize(vi_gray, targetSize);

% ----------------------------
% STD fusion to obtain background and salient masks
% ----------------------------
% Saliency mask from IR (salient regions)
salient_mask = imbinarize(mat2gray(ir_gray),'adaptive');
salient_mask = imgaussfilt(double(salient_mask),2);
salient_mask = mat2gray(salient_mask);

% Background mask (non-salient regions)
background_mask = 1 - salient_mask;

% ----------------------------
% Apply masks to visible and IR images
% ----------------------------
% Salient parts
salient_ir = ir_gray .* salient_mask;
salient_vi = vi_gray .* salient_mask;

% Background parts
background_ir = ir_gray .* background_mask;
background_vi = vi_gray .* background_mask;

% ----------------------------
% DWT on the masked images
% ----------------------------
waveletType = 'db2';   % Daubechies-2

% DWT on salient parts
[sal_irA, sal_irH, sal_irV, sal_irD] = dwt2(salient_ir, waveletType);
[sal_viA, sal_viH, sal_viV, sal_viD] = dwt2(salient_vi, waveletType);

% DWT on background parts
[bg_irA, bg_irH, bg_irV, bg_irD] = dwt2(background_ir, waveletType);
[bg_viA, bg_viH, bg_viV, bg_viD] = dwt2(background_vi, waveletType);

% ----------------------------
% Fuse subbands using STD fusion
% ----------------------------
alpha = 0.7; beta = 0.3;

% Resize masks to subband sizes (all subbands same size for level 1)
sal_mask_sub = imresize(salient_mask, 'OutputSize', size(sal_irA));
bg_mask_sub = imresize(background_mask, 'OutputSize', size(bg_irA));

% Fuse salient subbands with STD
fused_sal_A = sal_mask_sub .* (alpha*sal_irA + beta*sal_viA) + ...
              (1-sal_mask_sub) .* (0.4*sal_irA + 0.6*sal_viA);
fused_sal_H = sal_mask_sub .* (alpha*sal_irH + beta*sal_viH) + ...
              (1-sal_mask_sub) .* (0.4*sal_irH + 0.6*sal_viH);
fused_sal_V = sal_mask_sub .* (alpha*sal_irV + beta*sal_viV) + ...
              (1-sal_mask_sub) .* (0.4*sal_irV + 0.6*sal_viV);
fused_sal_D = sal_mask_sub .* (alpha*sal_irD + beta*sal_viD) + ...
              (1-sal_mask_sub) .* (0.4*sal_irD + 0.6*sal_viD);

% Fuse background subbands with STD
fused_bg_A = bg_mask_sub .* (alpha*bg_irA + beta*bg_viA) + ...
             (1-bg_mask_sub) .* (0.4*bg_irA + 0.6*bg_viA);
fused_bg_H = bg_mask_sub .* (alpha*bg_irH + beta*bg_viH) + ...
             (1-bg_mask_sub) .* (0.4*bg_irH + 0.6*bg_viH);
fused_bg_V = bg_mask_sub .* (alpha*bg_irV + beta*bg_viV) + ...
             (1-bg_mask_sub) .* (0.4*bg_irV + 0.6*bg_viV);
fused_bg_D = bg_mask_sub .* (alpha*bg_irD + beta*bg_viD) + ...
             (1-bg_mask_sub) .* (0.4*bg_irD + 0.6*bg_viD);

% ----------------------------
% IDWT reconstruction
% ----------------------------
fused_salient = idwt2(fused_sal_A, fused_sal_H, fused_sal_V, fused_sal_D, waveletType);
fused_background = idwt2(fused_bg_A, fused_bg_H, fused_bg_V, fused_bg_D, waveletType);

% Combine salient and background fused images
fused = fused_salient + fused_background;

% Normalize fused image
fused_gray = im2double(mat2gray(fused));

% ----------------------------
% Metrics
% ----------------------------
ir_resized = im2double(mat2gray(imresize(ir_gray, 'OutputSize', [size(fused_gray, 1), size(fused_gray, 2)])));
vi_resized = im2double(mat2gray(imresize(vi_gray, 'OutputSize', [size(fused_gray, 1), size(fused_gray, 2)])));

% PSNR
psnr_ir = psnr(fused_gray, ir_resized);
psnr_vi = psnr(fused_gray, vi_resized);

% Entropy
entropy_fused = entropy(fused_gray);

% Standard Deviation
std_fused = std2(fused_gray);

% Spatial Frequency
RF = sqrt(mean(diff(fused_gray,1,1).^2,'all'));
CF = sqrt(mean(diff(fused_gray,1,2).^2,'all'));
SF = sqrt(RF^2 + CF^2);

% SSIM
ssim_ir = ssim(fused_gray, ir_resized);
ssim_vi = ssim(fused_gray, vi_resized);

% ----------------------------
% Display results
% ----------------------------
fprintf('--- Hybrid STD + DWT Fusion Metrics ---\n');
fprintf('PSNR (Fused vs IR): %.4f dB\n', psnr_ir);
fprintf('PSNR (Fused vs VI): %.4f dB\n', psnr_vi);
fprintf('Entropy (Fused): %.4f\n', entropy_fused);
fprintf('Std Deviation (Fused): %.4f\n', std_fused);
fprintf('Spatial Frequency (Fused): %.4f\n', SF);
fprintf('SSIM (Fused vs IR): %.4f\n', ssim_ir);
fprintf('SSIM (Fused vs VI): %.4f\n', ssim_vi);

% ----------------------------
% Visualization
% ----------------------------
figure('Name','Hybrid STD + DWT Fusion','Color','w');
tiledlayout(2,3,'TileSpacing','compact');
nexttile; imshow(ir_gray,[]); title('Infrared');
nexttile; imshow(vi_gray,[]); title('Visible');
nexttile; imshow(salient_mask,[]); title('Salient Mask');
nexttile; imshow(background_mask,[]); title('Background Mask');
nexttile; imshow(salient_ir,[]); title('Salient IR');
nexttile; imshow(fused_gray,[]); title('Fused Output');