function [mask_rg, mask_ws] = segmentation(I_proc, I_seed_map)
    % 1. RICERCA DEL SEME (Svincolata da Otsu)
    [~, maxIdx] = max(I_seed_map(:));
    [seedY, seedX] = ind2sub(size(I_proc), maxIdx);

    % 2. OTSU PER STIMARE L'INTENSITÀ LOCALE
    try
        levels = multithresh(I_proc, 2);
        mask_otsu = I_proc > levels(2); 
    catch
        mask_otsu = I_proc > 0.6; 
    end
    
    if any(mask_otsu(:))
        mask_otsu = bwareafilt(mask_otsu, 1); 
    end

    % 3. REGION GROWING CUSTOM (Tolleranza Estesa tramite Percentili)
    intensities = I_proc(mask_otsu);
    if isempty(intensities)
        % Fallback generico
        thresh_rg = prctile(I_proc(I_proc > 0), 80); 
    else
        % Invece di mean-std (sensibile agli outlier), usiamo il 10° percentile.
        % Significa: "Accetta tutti i pixel che sono più luminosi del 10% dei pixel più scuri di Otsu".
        % Questo allarga drasticamente la maschera (aumentando la Sensitivity)
        thresh_rg = prctile(intensities, 5); % Molto permissivo (5° percentile)
    end
    
    mask_rg = region_growing(I_proc, seedY, seedX, thresh_rg);

    % 4. MARKER-CONTROLLED WATERSHED
    D = -bwdist(~mask_rg);
    D(~mask_rg) = -Inf; 
    L = watershed(D);
    
    mask_ws = mask_rg;
    mask_ws(L == 0) = 0; 
end