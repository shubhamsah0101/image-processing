% % hybrid_std_dwt_fusion.m
% % Hybrid STD + DWT fusion:
% % Salient mask applied only to IR, background mask applied only to VI
% % Computes PSNR, Entropy, Std Dev, Spatial Frequency, SSIM, Deviation, Correlation
% % Handles arrays of images (4 IR + 4 VI)
% 
% clear; clc; close all;
% 
% % ----------------------------
% % Load images (4 IR + 4 VI)
% % ----------------------------
% ir = {im2double(imread("IR_lake_g.bmp")), im2double(imread("manWalkIR.jpg")), ...
%       im2double(imread("IR_meting016_g.bmp")), im2double(imread("IR_helib_011.bmp"))};
% vi = {im2double(imread("VIS_lake_r.bmp")), im2double(imread("manWalkVB.jpg")), ...
%       im2double(imread("VIS_meting016_r.bmp")), im2double(imread("VIS_helib_011.bmp"))};
% 
% numImages = length(ir);  % Should be 4
% 
% % Initialize storage
% metrics = struct('psnr_ir', [], 'psnr_vi', [], 'entropy_fused', [], ...
%                  'std_fused', [], 'SF', [], 'ssim_ir', [], 'ssim_vi', [], ...
%                  'dev_ir', [], 'dev_vi', [], 'corr_ir', [], 'corr_vi', []);
% fused_images = cell(1, numImages);
% 
% % ----------------------------
% % Loop over image pairs
% % ----------------------------
% for idx = 1:numImages
%     fprintf('Processing image pair %d/%d...\n', idx, numImages);
% 
%     % Current images
%     ir_curr = ir{idx};
%     vi_curr = vi{idx};
% 
%     % Convert to grayscale if RGB
%     if size(ir_curr,3) > 1, ir_gray = rgb2gray(ir_curr); else, ir_gray = ir_curr; end
%     if size(vi_curr,3) > 1, vi_gray = rgb2gray(vi_curr); else, vi_gray = vi_curr; end
% 
%     % Resize both to same target size
%     targetSize = [256 256];
%     ir_gray = imresize(ir_gray, targetSize);
%     vi_gray = imresize(vi_gray, targetSize);
% 
%     % ----------------------------
%     % Masks
%     % ----------------------------
%     salient_mask = imbinarize(mat2gray(ir_gray),'adaptive');
%     salient_mask = imgaussfilt(double(salient_mask),2);
%     salient_mask = mat2gray(salient_mask);
% 
%     background_mask = 1 - salient_mask;
% 
%     % ----------------------------
%     % Apply masks (salient mask to IR only, background mask to VI only)
%     % ----------------------------
%     salient_ir = ir_gray .* salient_mask;       % IR salient regions only
%     background_vi = vi_gray .* background_mask; % VI background regions only
% 
%     % ----------------------------
%     % DWT on masked images
%     % ----------------------------
%     waveletType = 'db2';
% 
%     % DWT on salient IR
%     [sal_irA, sal_irH, sal_irV, sal_irD] = dwt2(salient_ir, waveletType);
% 
%     % DWT on background VI
%     [bg_viA, bg_viH, bg_viV, bg_viD] = dwt2(background_vi, waveletType);
% 
%     % ----------------------------
%     % Fusion (keep IR salient + VI background)
%     % ----------------------------
%     fused_A = (sal_irA + bg_viA)/2;
%     fused_H = sal_irH; if var(bg_viH(:)) > var(sal_irH(:)), fused_sal_H = bg_viH; end
%     fused_V = sal_irV; if var(bg_viV(:)) > var(sal_irV(:)), fused_sal_V = bg_viV; end
%     fused_D = sal_irD; if var(bg_viD(:)) > var(sal_irD(:)), fused_sal_D = bg_viD; end
% 
%     alpha = 0.7; beta = 0.3;
% 
%     fused = salient_mask .* (alpha*ir_gray + beta*vi_gray) + ...
%         background_mask .* (0.4*ir_gray + 0.6*vi_gray);
% 
% 
%     % fused_sal_A = sal_irA+bg_viA; 
%     % fused_sal_H = sal_irH+bg_viH; 
%     % fused_sal_V = sal_irV+bg_viV; 
%     % fused_sal_D = sal_irD+bg_viD;
% 
%     % fused_bg_A = bg_viA; 
%     % fused_bg_H = bg_viH; 
%     % fused_bg_V = bg_viV; 
%     % fused_bg_D = bg_viD;
% 
%     % ----------------------------
%     % IDWT reconstruction
%     % ----------------------------
%     % fused_salient = idwt2(fused_sal_A, fused_sal_H, fused_sal_V, fused_sal_D, waveletType);
%     % fused_background = idwt2(fused_bg_A, fused_bg_H, fused_bg_V, fused_bg_D, waveletType);
% 
%     % fused = fused_salient; %+ fused_background;
%     % fused_gray = im2double(mat2gray(fused));
% 
%     % fused_images{idx} = fused_gray;
% 
%     % ----------------------------
%     % Metrics
%     % ----------------------------
%     ir_resized = im2double(mat2gray(ir_gray));
%     vi_resized = im2double(mat2gray(vi_gray));
% 
%     % PSNR
%     psnr_ir = psnr(fused_gray, ir_resized);
%     psnr_vi = psnr(fused_gray, vi_resized);
% 
%     % Entropy
%     entropy_fused = entropy(fused_gray);
% 
%     % Std Dev
%     std_fused = std2(fused_gray);
% 
%     % Spatial Frequency
%     RF = sqrt(mean(diff(fused_gray,1,1).^2,'all'));
%     CF = sqrt(mean(diff(fused_gray,1,2).^2,'all'));
%     SF = sqrt(RF^2 + CF^2);
% 
%     % SSIM
%     ssim_ir = ssim(fused_gray, ir_resized);
%     ssim_vi = ssim(fused_gray, vi_resized);
% 
%     % Deviation (relative error)
%     epsilon = 1e-10;
%     dev_ir = mean(abs((ir_resized(:) - fused_gray(:)) ./ (ir_resized(:) + epsilon)));
%     dev_vi = mean(abs((vi_resized(:) - fused_gray(:)) ./ (vi_resized(:) + epsilon)));
% 
%     % Correlation
%     corr_ir = corr2(fused_gray, ir_resized);
%     corr_vi = corr2(fused_gray, vi_resized);
% 
%     % Store
%     metrics(idx).psnr_ir = psnr_ir;
%     metrics(idx).psnr_vi = psnr_vi;
%     metrics(idx).entropy_fused = entropy_fused;
%     metrics(idx).std_fused = std_fused;
%     metrics(idx).SF = SF;
%     metrics(idx).ssim_ir = ssim_ir;
%     metrics(idx).ssim_vi = ssim_vi;
%     metrics(idx).dev_ir = dev_ir;
%     metrics(idx).dev_vi = dev_vi;
%     metrics(idx).corr_ir = corr_ir;
%     metrics(idx).corr_vi = corr_vi;
% 
%     % Display metrics
%     fprintf('--- Metrics for Image Pair %d ---\n', idx);
%     fprintf('PSNR vs IR: %.4f dB\n', psnr_ir);
%     fprintf('PSNR vs VI: %.4f dB\n', psnr_vi);
%     fprintf('Entropy: %.4f\n', entropy_fused);
%     fprintf('Std Dev: %.4f\n', std_fused);
%     fprintf('Spatial Freq: %.4f\n', SF);
%     fprintf('SSIM vs IR: %.4f\n', ssim_ir);
%     fprintf('SSIM vs VI: %.4f\n', ssim_vi);
%     fprintf('Deviation vs IR: %.6f\n', dev_ir);
%     fprintf('Deviation vs VI: %.6f\n', dev_vi);
%     fprintf('Correlation vs IR: %.4f\n', corr_ir);
%     fprintf('Correlation vs VI: %.4f\n', corr_vi);
%     fprintf('\n');
% end
% 
% % ----------------------------
% % Overall Summary
% % ----------------------------
% fprintf('--- Overall Summary for All %d Images ---\n', numImages);
% for idx = 1:numImages
%     fprintf(['Image %d: PSNR_IR=%.4f, PSNR_VI=%.4f, Entropy=%.4f, Std=%.4f, SF=%.4f, ', ...
%              'SSIM_IR=%.4f, SSIM_VI=%.4f, Dev_IR=%.6f, Dev_VI=%.6f, Corr_IR=%.4f, Corr_VI=%.4f\n'], ...
%             idx, metrics(idx).psnr_ir, metrics(idx).psnr_vi, metrics(idx).entropy_fused, ...
%             metrics(idx).std_fused, metrics(idx).SF, metrics(idx).ssim_ir, metrics(idx).ssim_vi, ...
%             metrics(idx).dev_ir, metrics(idx).dev_vi, metrics(idx).corr_ir, metrics(idx).corr_vi);
% end
% 
% % ----------------------------
% % Visualization
% % ----------------------------
% figure('Name','Hybrid STD + DWT Fusion (First Pair)','Color','w');
% tiledlayout(2,3,'TileSpacing','compact');
% nexttile; imshow(ir_gray,[]); title('Infrared');
% nexttile; imshow(vi_gray,[]); title('Visible');
% nexttile; imshow(salient_mask,[]); title('Salient Mask (IR)');
% nexttile; imshow(background_mask,[]); title('Background Mask (VI)');
% nexttile; imshow(salient_ir,[]); title('Salient IR Only');
% nexttile; imshow(fused_images{1},[]); title('Fused Output (Pair 1)');
% 
% figure('Name','All Fused Images','Color','w');
% montage(fused_images, 'Size', [2 2]); % 4 pairs → 2x2 grid
% title('Montage of All Fused Images');




