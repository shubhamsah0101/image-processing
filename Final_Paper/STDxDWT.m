% Combine STD masks + masked DWT + STD fusion, WITHOUT IDWT
% Final fusion is direct STD fusion (like your first program)

clear; clc; close all;

%% ----------------------------
% Load images
% ----------------------------
ir = im2double(imread("IR_lake_g.bmp"));
vi = im2double(imread("VIS_lake_r.bmp"));

if size(ir,3) > 1, ir_gray = rgb2gray(ir); else, ir_gray = ir; end
if size(vi,3) > 1, vi_gray = rgb2gray(vi); else, vi_gray = vi; end

sz = size(vi);

% Resize both to same target size
targetSize = [256 256];
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
fA_sal = sal_mask_sub.*(alpha*siA + beta*svA) + (1-sal_mask_sub).*(0.4*siA + 0.6*svA);
fH_sal = sal_mask_sub.*(alpha*siH + beta*svH) + (1-sal_mask_sub).*(0.4*siH + 0.6*svH);
fV_sal = sal_mask_sub.*(alpha*siV + beta*svV) + (1-sal_mask_sub).*(0.4*siV + 0.6*svV);
fD_sal = sal_mask_sub.*(alpha*siD + beta*svD) + (1-sal_mask_sub).*(0.4*siD + 0.6*svD);

% Background fusion
fA_bg = bg_mask_sub.*(alpha*biA + beta*bvA) + (1-bg_mask_sub).*(0.4*biA + 0.6*bvA);
fH_bg = bg_mask_sub.*(alpha*biH + beta*bvH) + (1-bg_mask_sub).*(0.4*biH + 0.6*bvH);
fV_bg = bg_mask_sub.*(alpha*biV + beta*bvV) + (1-bg_mask_sub).*(0.4*biV + 0.6*bvV);
fD_bg = bg_mask_sub.*(alpha*biD + beta*bvD) + (1-bg_mask_sub).*(0.4*biD + 0.6*bvD);

%% ----------------------------
% STD Fusion (FINAL FUSION, NO IDWT)
% ----------------------------
% Reconstruct approximate image-like components by averaging subbands
sal_recon = fA_sal + (fH_sal + fV_sal + fD_sal)/3;
bg_recon  = fA_bg  + (fH_bg  + fV_bg  + fD_bg )/3;

% Combine salient + background
combined = sal_recon + bg_recon;

% Final STD fusion (same as first program)
fused = salient_mask .* (alpha*ir_gray + beta*vi_gray) + ...
        background_mask .* (0.4*ir_gray + 0.6*vi_gray);

% Resize DWT output to match fused image size
combined = imresize(combined, size(fused));

% Add DWT contribution
fused_gray = mat2gray(fused + 0.5*combined);

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

% correlation coefficient
c = corr2(fused_gray, ir_r);

%% ----------------------------
% Results
% ----------------------------
fprintf("\n--- Combined STD + DWT (No IDWT) ---\n");
fprintf("Entropy: %.4f\n", entropy_fused);
fprintf("Spatial Freq: %.4f\n", SF);
fprintf("PSNR vs IR: %.4f dB\n", psnr_ir);
fprintf("Std Dev: %.4f\n", std_fused);
fprintf("SSIM vs IR: %.4f\n", ssim_ir);
fprintf("CC: %.4f\n", c);

%% ----------------------------
% Display
% ----------------------------
figure('Name','Combined STD + DWT Fusion','Color','w');
tiledlayout(2,3,'TileSpacing','compact');
nexttile; imshow(ir_gray,[]); title('Infrared');
nexttile; imshow(vi_gray,[]); title('Visible');
nexttile; imshow(salient_mask,[]); title('Saliency Mask');
nexttile; imshow(bg_mask_sub,[]); title('Background Mask');
nexttile; imshow(combined,[]); title('DWT Combined');
nexttile; imshow(fused_gray,[]); title('Final Fused Output');
