function [F_shifted, magnitude_spectrum] = computeFFT2D(img)

    % computeFFT2D - Compute 2D FFT of an image and return shifted spectrum & magnitude
    %
    % Syntax:   [F_shifted, magnitude_spectrum] = computeFFT2D(img)
    %
    % Inputs:   img - Input image (grayscale or RGB)
    %
    % Outputs:  F_shifted - FFT shifted to center zero frequency 
    %           magnitude_spectrum - Log magnitude spectrum for visualization

    % Convert to double
    img = double(img);
    
    % Compute FFT
    F = fft2(img);
    
    % Shift zero frequency component to center
    F_shifted = fftshift(F);
    
    % Compute magnitude spectrum with log scaling for display
    magnitude_spectrum = log(abs(F_shifted) + 1);

end
