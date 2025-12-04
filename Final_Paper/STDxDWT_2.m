% hybrid_std_dwt_fusion.m
% Hybrid STD + DWT fusion: STD for masks, apply to images, DWT on masked images, STD subband fusion, IDWT
% Modified to handle arrays of images (e.g., 4 IR and 4 VI images)
% Added additional metrics to match the previous script's output (dev_ir, dev_vi, corr_ir, corr_vi)
% Updated fusion formula to F = S .* IR + (1 - S) .* VI instead of alpha/beta weights

clear; clc; close all;

% ----------------------------
% Load images as arrays (assuming 4 images each)
% ----------------------------
% Example: Replace with your actual loading if needed
% For demonstration, loading the same images multiple times; in practice, load different ones
ir = {im2double(imread("manWalkIR.jpg")), im2double(imread("IR_helib_011.bmp")), im2double(imread("IR_lake_g.bmp")), im2double(imread("IR_meting016_g.bmp"))};
vi = {im2double(imread("manWalkVB.jpg")), im2double(imread("VIS_helib_011.bmp")), im2double(imread("VIS_lake_r.bmp")), im2double(imread("VIS_meting016_r.bmp"))};

numImages = length(ir);  % Should be 4

% Initialize storage for metrics and fused images
metrics = struct('psnr_ir', [], 'psnr_vi', [], 'entropy_fused', [], 'std_fused', [], 'SF', [], 'ssim_ir', [], 'ssim_vi', [], ...
                 'dev_ir', [], 'dev_vi', [], 'corr_ir', [], 'corr_vi', []);
fused_images = cell(1, numImages);

% Loop over each image pair
for idx = 1:numImages
    fprintf('Processing image pair %d/%d...\n', idx, numImages);
    
    % Current images
    ir_curr = ir{idx};
    vi_curr = vi{idx};
    
    % Convert both to grayscale if RGB
    if size(ir_curr,3) > 1
        ir_gray = rgb2gray(ir_curr);
    else
        ir_gray = ir_curr;
    end
    
    if size(vi_curr,3) > 1
        vi_gray = rgb2gray(vi_curr);
    else
        vi_gray = vi_curr;
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
    % Fuse subbands using STD fusion (updated formula: F = S .* IR + (1 - S) .* VI)
    % ----------------------------
    % Resize masks to subband sizes (all subbands same size for level 1)
    sal_mask_sub = imresize(salient_mask, 'OutputSize', size(sal_irA));
    bg_mask_sub = imresize(background_mask, 'OutputSize', size(bg_irA));
    
    % Fuse salient subbands with STD (F = S .* IR + (1 - S) .* VI)
    fused_sal_A = sal_mask_sub .* sal_irA + (1 - sal_mask_sub) .* sal_viA;
    fused_sal_H = sal_mask_sub .* sal_irH + (1 - sal_mask_sub) .* sal_viH;
    fused_sal_V = sal_mask_sub .* sal_irV + (1 - sal_mask_sub) .* sal_viV;
    fused_sal_D = sal_mask_sub .* sal_irD + (1 - sal_mask_sub) .* sal_viD;
    
    % Fuse background subbands with STD (F = S .* IR + (1 - S) .* VI)
    fused_bg_A = bg_mask_sub .* bg_irA + (1 - bg_mask_sub) .* bg_viA;
    fused_bg_H = bg_mask_sub .* bg_irH + (1 - bg_mask_sub) .* bg_viH;
    fused_bg_V = bg_mask_sub .* bg_irV + (1 - bg_mask_sub) .* bg_viV;
    fused_bg_D = bg_mask_sub .* bg_irD + (1 - bg_mask_sub) .* bg_viD;
    
    % ----------------------------
    % IDWT reconstruction
    % ----------------------------
    fused_salient = idwt2(fused_sal_A, fused_sal_H, fused_sal_V, fused_sal_D, waveletType);
    fused_background = idwt2(fused_bg_A, fused_bg_H, fused_bg_V, fused_bg_D, waveletType);
    
    % Combine salient and background fused images
    fused = fused_salient + fused_background;
    
    % Normalize fused image
    fused_gray = im2double(mat2gray(fused));
    
    % Store fused image
    fused_images{idx} = fused_gray;
    
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
    
    % Spatial Frequency
    RF = sqrt(mean(diff(fused_gray,1,1).^2,'all'));
    CF = sqrt(mean(diff(fused_gray,1,2).^2,'all'));
    SF = sqrt(RF^2 + CF^2);
    
    % SSIM
    ssim_ir = ssim(fused_gray, ir_resized);
    ssim_vi = ssim(fused_gray, vi_resized);
    
    % Deviation (relative error) - Added epsilon to avoid division by zero
    dev_ir = deviation_1(fused_gray, ir_resized);
    dev_vi = deviation_1(fused_gray, vi_resized);
    
    % Correlation
    corr_ir = corr2(fused_gray, ir_resized);
    corr_vi = corr2(fused_gray, vi_resized);
    
    % Store metrics
    metrics(idx).psnr_ir = psnr_ir;
    metrics(idx).psnr_vi = psnr_vi;
    metrics(idx).entropy_fused = entropy_fused;
    metrics(idx).SF = SF;
    metrics(idx).ssim_ir = ssim_ir;
    metrics(idx).ssim_vi = ssim_vi;
    metrics(idx).dev_ir = dev_ir;
    metrics(idx).dev_vi = dev_vi;
    metrics(idx).corr_ir = corr_ir;
    metrics(idx).corr_vi = corr_vi;
    
    % Display metrics for this image
    fprintf('--- Metrics for Image Pair %d ---\n', idx);
    fprintf('PSNR (Fused vs VI): %.4f dB\n', psnr_vi);
    fprintf('PSNR (Fused vs IR): %.4f dB\n', psnr_ir);
    fprintf('Entropy (Fused): %.4f\n', entropy_fused);
    fprintf('Spatial Frequency (Fused): %.4f\n', SF);
    fprintf('SSIM (Fused vs VI): %.4f\n', ssim_vi);
    fprintf('SSIM (Fused vs IR): %.4f\n', ssim_ir);
    fprintf('Correlation vs VI: %.4f\n', corr_vi);
    fprintf('Correlation vs IR: %.4f\n', corr_ir);
    fprintf('Deviation vs VI: %.6f\n', dev_vi);
    fprintf('Deviation vs IR: %.6f\n', dev_ir);
    fprintf('\n');
