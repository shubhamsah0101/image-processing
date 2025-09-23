% IDEAL_LOWPASS_FILTER Applies an Ideal Low-Pass Filter in frequency domain.
%
% Usage:
%   filtered_img = ideal_lowpass_filter(input_img, D0)
%
% Parameters:
%   input_img : Grayscale image (uint8 or double)
%   D0        : Cutoff frequency (positive scalar)
%
% Returns:
%   filtered_img : Filtered image in spatial domain

function filtered_img = ideal_lowpass_filter(img, D0)

% Convert to double in range [0, 1] if not already
    if ~isfloat(img)
        img = im2double(img);
    end

    [M, N] = size(img);

    % 1. FFT and center shift
    F = fft2(img);
    F_shifted = fftshift(F);

    % 2. Create Ideal Low-Pass Filter Mask
    u = 0:M-1; 
    v = 0:N-1;
    u = u - floor(M/2);
    v = v - floor(N/2);
    [U, V] = meshgrid(v, u);

    D = sqrt(U.^2 + V.^2);
    H = double(D <= D0);

    % 3. Apply filter
    G = F_shifted .* H;

    % 4. Inverse FFT
    G_unshifted = ifftshift(G);
    filtered_img = real(ifft2(G_unshifted));

end
