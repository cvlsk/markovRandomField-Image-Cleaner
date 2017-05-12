
close all
im = imread('images/lena_noise.png');
im = int16(im);

y = im;
sz = size(im);
xdim = sz(2);
ydim = sz(1);

wrapN = @(x, N) (1 + mod(x-1, N));

lambda_d = 1.0;
lambda_s = 1.0;
step = 1;

change_flag=1;
count = 0;
while (change_flag && count < 1000)
    count = count + 1
    change_flag=0;
    for i=1:xdim
        for j=1:ydim

            xi = im(j,i);
            yi = y(j,i);
            a = im(wrapN(j - 1, ydim), i);
            b = im(j, wrapN(i + 1, xdim));
            c = im(wrapN(j+1,ydim), i);
            d = im(j, wrapN(i - 1, xdim));

            no_change = (-lambda_d * abs(xi - yi)) - (lambda_s * (abs(xi - a) + abs(xi - b) + abs(xi - c) + abs(xi - d)));
            xi = min(255, xi + step);
            pos_change = (-lambda_d * abs(xi - yi)) - (lambda_s * (abs(xi - a) + abs(xi - b) + abs(xi - c) + abs(xi - d)));
            xi = im(j,i);
            xi = max(0, xi - step);
            neg_change = (-lambda_d * abs(xi - yi)) - (lambda_s * (abs(xi - a) + abs(xi - b) + abs(xi - c) + abs(xi - d)));
            xi = im(j,i);

            if pos_change > no_change
                change_flag = 1;
                im(j,i) = min(255, xi + step);
            end
            if neg_change > no_change
                change_flag = 1;
                im(j,i) = max(0, xi - step);
            end
            
        end
    end
end

correct = imread('images/lena.png');

% Accuracy
accuracy = 1 - (sum(sum(xor(im,correct))) / (xdim * ydim))

% Resultant
imshow(uint8(im));

% Original
figure();
imshow(uint8(y));