end

% ----------------------------
% Overall Summary
% ----------------------------
fprintf('--- Overall Summary for All %d Images ---\n', numImages);
for idx = 1:numImages
    fprintf(['Image %d: PSNR_IR=%.4f, PSNR_VI=%.4f, Entropy=%.4f, SF=%.4f, SSIM_IR=%.4f, SSIM_VI=%.4f, ', ...
             'Dev_IR=%.6f, Dev_VI=%.6f, Corr_IR=%.4f, Corr_VI=%.4f\n'], ...
            idx, metrics(idx).psnr_ir, metrics(idx).psnr_vi, metrics(idx).entropy_fused, ...
            metrics(idx).SF, metrics(idx).ssim_ir, metrics(idx).ssim_vi, ...
            metrics(idx).dev_ir, metrics(idx).dev_vi, metrics(idx).corr_ir, metrics(idx).corr_vi);
end

% ----------------------------
% Visualization (showing first image pair as example; adjust as needed)
% ----------------------------
figure('Name','Hybrid STD + DWT Fusion (First Pair)','Color','w');
tiledlayout(2,3,'TileSpacing','compact');
nexttile; imshow(ir_gray,[]); title('Infrared');
nexttile; imshow(vi_gray,[]); title('Visible');
nexttile; imshow(salient_mask,[]); title('Salient Mask');
nexttile; imshow(background_mask,[]); title('Background Mask');
nexttile; imshow(salient_ir,[]); title('Salient IR');
nexttile; imshow(fused_images{1},[]); title('Fused Output (Pair 1)');

% Optional: Display all fused images in a montage
figure('Name','All Fused Images','Color','w');
montage(fused_images, 'Size', [2 2]);  % Assuming 4 images, 2x2 grid
title('Montage of All Fused Images');