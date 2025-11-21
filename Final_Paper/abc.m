% --------------------------------------
% Saliency-Guided Infrared–Visible Fusion
% Architecture-based MATLAB Implementation
% --------------------------------------

clear; clc; close all;

% ----------------------------
% Load & preprocess images
% ----------------------------
ir = im2double(imread('manWalkIR.jpg'));
vi = im2double(imread('manWalkVB.jpg'));

if size(ir,3) > 1, ir = rgb2gray(ir); end
if size(vi,3) > 1, vi = rgb2gray(vi); end

targetSize = [256 256];
ir = imresize(ir, targetSize);
vi = imresize(vi, targetSize);

% ----------------------------
% Compute Salient Target Mask
% ----------------------------
salient_mask = imbinarize(mat2gray(ir),'adaptive');
salient_mask = imgaussfilt(double(salient_mask), 2);
salient_mask = mat2gray(salient_mask);

% Background mask = 1 - saliency
background_mask = 1 - salient_mask;

% ----------------------------
% Element-wise masking
% (mimics the figure's multiplication circles)
% ----------------------------

% IR × salient mask  (foreground/salient)
IR_sal = ir .* salient_mask;

% VI × background mask (background)
VI_bg = vi .* background_mask;

% ----------------------------
% Additional masked combinations (as in figure)
% ----------------------------
% Visible × SalientMask (helps edges)
VI_sal = vi .* salient_mask;

% Infrared × BackgroundMask (helps structure)
IR_bg = ir .* background_mask;

% ----------------------------
% Fusion (mimics addition circles)
% ----------------------------
% Two complementary masked streams merged
foreground_stream  = IR_sal + 0.25 * VI_sal;
background_stream  = VI_bg + 0.25 * IR_bg;

% Final fused output
fused = foreground_stream + background_stream;

% Normalize
fused = mat2gray(fused);

% ----------------------------
% Display
% ----------------------------
figure('Color','w');
tiledlayout(2,3,'TileSpacing','compact');

nexttile; imshow(ir,[]), title('Infrared');
nexttile; imshow(vi,[]), title('Visible');
nexttile; imshow(salient_mask,[]), title('Salient Mask');
nexttile; imshow(background_mask,[]), title('Background Mask');
nexttile; imshow(IR_sal + VI_bg,[]), title('Intermediate Fusion');
nexttile; imshow(fused,[]), title('Final Fused Output');