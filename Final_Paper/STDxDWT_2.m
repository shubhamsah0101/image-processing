% -------------------------------------------------------------
% Hybrid Salient Target Detection + DWT Fusion (NO IDWT)
% Fusion Rule: F = S .* IR_DWT + (1 - S) .* VI_DWT
% -------------------------------------------------------------

clear; clc; close all;

% ----------------------------
% Load images
% ----------------------------
ir = im2double(imread("manWalkIR.jpg"));
vi = im2double(imread("manWalkVB.jpg"));

% Convert to grayscale
if size(ir,3)>1, ir = rgb2gray(ir); end
if size(vi,3)>1, vi = rgb2gray(vi); end

% Match sizes
vi = imresize(vi, size(ir));

%% -------------------------------------------------
% Generate Saliency Map S from IR
%% -------------------------------------------------
S = imbinarize(mat2gray(ir), "adaptive");
S = imgaussfilt(double(S), 1.5);  
S = mat2gray(S);
B = 1 - S;   % Background mask

%% -------------------------------------------------
% DWT Decomposition for IR & Visible
%% -------------------------------------------------
[LL_ir, LH_ir, HL_ir, HH_ir] = dwt2(ir, "db2");
[LL_vi, LH_vi, HL_vi, HH_vi] = dwt2(vi, "db2");

% Resize masks to coefficient sizes
S_dwt = imresize(S, size(LL_ir));
B_dwt = 1 - S_dwt;

%% -------------------------------------------------
% Masked Fusion of DWT Coefficients
%% -------------------------------------------------
LL_fused = S_dwt .* LL_ir + B_dwt .* LL_vi;
LH_fused = S_dwt .* LH_ir + B_dwt .* LH_vi;
HL_fused = S_dwt .* HL_ir + B_dwt .* HL_vi;
HH_fused = S_dwt .* HH_ir + B_dwt .* HH_vi;

%% -------------------------------------------------
% Reconstruct IR_DWT and VI_DWT separately
%% -------------------------------------------------
IR_dwt = idwt2(LL_ir, LH_ir, HL_ir, HH_ir, "db2");
VI_dwt = idwt2(LL_vi, LH_vi, HL_vi, HH_vi, "db2");

% Coarse fused reconstruction
F_dwt = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, "db2");
F_dwt = imresize(F_dwt, size(ir));
F_dwt = mat2gray(F_dwt);

%% -------------------------------------------------
% Resize before final STD fusion  (critical fix)
% -------------------------------------------------
IR_dwt = imresize(IR_dwt, size(S));
VI_dwt = imresize(VI_dwt, size(S));

%% -------------------------------------------------
% FINAL STD Fusion (No IDWT-based fusion)
% -------------------------------------------------
fused = S .* IR_dwt + (1 - S) .* VI_dwt;
fused = mat2gray(fused);


%% -------------------------------------------------
% Compute Metrics
%% -------------------------------------------------
entropy_fused = entropy(fused);
dev = deviation_1(ir, fused);
psnr_ir = psnr(fused, ir);
psnr_vi = psnr(fused, vi);

RF = sqrt(mean(diff(fused,1,1).^2,'all'));
CF = sqrt(mean(diff(fused,1,2).^2,'all'));
SF = sqrt(RF^2 + CF^2);

ssim_ir = ssim(fused, ir);
ssim_vi = ssim(fused, vi);

corr_ir = corr2(fused, ir);

%% -------------------------------------------------
% Display Metrics
%% -------------------------------------------------
fprintf("\n----- Hybrid STD + DWT Fusion Metrics -----\n");
fprintf("Entropy: %.4f\n", entropy_fused);
fprintf("Deviation: %.4f\n", dev);
fprintf("Spatial Frequency: %.4f\n", SF);
fprintf("PSNR vs IR: %.4f dB\n", psnr_ir);
fprintf("PSNR vs VIS: %.4f dB\n", psnr_vi);
fprintf("SSIM vs IR: %.4f\n", ssim_ir);
fprintf("SSIM vs VIS: %.4f\n", ssim_vi);
fprintf("Correlation vs IR: %.4f\n", corr_ir);

%% -------------------------------------------------
% Visualization
%% -------------------------------------------------
figure('Color','w');
tiledlayout(2,3,'TileSpacing','compact');

nexttile; imshow(ir, []); title("Infrared");
nexttile; imshow(vi, []); title("Visible");
nexttile; imshow(S, []); title("Saliency Map (S)");
nexttile; imshow(F_dwt, []); title("DWT-Coarse Fusion");
nexttile; imshow(fused, []); title("Final Hybrid Fusion");
