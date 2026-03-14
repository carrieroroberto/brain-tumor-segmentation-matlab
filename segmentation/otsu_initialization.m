function [seed_point, marker_int, marker_ext] = otsu_initialization(img)
    thresholds = multithresh(img, 2);
    
    quantized = imquantize(img, thresholds);
    
    tumor_raw = (quantized == 3);
    
    tumor_clean = bwareafilt(tumor_raw, 1);
    
    se_int = strel('disk', 3);
    marker_int = imerode(tumor_clean, se_int);
    
    se_ext = strel('disk', 15);
    marker_ext = ~imdilate(tumor_clean, se_ext) & (quantized > 1);
    
    stats = regionprops(tumor_clean, 'Centroid');
    if ~isempty(stats)
        centroid = stats(1).Centroid;
        seed_point = [round(centroid(2)), round(centroid(1))];
    else
        seed_point = [round(size(img,1)/2), round(size(img,2)/2)];
    end
end