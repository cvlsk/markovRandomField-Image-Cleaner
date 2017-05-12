function [bipimg] = img_to_bip(imgpath)
    i = imread(imgpath);
    greybayes = i(:,:,2);
    greater = greybayes > 128;
    bipimg= (greater * 2 ) - 1;
end
