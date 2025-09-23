function F = manualDFT(f)

    [M, N] = size(f);
    
    F = zeros(M, N);

    for u = 1:M
        for v = 1:N
            sum = 0;
            for x = 1:M
                for y = 1:N
                    angle = -2 * pi * (((u-1)*(x-1)/M) + ((v-1)*(y-1)/N));
                    sum = sum + double(f(x,y)) * exp(1i * angle);
                end
            end
            F(u,v) = sum;
        end
    end

end
