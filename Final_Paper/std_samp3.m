% hybrid_std_dwt_fusion_ir_sal_vi_bg.m
% Modified: apply salient mask to IR only, background mask to VIS only.
% Also perform mean/std matching to keep final fused image metrics stable.

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
% Important change:
% - Salient parts should come from IR only (apply salient_mask to IR)
% - Background parts should come from VI only (apply background_mask to VI)

% Salient parts (from IR only)
salient_ir = ir_gray .* salient_mask;
% We'll not use VI info for salient parts (set to zeros)
salient_vi = zeros(size(salient_ir));

% Background parts (from VI only)
background_vi = vi_gray .* background_mask;
% We'll not use IR info for background parts (set to zeros)
background_ir = zeros(size(background_vi));

% ----------------------------
% DWT on the masked images
% ----------------------------
waveletType = 'db2';   % Daubechies-2

% DWT on salient parts (IR only)
[sal_irA, sal_irH, sal_irV, sal_irD] = dwt2(salient_ir, waveletType);
[sal_viA, sal_viH, sal_viV, sal_viD] = dwt2(salient_vi, waveletType);

% DWT on background parts (VI only)
[bg_irA, bg_irH, bg_irV, bg_irD] = dwt2(background_ir, waveletType);
[bg_viA, bg_viH, bg_viV, bg_viD] = dwt2(background_vi, waveletType);

% ----------------------------
% Fuse subbands using STD fusion (but now with IR-only for salient and VI-only for bg)
% ----------------------------
% Keep fusion scheme but since one source is zero in each region it reduces to weighted IR or VI
alpha = 0.7; beta = 0.3;

% Resize masks to subband sizes (all subbands same size for level 1)
sal_mask_sub = imresize(salient_mask, 'OutputSize', size(sal_irA));
bg_mask_sub  = imresize(background_mask, 'OutputSize', size(bg_viA));

% --- Salient subbands: prefer IR (VI subbands are zeros) ---
% We still keep formula shape so it's easy to relax/change later
fused_sal_A = sal_mask_sub .* (alpha*sal_irA + beta*sal_viA) + ...
              (1-sal_mask_sub) .* (0.4*sal_irA + 0.6*sal_viA);
fused_sal_H = sal_mask_sub .* (alpha*sal_irH + beta*sal_viH) + ...
              (1-sal_mask_sub) .* (0.4*sal_irH + 0.6*sal_viH);
fused_sal_V = sal_mask_sub .* (alpha*sal_irV + beta*sal_viV) + ...
              (1-sal_mask_sub) .* (0.4*sal_irV + 0.6*sal_viV);
fused_sal_D = sal_mask_sub .* (alpha*sal_irD + beta*sal_viD) + ...
              (1-sal_mask_sub) .* (0.4*sal_irD + 0.6*sal_viD);

% --- Background subbands: prefer VI (IR subbands are zeros) ---
fused_bg_A = bg_mask_sub .* (alpha*bg_irA + beta*bg_viA) + ...
             (1-bg_mask_sub) .* (0.4*bg_irA + 0.6*bg_viA);
fused_bg_H = bg_mask_sub .* (alpha*bg_irH + beta*bg_viH) + ...
             (1-bg_mask_sub) .* (0.4*bg_irH + 0.6*bg_viH);
fused_bg_V = bg_mask_sub .* (alpha*bg_irV + beta*bg_viV) + ...
             (1-bg_mask_sub) .* (0.4*bg_irV + 0.6*bg_viV);
fused_bg_D = bg_mask_sub .* (alpha*bg_irD + beta*bg_viD) + ...
             (1-bg_mask_sub) .* (0.4*bg_irD + 0.6*bg_viD);

% Note:
% Because sal_vi* and bg_ir* are zeros, fused_sal_* is essentially weighted sal_ir_*
% and fused_bg_* is essentially weighted bg_vi_*. Fusion formulas kept for clarity.

% ----------------------------
% IDWT reconstruction
% ----------------------------
fused_salient = idwt2(fused_sal_A, fused_sal_H, fused_sal_V, fused_sal_D, waveletType);
fused_background = idwt2(fused_bg_A, fused_bg_H, fused_bg_V, fused_bg_D, waveletType);

% Combine salient and background fused images
fused = fused_salient + fused_background;

% ----------------------------
% Stabilize final fused image so metrics don't vary much
% Match fused image mean/std to average of IR and VI means/stds
% ----------------------------
% Resize input references to fused size
ir_resized = im2double(mat2gray(imresize(ir_gray,  size(fused))));
vi_resized = im2double(mat2gray(imresize(vi_gray,  size(fused))));

% Compute target mean/std as the average of both inputs (you can tweak to prefer one)
mean_ir = mean(ir_resized(:));
std_ir  = std2(ir_resized);
mean_vi = mean(vi_resized(:));
std_vi  = std2(vi_resized);

target_mean = (mean_ir + mean_vi) / 2;
target_std  = (std_ir  + std_vi)  / 2;

% Current fused stats
fused = im2double(fused);
mean_fused = mean(fused(:));
std_fused  = std2(fused);

% If std_fused is extremely small (flat image), avoid division by zero
if std_fused < 1e-6
    std_fused = 1e-6;
end

% Match mean and std
fused_matched = (fused - mean_fused) .* (target_std ./ std_fused) + target_mean;

% Clip and normalize to [0,1]
fused_matched = mat2gray(fused_matched);

fused_gray = fused_matched;

% ----------------------------
% Metrics (recompute/rescale as needed)
% ----------------------------
% Ensure resized references are in [0,1] as above
ir_resized = im2double(mat2gray(imresize(ir_gray,  size(fused_gray))));
vi_resized = im2double(mat2gray(imresize(vi_gray,  size(fused_gray))));

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
fprintf('--- Hybrid STD + DWT Fusion (IR-salient, VI-background) ---\n');
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
figure('Name','Hybrid STD + DWT Fusion (IR-salient, VI-background)','Color','w');
tiledlayout(2,3,'TileSpacing','compact');
nexttile; imshow(ir_gray,[]); title('Infrared (grayscale)');
nexttile; imshow(vi_gray,[]); title('Visible (grayscale)');
nexttile; imshow(salient_mask,[]); title('Salient Mask (from IR)');
nexttile; imshow(background_mask,[]); title('Background Mask (1 - salient)');
nexttile; imshow(fused_salient,[]); title('Fused Salient (IR only region)');
nexttile; imshow(fused_gray,[]); title('Final Fused Output (mean/std matched)');