% hybrid_std_dwt_fusion.m
% Hybrid STD + DWT fusion:
% Salient mask applied only to IR, background mask applied only to VI
% Computes PSNR, Entropy, Std Dev, Spatial Frequency, SSIM, Deviation, Correlation
% Handles arrays of images (4 IR + 4 VI)

clear; clc; close all;

% ----------------------------
% Load images (4 IR + 4 VI)
% ----------------------------
ir = {im2double(imread("IR_lake_g.bmp")), im2double(imread("manWalkIR.jpg")), ...
      im2double(imread("IR_meting016_g.bmp")), im2double(imread("IR_helib_011.bmp"))};
vi = {im2double(imread("VIS_lake_r.bmp")), im2double(imread("manWalkVB.jpg")), ...
      im2double(imread("VIS_meting016_r.bmp")), im2double(imread("VIS_helib_011.bmp"))};

numImages = length(ir);  % Should be 4

% Initialize storage
metrics = struct('psnr_ir', [], 'psnr_vi', [], 'entropy_fused', [], ...
                 'std_fused', [], 'SF', [], 'ssim_ir', [], 'ssim_vi', [], ...
                 'dev_ir', [], 'dev_vi', [], 'corr_ir', [], 'corr_vi', []);
fused_images = cell(1, numImages);

