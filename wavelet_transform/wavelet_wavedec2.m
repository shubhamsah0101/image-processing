clc; clear; close all;

% Step 1: Read and preprocess images
IR = imread("manWalkIR.jpg");
VIS = imread("manWalkVB.jpg");
if size(IR,3)==3
    IR = rgb2gray(IR);
end

if size(VIS,3)==3
    VIS = rgb2gray(VIS);
end

VIS = imresize(VIS, size(IR));
IR = im2double(IR);
VIS = im2double(VIS);

figure(1)
subplot(1,2,1); imshow(IR, []); title('Infrared Image');
subplot(1,2,2); imshow(VIS, []); title('Visible Image');

% Step 2: Multi-level wavelet decomposition
level = 2;
waveletName = 'db2';
[C_IR, S_IR] = wavedec2(IR, level, waveletName);
[C_VIS, S_VIS] = wavedec2(VIS, level, waveletName);

% Step 3: Fuse coefficients
C_fused = C_IR; % Start with IR coefficients

% Fuse approximation (LL) coefficients
approx_len = prod(S_IR(1,:));
A_IR = C_IR(1:approx_len);
A_VIS = C_VIS(1:approx_len);
A_fused = (A_IR + A_VIS) / 2;
C_fused(1:approx_len) = A_fused;

% Fuse detail coefficients level by level
start = approx_len + 1;
for i = 1:level
    sz = S_IR(i+1,:); num = prod(sz);

    % Horizontal detail indices (LH)
    H_IR = C_IR(start : start+num-1);
    H_VIS = C_VIS(start : start+num-1);
    H_fused = max(abs(H_IR), abs(H_VIS)) .* sign(H_IR + H_VIS);
    C_fused(start : start+num-1) = H_fused;
    start = start + num;

    % Vertical detail indices (HL)
    V_IR = C_IR(start : start+num-1);
    V_VIS = C_VIS(start : start+num-1);
    V_fused = max(abs(V_IR), abs(V_VIS)) .* sign(V_IR + V_VIS);
    C_fused(start : start+num-1) = V_fused;
    start = start + num;

    % Diagonal detail indices (HH)
    D_IR = C_IR(start : start+num-1);
    D_VIS = C_VIS(start : start+num-1);
    D_fused = max(abs(D_IR), abs(D_VIS)) .* sign(D_IR + D_VIS);
    C_fused(start : start+num-1) = D_fused;
    start = start + num;
end

% Step 4: Reconstruct fused image
Fused = waverec2(C_fused, S_IR, waveletName);

% Step 5: Enhance and display
Fused_eq = histeq(Fused);

figure(2)
imshow(Fused, []); title('Fused Image (Raw)');

figure(3)
imshow(Fused_eq, []); title('Fused Image (Enhanced)');