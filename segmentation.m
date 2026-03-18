function mask = segmentation(I_proc, seed_map)
% SEGMENTATION: Cascata Otsu -> Region Growing -> Watershed

    [~, maxIdx] = max(seed_map(:));
    [seedY, seedX] = ind2sub(size(I_proc), maxIdx);

    try
        levels = multithresh(I_proc, 2);
        mask_otsu = I_proc > levels(2); 
    catch
        mask_otsu = I_proc > 0.6; 
    end
    if any(mask_otsu(:)), mask_otsu = bwareafilt(mask_otsu, 1); end

    intensities = I_proc(mask_otsu);
    if isempty(intensities)
        thresh_rg = mean(I_proc(:)); 
    else
        % Soglia Adattiva (Aumenta la Sensitivity)
        thresh_rg = prctile(intensities, 5); 
    end
    
    mask_rg = region_growing(I_proc, seedY, seedX, thresh_rg);

    % Marker-Controlled Watershed (Usa RG come marker interno)
    D = -bwdist(~mask_rg);
    D(~mask_rg) = -Inf; 
    L = watershed(D);
    
    mask = mask_rg;
    mask(L == 0) = 0; 
end