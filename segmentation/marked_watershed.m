function mask = marked_watershed(img, marker_int, marker_ext)
    se = strel('disk', 1);
    grad = imdilate(img, se) - imerode(img, se);
    
    grad_mod = imimposemin(grad, marker_int | marker_ext);
    
    L = watershed(grad_mod);
    
    target_label = median(L(marker_int > 0));
    
    mask = (L == target_label);
end