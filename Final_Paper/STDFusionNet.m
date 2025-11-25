% Saliency-guided fusion of one IR + one visible image
% Computes PSNR, Entropy, Std Dev, Spatial Frequency, SSIM

clear; clc; close all;

% ----------------------------
% Load images
% ----------------------------
ir = im2double(imread("IR_lake_g.bmp"));        % infrared image
vi = im2double(imread("VIS_lake_r.bmp"));        % visible image

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

sz = size(vi_gray);

% Resize both to same target size
targetSize = [sz(1) sz(2)];
ir_gray = imresize(ir_gray, targetSize);
vi_gray = imresize(vi_gray, targetSize);

% ----------------------------
% Saliency mask from IR
% ----------------------------
mask = imbinarize(mat2gray(ir_gray),'adaptive');
mask = imgaussfilt(double(mask),2);
mask = mat2gray(mask);

% ----------------------------
% Fusion rule 
% ----------------------------


alpha = 0.7; beta = 0.3;
fused = mask .* (alpha*ir_gray + beta*vi_gray) + (1-mask) .* (0.4*ir_gray + 0.6*vi_gray);


% ----------------------------
% Normalize and ensure same size/channels
% ----------------------------
fused_gray = im2double(mat2gray(fused));
ir_resized = im2double(mat2gray(imresize(ir_gray, 'OutputSize', [size(fused_gray, 1), size(fused_gray, 2)])));
vi_resized = im2double(mat2gray(imresize(vi_gray, 'OutputSize', [size(fused_gray, 1), size(fused_gray, 2)])));

% ----------------------------
% Metrics
% ----------------------------
% PSNR
psnr_ir = psnr(fused_gray, ir_resized);
psnr_vi = psnr(fused_gray, vi_resized);

% Entropy
entropy_fused = entropy(fused_gray);

% Standard Deviation
std_fused = std2(fused_gray);

% Spatial Frequency
RF = sqrt(mean(diff(fused_gray,1,1).^2,'all'));   % row frequency
CF = sqrt(mean(diff(fused_gray,1,2).^2,'all'));   % column frequency
SF = sqrt(RF^2 + CF^2);

% SSIM
ssim_ir = ssim(fused_gray, ir_resized);
ssim_vi = ssim(fused_gray, vi_resized);

% correlation coefficient
c = corr2(fused_gray, ir_resized);

% ----------------------------
% Display results
% ----------------------------
fprintf('--- Fusion Metrics ---\n');

fprintf('Entropy (Fused): %.4f\n', entropy_fused);
fprintf('Spatial Frequency (Fused): %.4f\n', SF);
fprintf('PSNR (Fused vs IR): %.4f dB\n', psnr_ir);
fprintf('Std Deviation (Fused): %.4f\n', std_fused);
fprintf('SSIM (Fused vs IR): %.4f\n', c);
fprintf('CC: %.4f\n', c);

% ----------------------------
% Visualization
% ----------------------------
figure('Name','Fusion + Metrics','Color','w');
tiledlayout(2,2,'TileSpacing','compact');
nexttile; imshow(ir_gray,[]); title('Infrared');
nexttile; imshow(vi_gray,[]); title('Visible');
nexttile; imshow(mask,[]); title('Saliency Mask');
nexttile; imshow(fused_gray,[]); title('Fused Output');