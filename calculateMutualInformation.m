function mi = calculateMutualInformation(imageA, imageB)
%CALCULATEMUTUALINFORMATION Calculates the mutual information between two images.
%   mi = CALCULATEMUTUALINFORMATION(imageA, imageB) computes the mutual
%   information between imageA and imageB. Both images must be of the same size.

% Ensure images are of type uint8 for histogram calculation
imageA=imread("manWalkIR.jpg");
imageB=imread("final_result.jpg");
imageA = im2uint8(imageA);
imageB = im2uint8(imageB);

% Get image dimensions
[rows, cols] = size(imageA);

% Calculate joint histogram (256x256 for 8-bit images)
jointHist = zeros(256, 256);
for i = 1:rows
    for j = 1:cols
        pixelA = imageA(i, j) + 1; % +1 because MATLAB indices are 1-based
        pixelB = imageB(i, j) + 1;
        jointHist(pixelA, pixelB) = jointHist(pixelA, pixelB) + 1;
    end
end

% Normalize joint histogram to get joint probability distribution
jointProb = jointHist / (rows * cols);

% Calculate marginal probability distributions
probA = sum(jointProb, 2); % Sum across columns to get marginal for imageA
probB = sum(jointProb, 1); % Sum across rows to get marginal for imageB

% Calculate mutual information
mi = 0;
for i = 1:256
    for j = 1:256
        if jointProb(i, j) > 0 && probA(i) > 0 && probB(j) > 0
            mi = mi + jointProb(i, j) * log2(jointProb(i, j) / (probA(i) * probB(j)));
        end
    end
end

end