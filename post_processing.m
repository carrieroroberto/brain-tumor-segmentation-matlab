function mask_clean = post_processing(mask_raw)
% POST_PROCESSING: Algebra morfologica per regolarizzazione contorni e filling.
    se = strel('disk', 3);
    mask_clean = imclose(mask_raw, se);
    mask_clean = imfill(mask_clean, 'holes');
    
    if any(mask_clean(:)) 
        mask_clean = bwareafilt(mask_clean, 1);
    end
end