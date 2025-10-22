function score = FSIM(img1, img2)
    % FSIM (Feature Similarity Index) between two grayscale images
    % Input: img1, img2 [0,1], grayscale double
    % Output: FSIM score (scalar)
    
    % Convert images to double and normalize
    if ~isa(img1, 'double')
        img1 = double(img1) / 255;
    end
    if ~isa(img2, 'double')
        img2 = double(img2) / 255;
    end
    
    % Parameters
    T1 = 0.85;  % Stabilizing constant for Phase Congruency
    T2 = 160;   % Stabilizing constant for Gradient Magnitude
    
    % Compute Phase Congruency maps for both images
    PC1 = phasecong(img1);
    PC2 = phasecong(img2);
    
    % Compute gradient magnitude for both images
    grad1 = gradientMag(img1);
    grad2 = gradientMag(img2);
    
    % Similarity measure for Phase Congruency
    S_pc = (2 .* PC1 .* PC2 + T1) ./ (PC1.^2 + PC2.^2 + T1);
    
    % Similarity measure for Gradient Magnitude
    S_g = (2 .* grad1 .* grad2 + T2) ./ (grad1.^2 + grad2.^2 + T2);
    
    % Combined local similarity map
    S_l = S_pc .* S_g;
    
    % Weight map (max of PC maps)
    PCm = max(PC1, PC2);
    
    % Final FSIM calculation: weighted average of similarity
    score = sum(S_l(:) .* PCm(:)) / sum(PCm(:));
end

function PC = phasecong(I)
    % Simplified phase congruency calculation
    % (For full accurate use, download Kovesi's phasecong3.m)
    
    % Parameters for Gabor wavelets
    nscale  = 4;  % number of scales
    norient = 4;  % number of orientations
    minWaveLength = 6;
    mult = 2;
    sigmaOnf = 0.55;
    
    [rows, cols] = size(I);
    PC = zeros(rows, cols);
    
    % For demonstration, approximate with edge strength (can replace with real phase congruency)
    PC = edge(I, 'canny');
    PC = double(PC);
end

function G = gradientMag(I)
    % Compute gradient magnitude using Sobel operator
    
    hx = fspecial('sobel');
    hy = hx';
    
    Ix = imfilter(I, hx, 'replicate');
    Iy = imfilter(I, hy, 'replicate');
    
    G = sqrt(Ix.^2 + Iy.^2);
end