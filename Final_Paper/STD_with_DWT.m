% hybrid_std_dwt_fusion_array.m
% Hybrid STD + DWT fusion for arrays of IR + VI images (4 pairs)
% - STDFusion rule applied in DWT subbands (A,H,V,D)
% - Reconstruct IR_dwt, VI_dwt, and fused DWT image
% - Final spatial fusion: fused = S .* IR_dwt + (1 - S) .* VI_dwt
% - Computes Entropy, PSNR, Std, SF, SSIM, Deviation, Correlation
clear; clc; close all;

% ----------------------------
% INPUT arrays (4 IR + 4 VI)
% ----------------------------
ir = {im2double(imread("IR_lake_g.bmp")), im2double(imread("manWalkIR.jpg")), ...
      im2double(imread("IR_meting016_g.bmp")), im2double(imread("IR_helib_011.bmp"))};

vi = {im2double(imread("VIS_lake_r.bmp")), im2double(imread("manWalkVB.jpg")), ...
      im2double(imread("VIS_meting016_r.bmp")), im2double(imread("VIS_helib_011.bmp"))};

numImages = min(length(ir), length(vi)); % expect 4
targetSize = [256 256];                  % consistent processing size
waveletType = 'db2';
eps_small = 1e-10;

% Prealloc storage
fused_images = cell(1, numImages);
metrics = repmat(struct('psnr_ir',[],'psnr_vi',[],'entropy',[],'std',[],'SF',[],...
    'ssim_ir',[],'ssim_vi',[],'dev_ir',[],'dev_vi',[],'corr_ir',[],'corr_vi',[]),1,numImages);

for idx = 1:numImages
    fprintf('Processing image pair %d/%d...\n', idx, numImages);
    
    % ----------------------------
    % Load and grayscale (simple)
    % ----------------------------
    ir_raw = ir{idx};
    vi_raw = vi{idx};
    if ndims(ir_raw)==3 && size(ir_raw,3)==3
        ir_gray = rgb2gray(ir_raw);
    else
        ir_gray = ir_raw;
    end
    if ndims(vi_raw)==3 && size(vi_raw,3)==3
        vi_gray = rgb2gray(vi_raw);
    else
        vi_gray = vi_raw;
    end
    
    % Resize to target size
    ir_gray = imresize(ir_gray, targetSize);
    vi_gray = imresize(vi_gray, targetSize);
    
    % Normalize inputs to [0,1]
    ir_n = mat2gray(ir_gray);
    vi_n = mat2gray(vi_gray);
    
    % ----------------------------
    % Saliency mask S (from IR)
    % ----------------------------
    S = imbinarize(mat2gray(ir_n), 'adaptive');   % binary saliency
    S = imgaussfilt(double(S), 1.5);              % soften
    S = mat2gray(S);
    B = 1 - S;
    
    % ----------------------------
    % DWT of original IR & VI
    % ----------------------------
    [LL_ir, LH_ir, HL_ir, HH_ir] = dwt2(ir_n, waveletType);
    [LL_vi, LH_vi, HL_vi, HH_vi] = dwt2(vi_n, waveletType);
    
    % ----------------------------
    % Resize saliency to subband sizes
    % (subbands are half-size for single-level dwt2)
    % ----------------------------
    S_A = imresize(S, size(LL_ir));
    S_H = imresize(S, size(LH_ir));
    S_V = imresize(S, size(HL_ir));
    S_D = imresize(S, size(HH_ir));
    B_A = 1 - S_A;
    B_H = 1 - S_H;
    B_V = 1 - S_V;
    B_D = 1 - S_D;
    
    % ----------------------------
    % STDFusion rule inside *all* subbands
    % F_sub = S_sub .* IR_sub + (1 - S_sub) .* VI_sub
    % ----------------------------
    F_A = S_A .* LL_ir + (1 - S_A) .* LL_vi;
    F_H = S_H .* LH_ir + (1 - S_H) .* LH_vi;
    F_V = S_V .* HL_ir + (1 - S_V) .* HL_vi;
    F_D = S_D .* HH_ir + (1 - S_D) .* HH_vi;
    
    % ----------------------------
    % Reconstruct IR_dwt, VI_dwt, and coarse fused DWT image
    % ----------------------------
    IR_dwt = idwt2(LL_ir, LH_ir, HL_ir, HH_ir, waveletType);
    VI_dwt = idwt2(LL_vi, LH_vi, HL_vi, HH_vi, waveletType);
    F_dwt_coarse = idwt2(F_A, F_H, F_V, F_D, waveletType);
    
    % Resize reconstructed DWT images back to original target size
    IR_dwt = imresize(IR_dwt, size(ir_n));
    VI_dwt = imresize(VI_dwt, size(ir_n));
    F_dwt_coarse = imresize(F_dwt_coarse, size(ir_n));
    
    % Normalize reconstructions
    IR_dwt = mat2gray(IR_dwt);
    VI_dwt = mat2gray(VI_dwt);
    F_dwt_coarse = mat2gray(F_dwt_coarse);
    
    % ----------------------------
    % FINAL spatial fusion using reconstructed IR_dwt & VI_dwt
    % fused = S .* IR_dwt + (1 - S) .* VI_dwt
    % ----------------------------
    fused_spatial = S .* IR_dwt + (1 - S) .* VI_dwt;
    
    % Optionally combine fused_spatial with F_dwt_coarse (hybrid)
    % The code below uses alpha=0.5 to mix them
    alpha = 0.5;
    fused_final = alpha .* fused_spatial + (1 - alpha) .* F_dwt_coarse;
    
    fused_gray = mat2gray(fused_final);
    fused_images{idx} = fused_gray;
    
    % ----------------------------
    % Metrics (consistent normalized refs)
    % ----------------------------
    ir_ref = mat2gray(ir_n);
    vi_ref = mat2gray(vi_n);
    F = fused_gray;
    
    % PSNR
    psnr_ir = psnr(F, ir_ref);
    psnr_vi = psnr(F, vi_ref);

    % Entropy
    entropy_fused = entropy(F);

    % Std dev
    std_fused = std2(F);

    % Spatial frequency
    RF = sqrt(mean(diff(F,1,1).^2,'all'));
    CF = sqrt(mean(diff(F,1,2).^2,'all'));
    SF = sqrt(RF^2 + CF^2);

    % SSIM
    ssim_ir = ssim(F, ir_ref);
    ssim_vi = ssim(F, vi_ref);

    % Deviation
    dev_ir = deviation_1(F, ir_ref);
    dev_vi = deviation_1(F, vi_ref);

    % Correlation
    corr_ir = corr2(F, ir_ref);
    corr_vi = corr2(F, vi_ref);
    
    % Store metrics
    metrics(idx).psnr_ir = psnr_ir;
    metrics(idx).psnr_vi = psnr_vi;
    metrics(idx).entropy = entropy_fused;
    metrics(idx).std = std_fused;
    metrics(idx).SF = SF;
    metrics(idx).ssim_ir = ssim_ir;
    metrics(idx).ssim_vi = ssim_vi;
    metrics(idx).dev_ir = dev_ir;
    metrics(idx).dev_vi = dev_vi;
    metrics(idx).corr_ir = corr_ir;
    metrics(idx).corr_vi = corr_vi;
    
    % Print per-pair summary
    fprintf('--- Metrics for Pair %d ---\n', idx);
    fprintf('PSNR vs IR: %.4f dB, PSNR vs VI: %.4f dB\n', psnr_ir, psnr_vi);
    fprintf('Entropy: %.4f, Std: %.4f, SF: %.4f\n', entropy_fused, std_fused, SF);
    fprintf('SSIM vs IR: %.4f, SSIM vs VI: %.4f\n', ssim_ir, ssim_vi);
    fprintf('Dev vs IR: %.6f, Dev vs VI: %.6f\n', dev_ir, dev_vi);
    fprintf('Corr vs IR: %.4f, Corr vs VI: %.4f\n\n', corr_ir, corr_vi);
