function jointHist = jointHistogram(img1, img2)
    img1 = uint8(img1);
    img2 = uint8(img2);
    jointHist = zeros(256, 256);
    for i = 1:numel(img1)
        jointHist(img1(i)+1, img2(i)+1) = jointHist(img1(i)+1, img2(i)+1) + 1;
    end
end

function MI = computeMI(imgPath1, imgPath2)
    img1 = imread(imgPath1);
    img2 = imread(imgPath2);

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

clc; clear all; close all;

% Compute MI for IR image
MI_IR = computeMI("manWalkIR.jpg", "dwt_db2_final.jpg");    % dwt only
% MI_IR = computeMI("manWalkIR.jpg", "wavelet_std_result.jpg");     % dwt with STDFusionNet

% Compute MI for VB image
MI_VB = computeMI("manWalkVB.jpg", "dwt_db2_final.jpg");    % dwt only
% MI_VB = computeMI("manWalkVB.jpg", "wavelet_std_result.jpg");     % dwt with STDFusionNet

% Final MI sum
MIFinal = MI_IR + MI_VB;

% Display results
fprintf('Mutual Information (IR vs Fused): %.4f\n', MI_IR);
fprintf('Mutual Information (VB vs Fused): %.4f\n', MI_VB);
fprintf('Combined Mutual Information: %.4f\n', MIFinal);