function mask_final = refinement(mask_raw)
    mask_raw = logical(mask_raw);
    
    se_bridge = strel('disk', 4); 
    mask_sealed = imclose(mask_raw, se_bridge);
    
    mask_filled = imfill(mask_sealed, 'holes');
    
    mask_final = bwareafilt(mask_filled, 1);
end