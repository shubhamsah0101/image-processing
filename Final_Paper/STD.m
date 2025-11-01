% clc; clear; close all;
% 
% %% Step 1: Load Input Images
% IR = imread('manWalkIR.jpg');
% VIS = imread('manWalkVB.jpg');
% figure, imshow(IR); title('Original Infrared Image');
% 
% %% Step 2: Preprocess Infrared Image
% grayIR = rgb2gray(IR);
% figure, imhist(grayIR); title('Histogram of Infrared Grayscale Image');
% 
% smoothedIR = imgaussfilt(grayIR, 2);  % Gaussian smoothing
% level = graythresh(smoothedIR);      % Otsu threshold
% threshold = round(level * 255);
% fprintf('Computed Otsu Threshold: %d\n', threshold);
% 
% binaryMask = smoothedIR > threshold;
% binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
% binaryMask = bwareaopen(binaryMask, 100);             % Remove small fragments
% 
% %% Step 3: Apply Mask to IR Image
% maskedIR = IR;
% maskedIR(repmat(~binaryMask, [1 1 3])) = 0;
% figure, imshow(maskedIR); title('Masked IR Image (Auto ROI)');
% 
% %% Step 4: Create STM and BM Masks
% stm = uint8(binaryMask) * 255;
% bm = uint8(~binaryMask) * 255;
% 
% figure;
% subplot(1,2,1); imshow(stm); title('Salient Target Mask');
% subplot(1,2,2); imshow(bm); title('Background Mask');
% 
% greyI = rgb2gray(IR);
% result1 = greyI .* uint8(binaryMask);
% figure, imshow(result1); title('Salient × Infrared');
% 
% result2 = greyI .* uint8(~binaryMask);
% figure, imshow(result2); title('Background × Infrared');
% 
% %% Step 5: Visible Image Fusion
% greyVIS = rgb2gray(VIS);
% stmDouble = double(stm) / 255;
% VIS_double = double(VIS);
% 
% Id = uint8(stmDouble .* double(greyVIS) + (1 - stmDouble) .* VIS_double);
% 
% % Ensure RGB format
% if size(Id, 3) == 1
%     Id_rgb = cat(3, Id, Id, Id);
% else
%     Id_rgb = Id;
% end
% 
% if size(maskedIR, 3) == 1
%     masked_rgb = cat(3, maskedIR, maskedIR, maskedIR);
% else
%     masked_rgb = maskedIR;
% end
% 
% %% Step 6: Final Fusion
% fusedFinal = uint8(0.5 * double(masked_rgb) + 0.5 * double(Id_rgb));
% figure, imshow(fusedFinal); title('Final Fused Output (Auto ROI + Otsu)');
% en=entropy(fusedFinal);
% % %% Step 7: Simulated Convolutional Enhancement
% % conv1x1_1 = fusedFinal;                     % Simulated 1×1 conv
% % conv3x3 = imgaussfilt(conv1x1_1, 1);        % Simulated 3×3 conv
% % conv1x1_2 = conv3x3;                        % Simulated 1×1 conv
% % 
% % convEnhanced = uint8(0.5 * double(fusedFinal) + 0.5 * double(conv1x1_2));
% % figure, imshow(convEnhanced); title('Simulated Convolutional Enhancement Output');
% 
% %% Step 8: Loss Function Evaluation
% fusedGray = rgb2gray(fusedFinal);
% refGray = rgb2gray(VIS);  % Reference can be VIS, IR, or maskedIR
% 
% % SSIM Loss
% ssimVal = ssim(fusedGray, refGray);
% L_ssim = 1 - ssimVal;
% 
% % Gradient Loss
% Gx_fused = imgradient(fusedGray, 'sobel');
% Gx_ref = imgradient(refGray, 'sobel');
% L_grad = mean(abs(double(Gx_fused) - double(Gx_ref)), 'all') / 255;
% 
% % Total Loss
% L_total = L_ssim + L_grad;
% 
% fprintf('\n--- Fusion Loss Evaluation ---\n');
% fprintf('SSIM Loss      : %.4f\n', L_ssim);
% fprintf('Gradient Loss  : %.4f\n', L_grad);
% fprintf('Total Loss     : %.4f\n', L_total);








clc; clear; close all;
%fusion is grayscale only
%% Step 1: Load Input Images
IR = imread('manWalkIR.jpg');
VIS = imread('manWalkVB.jpg');
figure, imshow(IR); title('Original Infrared Image');

%% Step 2: Preprocess Infrared Image
grayIR = rgb2gray(IR);
figure, imhist(grayIR); title('Histogram of Infrared Grayscale Image');
smoothedIR = imgaussfilt(grayIR, 2);         % Gaussian smoothing
level = graythresh(smoothedIR);              % Otsu threshold
threshold = round(level * 255);
fprintf('Computed Otsu Threshold: %d\n', threshold);
binaryMask = smoothedIR > threshold;
binaryMask = imclose(binaryMask, strel('disk', 5));   % Fill gaps
binaryMask = bwareaopen(binaryMask, 100);             % Remove small fragments

%% Step 3: Apply Mask to IR and Visible Images
maskedIR = grayIR .* uint8(binaryMask);
maskedVIS = rgb2gray(VIS) .* uint8(binaryMask);

%% Step 4: Create Backgrounds
backgroundVIS = rgb2gray(VIS) .* uint8(~binaryMask);

%% Step 5: Salient-region Fusion (Grayscale only!)
fusedROI = uint8(0.5 * double(maskedIR) + 0.5 * double(maskedVIS));
fusedFinalGray = fusedROI + backgroundVIS;

figure, imshow(fusedFinalGray, []); title('Final Fused Output (Gray IR + Gray VIS)');

%% Step 6: Simulated Convolutional Enhancement
% conv1x1_1 = fusedFinalGray; % Simulated 1×1 conv
% conv3x3 = imgaussfilt(conv1x1_1, 1);        % Simulated 3×3 conv
% conv1x1_2 = conv3x3;                        % Simulated 1×1 conv
% convEnhanced = uint8(0.5 * double(fusedFinalGray) + 0.5 * double(conv1x1_2));
% figure, imshow(convEnhanced, []); title('Simulated Convolutional Enhancement Output');
en=entropy(fusedFinalGray);
%% Step 7: Loss Function Evaluation
fusedGray = fusedFinalGray;
refGray = rgb2gray(VIS);  % Reference can be VIS, IR, or maskedIR

% SSIM Loss
ssimVal = ssim(fusedGray, refGray);
L_ssim = 1 - ssimVal;

% Gradient Loss
Gx_fused = imgradient(fusedGray, 'sobel');
Gx_ref = imgradient(refGray, 'sobel');
L_grad = mean(abs(double(Gx_fused) - double(Gx_ref)), 'all') / 255;

% Total Loss
L_total = L_ssim + L_grad;

fprintf('\n--- Fusion Loss Evaluation ---\n');
fprintf('SSIM Loss      : %.4f\n', L_ssim);
fprintf('Gradient Loss  : %.4f\n', L_grad);
fprintf('Total Loss     : %.4f\n', L_total);