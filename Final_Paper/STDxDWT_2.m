% Combine STD masks + masked DWT + STD fusion, WITHOUT IDWT
% Final fusion is direct STD fusion (like your first program)
% Modified to handle arrays of images (e.g., 4 IR and 4 VI images)
% Computes PSNR, Entropy, Std Dev, Spatial Frequency, SSIM, Correlation

clear; clc; close all;

%% ----------------------------
% Load images as arrays (4 images each)
% ----------------------------
ir = {im2double(imread("IR_lake_g.bmp")), im2double(imread("manWalkIR.jpg")), ...
      im2double(imread("IR_meting016_g.bmp")), im2double(imread("IR_helib_011.bmp"))};
vi = {im2double(imread("VIS_lake_r.bmp")), im2double(imread("manWalkVB.jpg")), ...
      im2double(imread("VIS_meting016_r.bmp")), im2double(imread("VIS_helib_011.bmp"))};

numImages = length(ir);  % Should be 4

% Initialize storage for metrics and fused images
metrics = struct('psnr_ir', [], 'psnr_vi', [], 'entropy_fused', [], ...
                 'std_fused', [], 'SF', [], 'ssim_ir', [], 'ssim_vi', [], ...
                 'corr_ir', [], 'corr_vi', []);
fused_images = cell(1, numImages);

