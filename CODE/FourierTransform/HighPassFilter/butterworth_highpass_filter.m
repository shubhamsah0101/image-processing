% BUTTERWORTH_HIGHPASS_FILTER Applies Butterworth HPF in frequency domain.
%
% Usage:
%   filtered_img = butterworth_highpass_filter(input_img, D0, n)
%
% Parameters:
%   input_img : Grayscale image (uint8 or double)
%   D0        : Cutoff frequency (positive scalar)
%   n         : Order of filter (positive integer, sharpness control)
%
% Returns:
%   filtered_img : High-pass filtered image in spatial domain

function filtered_img = butterworth_highpass_filter(input_img, D0, n)

    if ~isfloat(input_img)
        input_img = im2double(input_img);
    end

    [M, N] = size(input_img);

    % 1. FFT and center shift
    F = fft2(input_img);
    F_shifted = fftshift(F);

    % 2. Create Butterworth HPF Mask
    u = 0:M-1; v = 0:N-1;
    u = u - floor(M/2);
    v = v - floor(N/2);
    [U, V] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);

    % Butterworth high-pass formula
    H = 1 ./ (1 + (D0 ./ (D + eps)).^(2*n));  % eps avoids division by zero

    % 3. Apply filter
    G = F_shifted .* H;

    % 4. Inverse FFT
    G_unshifted = ifftshift(G);
    filtered_img = real(ifft2(G_unshifted));

end