% ----------------------------
% Loop over image pairs
% ----------------------------
for idx = 1:numImages
    fprintf('Processing image pair %d/%d...\n', idx, numImages);

    % Current images
    ir_curr = ir{idx};
    vi_curr = vi{idx};

    % Convert to grayscale if RGB
    if size(ir_curr,3) > 1, ir_gray = rgb2gray(ir_curr); else, ir_gray = ir_curr; end
    if size(vi_curr,3) > 1, vi_gray = rgb2gray(vi_curr); else, vi_gray = vi_curr; end

    % Resize both to same target size
    targetSize = [256 256];
    ir_gray = imresize(ir_gray, targetSize);
    vi_gray = imresize(vi_gray, targetSize);

    % ----------------------------
    % Masks
    % ----------------------------
    salient_mask = imbinarize(mat2gray(ir_gray),'adaptive');
    salient_mask = imgaussfilt(double(salient_mask),2);
    salient_mask = mat2gray(salient_mask);

    background_mask = 1 - salient_mask;

    % ----------------------------
    % Apply masks (salient mask to IR only, background mask to VI only)
    % ----------------------------
    salient_ir = ir_gray .* salient_mask;       % IR salient regions only
    background_vi = vi_gray .* background_mask; % VI background regions only

    % ----------------------------
    % DWT on masked images
    % ----------------------------
    waveletType = 'db2';

    % DWT on salient IR
    [sal_irA, sal_irH, sal_irV, sal_irD] = dwt2(salient_ir, waveletType);

    % DWT on background VI
    [bg_viA, bg_viH, bg_viV, bg_viD] = dwt2(background_vi, waveletType);

    % ----------------------------
    % Fusion (keep IR salient + VI background)
    % ----------------------------
    fused_sal_A = 0.5.*sal_irA+0.5.*bg_viA;
   
    fused_sal_H = sal_irH;if var(bg_viH(:)) > var(sal_irH(:)),fused_sal_H = bg_viH;end
    fused_sal_V = sal_irV;if var(bg_viV(:)) > var(sal_irV(:)),fused_sal_V = bg_viV;end
    fused_sal_D = sal_irD;if var(bg_viD(:)) > var(sal_irD(:)),fused_sal_D = bg_viD;end

    % fused_bg_A = bg_viA; fused_bg_H = bg_viH; fused_bg_V = bg_viV; fused_bg_D = bg_viD;

    % ----------------------------
    % IDWT reconstruction
    % ----------------------------
    fused_salient = idwt2(fused_sal_A, fused_sal_H, fused_sal_V, fused_sal_D, waveletType);
    % fused_background = idwt2(fused_bg_A, fused_bg_H, fused_bg_V, fused_bg_D, waveletType);

    fused = fused_salient; %+ fused_background;
    fused_gray = im2double(mat2gray(fused));

    fused_images{idx} = fused_gray;

    % ----------------------------
    % Metrics
    % ----------------------------
    ir_resized = im2double(mat2gray(ir_gray));
    vi_resized = im2double(mat2gray(vi_gray));

    % PSNR
    psnr_ir = psnr(fused_gray, ir_resized);
    psnr_vi = psnr(fused_gray, vi_resized);

    % Entropy
    entropy_fused = entropy(fused_gray);

    % Std Dev
    std_fused = std2(fused_gray);

    % Spatial Frequency
    RF = sqrt(mean(diff(fused_gray,1,1).^2,'all'));
    CF = sqrt(mean(diff(fused_gray,1,2).^2,'all'));
    SF = sqrt(RF^2 + CF^2);

    % SSIM
    ssim_ir = ssim(fused_gray, ir_resized);
    ssim_vi = ssim(fused_gray, vi_resized);

    % Deviation (relative error)
    epsilon = 1e-10;
    dev_ir = mean(abs((ir_resized(:) - fused_gray(:)) ./ (ir_resized(:) + epsilon)));
    dev_vi = mean(abs((vi_resized(:) - fused_gray(:)) ./ (vi_resized(:) + epsilon)));

    % Correlation
    corr_ir = corr2(fused_gray, ir_resized);
    corr_vi = corr2(fused_gray, vi_resized);

    % Store
    metrics(idx).psnr_ir = psnr_ir;
    metrics(idx).psnr_vi = psnr_vi;
    metrics(idx).entropy_fused = entropy_fused;
    metrics(idx).std_fused = std_fused;
    metrics(idx).SF = SF;
    metrics(idx).ssim_ir = ssim_ir;
    metrics(idx).ssim_vi = ssim_vi;
    metrics(idx).dev_ir = dev_ir;
    metrics(idx).dev_vi = dev_vi;
    metrics(idx).corr_ir = corr_ir;
    metrics(idx).corr_vi = corr_vi;

    % Display metrics
    fprintf('--- Metrics for Image Pair %d ---\n', idx);
    fprintf('PSNR vs IR: %.4f dB\n', psnr_ir);
    fprintf('PSNR vs VI: %.4f dB\n', psnr_vi);
    fprintf('Entropy: %.4f\n', entropy_fused);
    fprintf('Std Dev: %.4f\n', std_fused);
    fprintf('Spatial Freq: %.4f\n', SF);
    fprintf('SSIM vs IR: %.4f\n', ssim_ir);
    fprintf('SSIM vs VI: %.4f\n', ssim_vi);
    fprintf('Deviation vs IR: %.6f\n', dev_ir);
    fprintf('Deviation vs VI: %.6f\n', dev_vi);
    fprintf('Correlation vs IR: %.4f\n', corr_ir);
    fprintf('Correlation vs VI: %.4f\n', corr_vi);
    fprintf('\n');
