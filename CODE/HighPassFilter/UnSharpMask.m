% UNSHARP MASKING AND HIGHBOOST FILTERING
% if k = 1 -> UNSHARP MASK
% if k > 1 -> HIBOOST

function sharpened = UnSharpMask(i_img, k)

    % Convert to double
    i_img = double(i_img);

    % Get size
    [m, n] = size(i_img);

    % Define simple 3x3 average blur kernel (box filter)
    blur_kernel = (1/9) * ones(3,3);

    % Zero-padding the image
    padded = zeros(m+2, n+2);
    padded(2:m+1, 2:n+1) = i_img;

    % Initialize blurred image
    blurred = zeros(m, n);

    % Apply manual convolution for blur
    for i = 2:m+1
        for j = 2:n+1
            sum = 0;
            for a = -1:1
                for b = -1:1
                    sum = sum + blur_kernel(a+2, b+2) * padded(i+a, j+b);
                end
            end
            blurred(i-1, j-1) = sum;
        end
    end

    % Compute the mask (edge detail)
    mask = i_img - blurred;

    % Apply unsharp masking
    sharpened = i_img + k * mask;

    % Clamp values to [0, 255]
    sharpened = max(0, min(sharpened, 255));

    % Convert to uint8
    sharpened = uint8(sharpened);

end
