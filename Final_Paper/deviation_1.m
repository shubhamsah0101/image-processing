function deviationValue = deviation_1(IR_image, Fused_image)

    % Convert to grayscale if needed
    if size(IR_image,3) == 3
        IR_gray = rgb2gray(IR_image);
    else
        IR_gray = IR_image;
    end

    if size(Fused_image,3) == 3
        fused_gray = rgb2gray(Fused_image);
    else
        fused_gray = Fused_image;
    end

    % Convert images to double (0–1)
    IR_gray = im2double(IR_gray);
    fused_gray = im2double(fused_gray);

    % Resize fused image if sizes mismatch
    if ~isequal(size(IR_gray), size(fused_gray))
        fused_gray = imresize(fused_gray, size(IR_gray));
    end

    % Compute absolute deviation map
    DeviationMap = abs(IR_gray - fused_gray);

    % Final deviation value
    deviationValue = mean(DeviationMap, "all");
end
