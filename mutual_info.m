clc; clear all; close all;

% Compute MI for IR image
MI_IR = computeMI("manWalkIR.jpg", "final_result_2_new.jpg");

% Compute MI for VB image
MI_VB = computeMI("manWalkVB.jpg", "final_result_2_new.jpg");

% Final MI sum
MIFinal = MI_IR + MI_VB;

% Display results
fprintf('Mutual Information (IR vs Fused): %.4f\n', MI_IR);
fprintf('Mutual Information (VB vs Fused): %.4f\n', MI_VB);
fprintf('Combined Mutual Information: %.4f\n', MIFinal);