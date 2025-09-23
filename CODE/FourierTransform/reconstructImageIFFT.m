function img_reconstructed = reconstructImageIFFT(F_shifted)
    
    % reconstructImageIFFT - Compute inverse 2D FFT from shifted frequency spectrum
    %
    % Syntax:   img_reconstructed = reconstructImageIFFT(F_shifted)
    %
    % Inputs:   F_shifted - Shifted complex FFT spectrum (output of computeFFT2D)
    %
    % Outputs:  img_reconstructed - Reconstructed spatial domain image (real part)
    
    % Shift zero frequency back
    F_ishift = ifftshift(F_shifted);
    
    % Inverse FFT
    img_ifft = ifft2(F_ishift);
    
    % Take real part to obtain reconstructed image
    img_reconstructed = real(img_ifft);

end
