% LAPLACIAN_FREQUENCY Applies Laplacian filter in the frequency domain
%
% Returns a Laplacian-enhanced image (may need to add back to original for sharpening)

function laplacian_img = laplacian_frequency(input_img)

    if ~isfloat(input_img)
        input_img = im2double(input_img);
    end

    [M, N] = size(input_img);

    % 1. FFT
    F = fft2(input_img);
    F_shifted = fftshift(F);

    % 2. Frequency coordinates
    u = 0:M-1; v = 0:N-1;
    u = u - floor(M/2);
    v = v - floor(N/2);
    [U, V] = meshgrid(v, u);

    % 3. Laplacian filter in frequency domain
    H = -4 * pi^2 * (U.^2 + V.^2);

    % 4. Apply Laplacian filter
    G = H .* F_shifted;

    % 5. Inverse FFT
    G_unshifted = ifftshift(G);
    laplacian_img = real(ifft2(G_unshifted));
end