end

% ----------------------------
% Overall summary
% ----------------------------
fprintf('--- Overall Summary for %d pairs ---\n', numImages);

for idx = 1:numImages
    fprintf(['Image %d: PSNR_IR=%.4f, PSNR_VI=%.4f, Entropy=%.4f, Std=%.4f, SF=%.4f, ', ...
             'SSIM_IR=%.4f, SSIM_VI=%.4f, Dev_IR=%.6f, Dev_VI=%.6f, Corr_IR=%.4f, Corr_VI=%.4f\n'], ...
            idx, metrics(idx).psnr_ir, metrics(idx).psnr_vi, metrics(idx).entropy, metrics(idx).std, ...
            metrics(idx).SF, metrics(idx).ssim_ir, metrics(idx).ssim_vi, metrics(idx).dev_ir, metrics(idx).dev_vi, ...
            metrics(idx).corr_ir, metrics(idx).corr_vi);
end

% ----------------------------
% Visualize first pair + montage
% ----------------------------
figure('Name','Hybrid STD+DWT (Pair 1)','Color','w');
tiledlayout(2,3,'TileSpacing','compact');

% show original IR/VI (resized)
nexttile; imshow(ir_n,[]); title('Infrared (resized)');
nexttile; imshow(vi_n,[]); title('Visible (resized)');
nexttile; imshow(S,[]); title('Saliency Map (S)');
nexttile; imshow(F_dwt_coarse,[]); title('DWT Coarse Fusion (reconstructed)');
nexttile; imshow(fused_images{1},[]); title('Final Hybrid Fusion');

% show IR_dwt and VI_dwt for inspection
nexttile; imshow(IR_dwt,[]); title('IR reconstructed from DWT');

figure('Name','All Fused Images','Color','w');
montage(fused_images, 'Size', [2 2]);
title('Montage of Final Fused Outputs');