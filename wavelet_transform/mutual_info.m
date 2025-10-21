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