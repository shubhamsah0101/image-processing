% GAUSSIAN_LOWPASS_FILTER Applies a Gaussian Low-Pass Filter in frequency domain.
%
% Usage:
%   filtered_img = gaussian_lowpass_filter(input_img, D0)
%
% Parameters:
%   input_img : Grayscale image (uint8 or double)
%   D0        : Cutoff frequency (positive scalar)
%
% Returns:
%   filtered_img : Filtered image in spatial domain

function filtered_img = gaussian_lowpass_filter(input_img, D0)

% Convert to double in range [0, 1] if not already
    if ~isfloat(input_img)
        input_img = im2double(input_img);
    end

    [M, N] = size(input_img);

    % 1. FFT and shift
    F = fft2(input_img);
    F_shifted = fftshift(F);

    % 2. Create Gaussian Low-Pass Filter Mask
    u = 0:M-1; v = 0:N-1;
    u = u - floor(M/2);
    v = v - floor(N/2);
    [U, V] = meshgrid(v, u);

    D = sqrt(U.^2 + V.^2);
    H = exp(-(D.^2) / (2 * D0^2));  % Gaussian LPF

    % 3. Apply filter
    G = F_shifted .* H;

    % 4. Inverse FFT
    G_unshifted = ifftshift(G);
    filtered_img = real(ifft2(G_unshifted));
    
end
