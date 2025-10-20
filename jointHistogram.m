function jointHist = jointHistogram(img1, img2)
    img1 = uint8(img1);
    img2 = uint8(img2);
    jointHist = zeros(256, 256);
    for i = 1:numel(img1)
        jointHist(img1(i)+1, img2(i)+1) = jointHist(img1(i)+1, img2(i)+1) + 1;
    end
end