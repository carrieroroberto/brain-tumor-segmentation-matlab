function [seed_point, marker_int, marker_ext, img_roi] = otsu_initialization(img)
    thresholds = multithresh(img, 3); 
    quantized = imquantize(img, thresholds);
    all_bright_spots = (quantized >= 3);
    
    se_break = strel('disk', 4); 
    broken_spots = imopen(all_bright_spots, se_break);
    
    stats = regionprops(broken_spots, img, 'Area', 'MeanIntensity', 'PixelIdxList', 'Solidity');
    
    if isempty(stats)
        se_break = strel('disk', 2);
        broken_spots = imopen(all_bright_spots, se_break);
        stats = regionprops(broken_spots, img, 'Area', 'MeanIntensity', 'PixelIdxList', 'Solidity');
    end
    
    if isempty(stats)
        se_break = strel('disk', 1);
        broken_spots = all_bright_spots;
        stats = regionprops(broken_spots, img, 'Area', 'MeanIntensity', 'PixelIdxList', 'Solidity');
    end
    
    if isempty(stats)
        error('Impossibile trovare candidati iper-intensi nella classe 3 di Otsu.');
    end
    
    scores = [stats.Area] .* [stats.MeanIntensity] .* ([stats.Solidity].^3);
    [~, target_idx] = max(scores);
    
    target_pixels = stats(target_idx).PixelIdxList;
    [~, local_max_idx] = max(img(target_pixels));
    [r, c] = ind2sub(size(img), target_pixels(local_max_idx));
    seed_point = [r, c];
    
    tumor_mask = bwselect(broken_spots, c, r, 4); 
    
    tumor_mask = imdilate(tumor_mask, se_break);
    tumor_mask = imfill(tumor_mask, 'holes');
    
    tumor_mask = tumor_mask & all_bright_spots;
    
    img_roi = img;
    img_roi(~tumor_mask) = 0;
    
    marker_int = imerode(tumor_mask, strel('disk', 3));
    marker_ext = ~imdilate(tumor_mask, strel('disk', 15)) & (img > 0.05);
end