% Loop over each image pair
for idx = 1:numImages
    fprintf('Processing image pair %d/%d...\n', idx, numImages);
    
    % Current images
    ir_curr = ir{idx};
    vi_curr = vi{idx};
    
    if size(ir_curr,3) > 1, ir_gray = rgb2gray(ir_curr); else, ir_gray = ir_curr; end
    if size(vi_curr,3) > 1, vi_gray = rgb2gray(vi_curr); else, vi_gray = vi_curr; end
    
    targetSize = [256 256];
    ir_gray = imresize(ir_gray, targetSize);
    vi_gray = imresize(vi_gray, targetSize);
    
    %% ----------------------------
    % Saliency + background masks
    % ----------------------------
    salient_mask = imbinarize(mat2gray(ir_gray),'adaptive');
    salient_mask = imgaussfilt(double(salient_mask),2);
    salient_mask = mat2gray(salient_mask);
    
    background_mask = 1 - salient_mask;
    
    %% ----------------------------
    % Apply masks
    % ----------------------------
    sal_ir = ir_gray .* salient_mask;
    sal_vi = vi_gray .* salient_mask;
    
    bg_ir  = ir_gray .* background_mask;
    bg_vi  = vi_gray .* background_mask;
    
    %% ----------------------------
    % DWT on masked images
    % ----------------------------
    waveletType = 'db2';
    
    [siA, siH, siV, siD] = dwt2(sal_ir, waveletType);
    [svA, svH, svV, svD] = dwt2(sal_vi, waveletType);
    
    [biA, biH, biV, biD] = dwt2(bg_ir, waveletType);
    [bvA, bvH, bvV, bvD] = dwt2(bg_vi, waveletType);
    
    %% ----------------------------
    % Fuse subbands using STD rule
    % ----------------------------
    alpha = 0.7; beta = 0.3;
    
    sal_mask_sub = imresize(salient_mask, size(siA));
    bg_mask_sub  = imresize(background_mask, size(biA));
    
    % Salient fusion
    fA_sal = sal_mask_sub .* (alpha*siA + beta*svA) + (1-sal_mask_sub) .* (0.4*siA + 0.6*svA);
    fH_sal = sal_mask_sub .* (alpha*siH + beta*svH) + (1-sal_mask_sub) .* (0.4*siH + 0.6*svH);
    fV_sal = sal_mask_sub .* (alpha*siV + beta*svV) + (1-sal_mask_sub) .* (0.4*siV + 0.6*svV);
    fD_sal = sal_mask_sub .* (alpha*siD + beta*svD) + (1-sal_mask_sub) .* (0.4*siD + 0.6*svD);
    
    % Background fusion
    fA_bg = bg_mask_sub .* (alpha*biA + beta*bvA) + (1-bg_mask_sub) .* (0.4*biA + 0.6*bvA);
    fH_bg = bg_mask_sub .* (alpha*biH + beta*bvH) + (1-bg_mask_sub) .* (0.4*biH + 0.6*bvH);
    fV_bg = bg_mask_sub .* (alpha*biV + beta*bvV) + (1-bg_mask_sub) .* (0.4*biV + 0.6*bvV);
    fD_bg = bg_mask_sub .* (alpha*biD + beta*bvD) + (1-bg_mask_sub) .* (0.4*biD + 0.6*bvD);
    
    %% ----------------------------
    % STD Fusion (FINAL FUSION, NO IDWT)
    % ----------------------------
    sal_recon = fA_sal + (fH_sal + fV_sal + fD_sal)/3;
    bg_recon  = fA_bg  + (fH_bg  + fV_bg  + fD_bg )/3;
    
    combined = sal_recon + bg_recon;
    
    fused = salient_mask .* (alpha*ir_gray + beta*vi_gray) + ...
            background_mask .* (0.4*ir_gray + 0.6*vi_gray);
    
    combined = imresize(combined, size(fused));
    
    fused_gray = mat2gray(fused + 0.5*combined);
    
    fused_images{idx} = fused_gray;
    
    %% ----------------------------
    % Metrics
    % ----------------------------
    ir_r = mat2gray(ir_gray);
    vi_r = mat2gray(vi_gray);
    
    psnr_ir  = psnr(fused_gray, ir_r);
    psnr_vi  = psnr(fused_gray, vi_r);
    entropy_fused = entropy(fused_gray);
    std_fused = std2(fused_gray);
    
    RF = sqrt(mean(diff(fused_gray,1,1).^2,'all'));
    CF = sqrt(mean(diff(fused_gray,1,2).^2,'all'));
    SF = sqrt(RF^2 + CF^2);
    
    ssim_ir = ssim(fused_gray, ir_r);
    ssim_vi = ssim(fused_gray, vi_r);
    
    % Correlation coefficients
    corr_ir = corr2(fused_gray, ir_r);
    corr_vi = corr2(fused_gray, vi_r);
    
    % Store metrics
    metrics(idx).psnr_ir = psnr_ir;
    metrics(idx).psnr_vi = psnr_vi;
    metrics(idx).entropy_fused = entropy_fused;
    metrics(idx).std_fused = std_fused;
    metrics(idx).SF = SF;
    metrics(idx).ssim_ir = ssim_ir;
    metrics(idx).ssim_vi = ssim_vi;
    metrics(idx).corr_ir = corr_ir;
    metrics(idx).corr_vi = corr_vi;
    
    %% ----------------------------
    % Results for this image
    % ----------------------------
    fprintf("\n--- Combined STD + DWT (No IDWT) for Image Pair %d ---\n", idx);
    fprintf("PSNR vs IR: %.4f dB\n", psnr_ir);
    % fprintf("PSNR vs VI: %.4f dB\n", psnr_vi);
    fprintf("Entropy: %.4f\n", entropy_fused);
    fprintf("Std Dev: %.4f\n", std_fused);
    fprintf("Spatial Freq: %.4f\n", SF);
    fprintf("SSIM vs IR: %.4f\n", ssim_ir);
    % fprintf("SSIM vs VI: %.4f\n", ssim_vi);
    fprintf("Correlation vs IR: %.4f\n", corr_ir);
    % fprintf("Correlation vs VI: %.4f\n", corr_vi);
    fprintf('\n');
end

% ----------------------------
% Overall Summary
% ----------------------------
fprintf('--- Overall Summary for All %d Images ---\n', numImages);
for idx = 1:numImages
    fprintf(['Image %d: PSNR_IR=%.4f, PSNR_VI=%.4f, Entropy=%.4f, Std=%.4f, SF=%.4f, ', ...
             'SSIM_IR=%.4f, SSIM_VI=%.4f, Corr_IR=%.4f, Corr_VI=%.4f\n'], ...
            idx, metrics(idx).psnr_ir, metrics(idx).psnr_vi, metrics(idx).entropy_fused, ...
            metrics(idx).std_fused, metrics(idx).SF, metrics(idx).ssim_ir, metrics(idx).ssim_vi, ...
            metrics(idx).corr_ir, metrics(idx).corr_vi);
end

%% ----------------------------
%