clc; clear; close all;

%% ----------------------------
% Load and normalize images
% ----------------------------
ir = im2double(imread("IR_lake_g.bmp"));
vi = im2double(imread("VIS_lake_r.bmp"));

if size(ir,3)>1, ir = rgb2gray(ir); end
if size(vi,3)>1, vi = rgb2gray(vi); end

ir = im2double(ir);
vi = im2double(vi);

%% ----------------------------
% Generate Salient Mask (IR → target)
% ----------------------------
sal_mask = imbinarize(mat2gray(ir),'adaptive'); 
sal_mask = imgaussfilt(double(sal_mask), 2);
sal_mask = mat2gray(sal_mask);

bg_mask = 1 - sal_mask;

%% ----------------------------
% Apply masks
% ----------------------------
sal_ir = ir .* sal_mask;
sal_vi = vi .* sal_mask;

bg_ir  = ir .* bg_mask;
bg_vi  = vi .* bg_mask;

%% ----------------------------
% Perform DWT
% ----------------------------
wave = 'db2';

% Salient region
[siA, siH, siV, siD] = dwt2(sal_ir, wave);
[svA, svH, svV, svD] = dwt2(sal_vi, wave);

% Background region
[biA, biH, biV, biD] = dwt2(bg_ir, wave);
[bvA, bvH, bvV, bvD] = dwt2(bg_vi, wave);

%% ----------------------------
% STDNet Weights (Option A)
% ----------------------------
w_sal_ir = 0.7;  w_sal_vi = 0.3;
w_bg_ir  = 0.4;  w_bg_vi  = 0.6;

%% ----------------------------
% Fuse subbands (NO IDWT)
% ----------------------------
% Salient fusion
fA_sal = w_sal_ir*siA + w_sal_vi*svA;
fH_sal = w_sal_ir*siH + w_sal_vi*svH;
fV_sal = w_sal_ir*siV + w_sal_vi*svV;
fD_sal = w_sal_ir*siD + w_sal_vi*svD;

% Background fusion
fA_bg = w_bg_ir*biA + w_bg_vi*bvA;
fH_bg = w_bg_ir*biH + w_bg_vi*bvH;
fV_bg = w_bg_ir*biV + w_bg_vi*bvV;
fD_bg = w_bg_ir*biD + w_bg_vi*bvD;

%% ----------------------------
% Reconstruct image-like signals (no IDWT)
% ----------------------------
sal_recon = fA_sal + (fH_sal + fV_sal + fD_sal)/3;
bg_recon  = fA_bg  + (fH_bg + fV_bg + fD_bg)/3;

% Resize to original
sal_recon = imresize(sal_recon, size(ir));
bg_recon  = imresize(bg_recon, size(ir));

%% ----------------------------
% Final STDNet Fusion Rule (Option A)
% ----------------------------
fused = sal_mask .* (w_sal_ir*ir + w_sal_vi*vi) + ...
        bg_mask  .* (w_bg_ir*ir  + w_bg_vi*vi);

% Add DWT contribution
fused = fused + 0.5*(sal_recon + bg_recon);
fused = mat2gray(fused);

%% ----------------------------
% Metrics
% ----------------------------
entropy_fused = entropy(fused);
std_fused = std2(fused);

% Spatial frequency
RF = sqrt(mean(diff(fused,1,1).^2,'all'));
CF = sqrt(mean(diff(fused,1,2).^2,'all'));
SF = sqrt(RF^2 + CF^2);

psnr_ir = psnr(fused, ir);
psnr_vi = psnr(fused, vi);

ssim_ir = ssim(fused, ir);
ssim_vi = ssim(fused, vi);

cc = corr2(fused, ir);

%% ----------------------------
% Display Results
% ----------------------------
fprintf("\n------ FINAL STDNet-Style Fusion (NO IDWT) ------\n");
fprintf("Entropy: %.4f\n", entropy_fused);
fprintf("Std Dev: %.4f\n", std_fused);
fprintf("Spatial Freq: %.4f\n", SF);
fprintf("PSNR vs IR: %.4f dB\n", psnr_ir);
fprintf("SSIM vs IR: %.4f\n", ssim_ir);
fprintf("Correlation: %.4f\n", cc);

%% ----------------------------
% Show Images
% ----------------------------
figure('Color','w');
tiledlayout(2,3,'TileSpacing','compact');

nexttile; imshow(ir,[]); title("Infrared");
nexttile; imshow(vi,[]); title("Visible");
nexttile; imshow(sal_mask,[]); title("Saliency Mask");
nexttile; imshow(bg_mask,[]); title("Background Mask");
nexttile; imshow(sal_recon + bg_recon,[]); title("DWT Reconstructed");
nexttile; imshow(fused,[]); title("Final Fused Image");
