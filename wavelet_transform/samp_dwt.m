clc; clear all; close all;

% Read and preprocess images
IR = imread("manWalkIR.jpg");
VIS = imread("manWalkVB.jpg");

if size(IR,3)==3, IR = rgb2gray(IR); end
if size(VIS,3)==3, VIS = rgb2gray(VIS); end
VIS = imresize(VIS, size(IR));

IR = im2double(IR); VIS = im2double(VIS);

level = 2; waveletName = 'db2';

% 2-level wavelet decomposition
[C_IR, S_IR] = wavedec2(IR, level, waveletName);
[C_VIS, S_VIS] = wavedec2(VIS, level, waveletName);

% Level 1 components
LL1_IR = appcoef2(C_IR, S_IR, waveletName, 1);
[LH1_IR, HL1_IR, HH1_IR] = detcoef2('all', C_IR, S_IR, 1);

LL1_VIS = appcoef2(C_VIS, S_VIS, waveletName, 1);
[LH1_VIS, HL1_VIS, HH1_VIS] = detcoef2('all', C_VIS, S_VIS, 1);

% Level 2 components
LL2_IR = appcoef2(C_IR, S_IR, waveletName, 2);
[LH2_IR, HL2_IR, HH2_IR] = detcoef2('all', C_IR, S_IR, 2);

LL2_VIS = appcoef2(C_VIS, S_VIS, waveletName, 2);
[LH2_VIS, HL2_VIS, HH2_VIS] = detcoef2('all', C_VIS, S_VIS, 2);

% Variance-based fusion (approximation averaged, detail chosen by higher variance)
C_fused = C_IR;
approx_len = prod(S_IR(1,:));
A_IR = C_IR(1:approx_len); A_VIS = C_VIS(1:approx_len);
C_fused(1:approx_len) = (A_IR + A_VIS) / 2;

start = approx_len + 1;
for i = 1:level
    sz = S_IR(i+1,:); num = prod(sz);

    % LH (Horizontal details)
    H_IR = C_IR(start : start+num-1); H_VIS = C_VIS(start : start+num-1);
    var_IR = var(H_IR(:)); var_VIS = var(H_VIS(:));
    C_fused(start : start+num-1) = (var_IR > var_VIS) * H_IR + (var_IR <= var_VIS) * H_VIS;
    start = start + num;

    % HL (Vertical details)
    V_IR = C_IR(start : start+num-1); V_VIS = C_VIS(start : start+num-1);
    var_IR = var(V_IR(:)); var_VIS = var(V_VIS(:));
    C_fused(start : start+num-1) = (var_IR > var_VIS) * V_IR + (var_IR <= var_VIS) * V_VIS;
    start = start + num;

    % HH (Diagonal details)
    D_IR = C_IR(start : start+num-1); D_VIS = C_VIS(start : start+num-1);
    var_IR = var(D_IR(:)); var_VIS = var(D_VIS(:));
    C_fused(start : start+num-1) = (var_IR > var_VIS) * D_IR + (var_IR <= var_VIS) * D_VIS;
    start = start + num;
end

Fused = waverec2(C_fused, S_IR, waveletName);

% Show original images
figure;
subplot(1,2,1); imshow(IR, []); title('Original IR');
subplot(1,2,2); imshow(VIS, []); title('Original VIS');

% Show level 1 components (VIS and IR in separate figures)
figure;
subplot(2,2,1); imshow(LL1_IR, []); title('IR Level 1 Approx');
subplot(2,2,2); imshow(LH1_IR, []); title('IR Level 1 Horizontal');
subplot(2,2,3); imshow(HL1_IR, []); title('IR Level 1 Vertical');
subplot(2,2,4); imshow(HH1_IR, []); title('IR Level 1 Diagonal');

figure;
subplot(2,2,1); imshow(LL1_VIS, []); title('VIS Level 1 Approx');
subplot(2,2,2); imshow(LH1_VIS, []); title('VIS Level 1 Horizontal');
subplot(2,2,3); imshow(HL1_VIS, []); title('VIS Level 1 Vertical');
subplot(2,2,4); imshow(HH1_VIS, []); title('VIS Level 1 Diagonal');

% Show level 2 components (IR and VIS in separate figures)
figure;
subplot(2,2,1); imshow(LL2_IR, []); title('IR Level 2 Approx');
subplot(2,2,2); imshow(LH2_IR, []); title('IR Level 2 Horizontal');
subplot(2,2,3); imshow(HL2_IR, []); title('IR Level 2 Vertical');
subplot(2,2,4); imshow(HH2_IR, []); title('IR Level 2 Diagonal');

figure;
subplot(2,2,1); imshow(LL2_VIS, []); title('VIS Level 2 Approx');
subplot(2,2,2); imshow(LH2_VIS, []); title('VIS Level 2 Horizontal');
subplot(2,2,3); imshow(HL2_VIS, []); title('VIS Level 2 Vertical');
subplot(2,2,4); imshow(HH2_VIS, []); title('VIS Level 2 Diagonal');

% Show the final fused image
figure;
imshow(Fused, []); title('Final Fused Image (Variance-based Fusion)');

figure;

a = imgaussfilt(Fused);
imshow(a)