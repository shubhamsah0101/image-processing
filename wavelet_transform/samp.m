clc; clear all; close all;

% Read and preprocess images
IR = imread("manWalkIR.jpg");
VIS = imread("manWalkVB.jpg");

% Original images display
figure(1)
subplot(1,2,1); imshow(IR, []); title('Infrared Image');
subplot(1,2,2); imshow(VIS, []); title('Visible Image');

% Convert to grayscale if necessary
if size(IR,3) == 3
    IR = rgb2gray(IR);
end
if size(VIS,3) == 3
    VIS = rgb2gray(VIS);
end

% Resize visible image to match IR dimensions
[rows, cols] = size(IR);
VIS = imresize(VIS, [rows cols]);

% Convert to double precision for processing
IR = im2double(IR);
VIS = im2double(VIS);

% Apply single-level DWT
[LL_IR, LH_IR, HL_IR, HH_IR] = dwt2(IR, 'db2', 2);
[LL_VIS, LH_VIS, HL_VIS, HH_VIS] = dwt2(VIS, 'db2', 2);

% Display wavelet components for infrared image
figure(2)
subplot(2,2,1); imshow(LL_IR, []); title('Approximation (LL) IR');
subplot(2,2,2); imshow(LH_IR, []); title('Horizontal Detail (LH) IR');
subplot(2,2,3); imshow(HL_IR, []); title('Vertical Detail (HL) IR');
subplot(2,2,4); imshow(HH_IR, []); title('Diagonal Detail (HH) IR');

% Display wavelet components for visible image
figure(3)
subplot(2,2,1); imshow(LL_VIS, []); title('Approximation (LL) VIS');
subplot(2,2,2); imshow(LH_VIS, []); title('Horizontal Detail (LH) VIS');
subplot(2,2,3); imshow(HL_VIS, []); title('Vertical Detail (HL) VIS');
subplot(2,2,4); imshow(HH_VIS, []); title('Diagonal Detail (HH) VIS');

% Fuse approximation coefficients as average
LL_fused = (0.6*LL_IR + 0.4*LL_VIS);

% Compute variances of detail coefficients
var_LH_IR = var(LH_IR(:));
var_LH_VIS = var(LH_VIS(:));
var_HL_IR = var(HL_IR(:));
var_HL_VIS = var(HL_VIS(:));
var_HH_IR = var(HH_IR(:));
var_HH_VIS = var(HH_VIS(:));

% Fuse detail coefficients by selecting based on higher variance
if var_LH_IR > var_LH_VIS
    LH_fused = LH_IR;
else
    LH_fused = LH_VIS;
end

if var_HL_IR > var_HL_VIS
    HL_fused = HL_IR;
else
    HL_fused = HL_VIS;
end

if var_HH_IR > var_HH_VIS
    HH_fused = HH_IR;
else
    HH_fused = HH_VIS;
end

% Reconstruct fused image from fused coefficients
Fused = idwt2(LL_fused, LH_fused, HL_fused, HH_fused, 'db2');

% Display fused image
figure(4)
imshow(Fused, [])
title("Fused Image using Variance-based Fusion for Details");

% ==============================
% Compute image entropy (EN)
% ==============================

img = Fused;
if size(img, 3) == 3
    img = rgb2gray(img);
end

img = double(img);
numBins = 256;
counts = imhist(img, numBins);
probs = counts / sum(counts);
probs(probs == 0) = [];
entropyValue = -sum(probs .* log2(probs));
fprintf('Entropy of the fused image: %.4f\n', entropyValue);

% ==============================
% Mutual Information Computation
% ==============================

% Compute MI for IR image
MI_IR = computeMI("manWalkIR.jpg", Fused);

% Compute MI for VB image
MI_VB = computeMI("manWalkVB.jpg", Fused);

% Final MI sum
MIFinal = MI_IR + MI_VB;

% Display results
fprintf('Mutual Information (IR vs Fused): %.4f\n', MI_IR);
fprintf('Mutual Information (VB vs Fused): %.4f\n', MI_VB);
fprintf('Combined Mutual Information: %.4f\n', MIFinal);

% ==============================
% Functions
% ==============================

function jointHist = jointHistogram(img1, img2)
    img1 = uint8(img1);
    img2 = uint8(img2);
    jointHist = zeros(256, 256);
    for i = 1:numel(img1)
        jointHist(img1(i)+1, img2(i)+1) = jointHist(img1(i)+1, img2(i)+1) + 1;
    end
end

function MI = computeMI(imgPath1, img2)
    img1 = imread(imgPath1);

    % Convert to grayscale if needed
    if size(img1, 3) == 3
        img1 = rgb2gray(img1);
    end
    if size(img2, 3) == 3
        img2 = rgb2gray(img2);
    end

    % Resize to match dimensions
    if ~isequal(size(img1), size(img2))
        img2 = imresize(img2, size(img1));
    end

    % Convert to double
    img1 = double(img1);
    img2 = double(img2);

    % Compute joint histogram
    jointHist = jointHistogram(img1, img2);

    % Normalize to get joint probability
    jointProb = jointHist / sum(jointHist(:));

    % Marginal probabilities
    p1 = sum(jointProb, 2);  % over columns
    p2 = sum(jointProb, 1);  % over rows

   % computeMI
    MI = 0;
    for i = 1:length(p1)
        for j = 1:length(p2)
            if jointProb(i,j) > 0
                MI = MI + jointProb(i,j) * log2(jointProb(i,j) / (p1(i) * p2(j)));
            end
        end
    end
end
