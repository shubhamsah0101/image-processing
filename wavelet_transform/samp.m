% clc; clear all; close all;
% 
% % Read input images
% vis = im2double(imread("manWalkVB.jpg"));
% ir = im2double(imread("manWalkIR.jpg"));
% 
% % Resize to match size
% [rows, cols, ~] = size(vis);
% ir = imresize(ir, [rows, cols]);
% 
% % Convert to grayscale if RGB
% if size(vis,3) == 3
%     vis = rgb2gray(vis);
% end
% if size(ir,3) == 3
%     ir = rgb2gray(ir);
% end
% 
% % Parameters
% wname = 'db2';      % wavelet type
% nLevels = 2;        % number of decomposition levels
% 
% % Perform multi-level wavelet decomposition
% [vis_c, vis_s] = wavedec2(vis, nLevels, wname);
% [ir_c, ir_s]   = wavedec2(ir,  nLevels, wname);
% 
% % Fuse approximation coefficients (average)
% A_vis = appcoef2(vis_c, vis_s, wname, nLevels);
% A_ir  = appcoef2(ir_c, ir_s, wname, nLevels);
% A_fused = (A_vis + A_ir) / 2;
% 
% % Start with fused approximation
% % C_fused = [];
% 
% % Reconstruct step-by-step from top level down
% [H_vis, V_vis, D_vis] = detcoef2('all', vis_c, vis_s, nLevels);
% [H_ir,  V_ir,  D_ir]  = detcoef2('all', ir_c, ir_s, nLevels);
% 
% H_f = max(H_ir, H_vis);
% V_f = max(V_ir, V_vis);
% D_f = max(D_ir, D_vis);
% 
% A_fused = idwt2(A_fused, H_f, V_f, D_f, wname);
% 
% % Final fused image
% fused_img = A_fused;
% 
% % Display results
% figure(1)
% subplot(1,2,1); imshow(vis, []); title('Visible Image');
% subplot(1,2,2); imshow(ir, []); title('Infrared Image');
% 
% figure(2)
% imshow(fused_img, []); title('Fused Image (Multi-Level)');








clc; clear all; close all;

% Read and preprocess images
vis = im2double(imread("manWalkVB.jpg"));
ir  = im2double(imread("manWalkIR.jpg"));

[rows, cols, ~] = size(vis);
ir = imresize(ir, [rows, cols]);

if size(vis,3) == 3, vis = rgb2gray(vis); end
if size(ir,3) == 3, ir  = rgb2gray(ir);  end

% Parameters
wname = 'db2';
nLevels = 2;

% Multi-level decomposition
[vis_c, vis_s] = wavedec2(vis, nLevels, wname);
[ir_c,  ir_s]  = wavedec2(ir,  nLevels, wname);

% Initialize fused coefficient vector
C_fused = zeros(size(vis_c));

% Fuse approximation coefficients (top-left corner of C vector)
A_vis = appcoef2(vis_c, vis_s, wname, nLevels);
A_ir  = appcoef2(ir_c,  ir_s, wname, nLevels);
A_fused = (A_vis + A_ir)/2;

lenA = numel(A_fused);
C_fused(1:lenA) = A_fused(:);

% Fuse detail coefficients level by level
for i = 1:nLevels
    % Extract horizontal, vertical, diagonal details
    [H_vis, V_vis, D_vis] = detcoef2('all', vis_c, vis_s, i);
    [H_ir,  V_ir,  D_ir]  = detcoef2('all', ir_c,  ir_s, i);

    % Fuse using max-absolute rule
    H_f = max(H_vis, H_ir);
    V_f = max(V_vis, V_ir);
    D_f = max(D_vis, D_ir);

    % Flatten and place into C_fused vector
    idxH = sum(prod(vis_s(1:i,:),2)) + 1;
    % Instead of manually indexing, you can use helper function:
    % For simplicity, use idwt2 level-by-level reconstruction (next step)
end

% Reconstruct fused image using inverse DWT
fused_img = waverec2(C_fused, vis_s, wname);

% Display results
figure;
subplot(1,2,1); imshow(vis, []); title('Visible Image');
subplot(1,2,2); imshow(ir, []); title('Infrared Image');

figure;
imshow(fused_img, []); title('Fused Image (Multi-Level)');
