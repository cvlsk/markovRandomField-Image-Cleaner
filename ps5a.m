
close all
im = imread('images/bayes_dirty.png');
im = int8(im);
im = (im * 2) - 1;
y = im;
sz = size(im);
xdim = sz(2);
ydim = sz(1);

count = 0;

wrapN = @(x, N) (1 + mod(x-1, N));
h = -.01
beta = 5
eta = 3
change_flag=1;

while (change_flag)
    count = count + 1
    change_flag=0;
    for i=1:xdim
        for j=1:ydim

            no_flip_energy = energy(   im(j,i ), im( j, wrapN(i+1, xdim)), im( j, wrapN(i-1, xdim)), im( wrapN(j+1, ydim), i ), im( wrapN(j-1, ydim), i ), y(j,i), h, beta, eta );
            flip_energy = energy(-1*im(j,i), im( j, wrapN(i+1, xdim)), im( j, wrapN(i-1, xdim)), im( wrapN(j+1, ydim), i ), im( wrapN(j-1, ydim), i ), y(j,i), h, beta, eta );

            if flip_energy < no_flip_energy
                im(j, i) = -1 * im(j,i);
                change_flag = 1;
            end

        end
    end
end

im = (im + 1) / 2;
correct = imread('images/bayes.png');

% Accuracy
accuracy = 1 - (sum(sum(xor(im, correct))) / (xdim * ydim))

% Resultant
im = uint8(im);
imshow(255 * im);

% Original
figure();
imshow(uint8(y) * 255);