end

% ----------------------------
% Overall Summary
% ----------------------------
fprintf('--- Overall Summary for All %d Images ---\n', numImages);
for idx = 1:numImages
    fprintf(['Image %d: PSNR_IR=%.4f, PSNR_VI=%.4f, Entropy=%.4f, Std=%.4f, SF=%.4f, ', ...
             'SSIM_IR=%.4f, SSIM_VI=%.4f, Dev_IR=%.6f, Dev_VI=%.6f, Corr_IR=%.4f, Corr_VI=%.4f\n'], ...
            idx, metrics(idx).psnr_ir, metrics(idx).psnr_vi, metrics(idx).entropy_fused, ...
            metrics(idx).std_fused, metrics(idx).SF, metrics(idx).ssim_ir, metrics(idx).ssim_vi, ...
            metrics(idx).dev_ir, metrics(idx).dev_vi, metrics(idx).corr_ir, metrics(idx).corr_vi);
end

% ----------------------------
% Visualization
% ----------------------------
figure('Name','Hybrid STD + DWT Fusion (First Pair)','Color','w');
tiledlayout(2,3,'TileSpacing','compact');
nexttile; imshow(ir_gray,[]); title('Infrared');
nexttile; imshow(vi_gray,[]); title('Visible');
nexttile; imshow(salient_mask,[]); title('Salient Mask (IR)');
nexttile; imshow(background_mask,[]); title('Background Mask (VI)');
nexttile; imshow(salient_ir,[]); title('Salient IR Only');
nexttile; imshow(fused_images{1},[]); title('Fused Output (Pair 1)');

figure('Name','All Fused Images','Color','w');
montage(fused_images, 'Size', [2 2]); % 4 pairs → 2x2 grid
title('Montage of All Fused Images');