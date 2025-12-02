% -----------------------------------------
% STDFusionNet Fusion Rule (Simplified)
% F = S .* IR + (1 - S) .* VI
% -----------------------------------------

clear; clc; close all;

% ----------------------------
% Load images
% ----------------------------
ir = im2double(imread("IR_lake_g.bmp"));
vi = im2double(imread("VIS_lake_r.bmp"));

% Convert to grayscale if needed
if size(ir,3) > 1, ir = rgb2gray(ir); end
if size(vi,3) > 1, vi = rgb2gray(vi); end

% Resize visible to match IR
vi = imresize(vi, size(ir));

% ----------------------------
% Generate saliency map S
% ----------------------------
S = imbinarize(mat2gray(ir), 'adaptive');
S = imgaussfilt(double(S), 2);   % soft saliency
S = mat2gray(S);

% ----------------------------
% STDFusionNet Fusion Rule
% ----------------------------
fused = S .* ir + (1 - S) .* vi;
fused = mat2gray(fused);   % normalize

% ----------------------------
% Compute Metrics
% ----------------------------

% Entropy
entropy_fused = entropy(fused);

% deviation
dev = deviation_1(vi, fused);

% PSNR with respect to IR and visible
% psnr_ir = psnr(fused, ir);
psnr_vi = psnr(fused, vi);

% Spatial Frequency (SF)
RF = sqrt(mean(diff(fused,1,1).^2,'all'));  % row frequency
CF = sqrt(mean(diff(fused,1,2).^2,'all'));  % column frequency
SF = sqrt(RF^2 + CF^2);

% SSIM
% ssim_ir = ssim(fused, ir);
ssim_vi = ssim(fused, vi);

% Correlation Coefficient (with VI)
corr_vi = corr2(fused, vi);

% ----------------------------
% Display metrics
% ----------------------------
fprintf('\n----- Fusion Performance Metrics -----\n');

fprintf('PSNR (fused vs Visible): %.4f dB\n', psnr_vi);
fprintf('Entropy: %.4f\n', entropy_fused);
fprintf('Spatial Frequency: %.4f\n', SF);
fprintf('SSIM (fused vs Visible): %.4f\n', ssim_vi);
fprintf('Correlation Coefficient (fused vs VI): %.4f\n', corr_vi);
fprintf('Deviation: %.4f\n', dev);

% ----------------------------
% Visualization
% ----------------------------
figure('Color','w'); 
tiledlayout(2,2,'TileSpacing','compact');

nexttile; imshow(ir, []); title('Infrared Image');
nexttile; imshow(vi, []); title('Visible Image');
nexttile; imshow(S, []); title('Saliency Map S');
nexttile; imshow(fused, []); title('Fused Output (STDFusion Rule)');
