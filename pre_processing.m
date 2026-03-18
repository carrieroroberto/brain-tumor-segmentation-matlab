function [imgs_proc, mask_gt, seed_map, prep_steps] = pre_processing(path_img, path_gt)
% PRE_PROCESSING: Estrae la slice ottima e genera le 5 configurazioni 
% per il test di ablazione completo.

    vol_4d = double(niftiread(path_img));
    vol_gt = double(niftiread(path_gt));

    scores = squeeze(sum(sum(vol_gt > 0, 1), 2));
    [~, z_best] = max(scores);

    img_fl   = vol_4d(:,:,z_best,1);
    img_t1 = vol_4d(:,:,z_best,2);
    img_t1c = vol_4d(:,:,z_best,3);
    img_t2   = vol_4d(:,:,z_best,4);
    mask_gt  = vol_gt(:,:,z_best) > 0;
    
    img_raw_flair = mat2gray(img_fl);

    % Maschera del tessuto cerebrale
    mask_brain = img_fl > 0;
    mask_brain = imfill(mask_brain, 'holes');

    % Z-Score indipendente per canale
    if any(mask_brain(:))
        img_fl(mask_brain)   = (img_fl(mask_brain)   - mean(img_fl(mask_brain)))   / std(img_fl(mask_brain));
        img_t1(mask_brain)   = (img_t1(mask_brain)   - mean(img_t1(mask_brain)))   / std(img_t1(mask_brain));
        img_t1c(mask_brain) = (img_t1c(mask_brain) - mean(img_t1c(mask_brain))) / std(img_t1c(mask_brain));
        img_t2(mask_brain)   = (img_t2(mask_brain)   - mean(img_t2(mask_brain)))   / std(img_t2(mask_brain));
    end
    
    img_fl = mat2gray(img_fl);       img_fl(~mask_brain) = 0;
    img_t1 = mat2gray(img_t1);       img_t1(~mask_brain) = 0;
    img_t1c = mat2gray(img_t1c);   img_t1c(~mask_brain) = 0;
    img_t2 = mat2gray(img_t2);       img_t2(~mask_brain) = 0;

    % Funzione anonima per Filtro + CLAHE
    apply_filters = @(I) adapthisteq(medfilt2(I, [3 3]), 'ClipLimit', 0.015);

    % --- GENERAZIONE DELLE 5 CONFIGURAZIONI SPERIMENTALI ---
    imgs_proc.flair = apply_filters(img_fl);
    imgs_proc.t1 = apply_filters(img_t1);
    imgs_proc.t1c   = apply_filters(img_t1c);
    imgs_proc.t2    = apply_filters(img_t2);
    imgs_proc.fus2  = apply_filters((0.6 * img_fl) + (0.4 * img_t1c)); % Fusione a 2
    imgs_proc.fus3  = apply_filters((0.5 * img_fl) + (0.3 * img_t1c) + (0.2 * img_t2)); % Fusione a 3

    % Mappa Seme Sfocata (calcolata sulla Fusion a 3 per massima stabilità)
    props = regionprops(mask_gt, 'BoundingBox');
    roi_mask = false(size(mask_gt));
    if ~isempty(props)
        bb = floor(props(1).BoundingBox);
        pad = 20; 
        x_min = max(1, bb(1) - pad); y_min = max(1, bb(2) - pad);
        x_max = min(size(mask_gt, 2), bb(1) + bb(3) + pad);
        y_max = min(size(mask_gt, 1), bb(2) + bb(4) + pad);
        roi_mask(y_min:y_max, x_min:x_max) = true;
    end
    
    I_seed_only = imgs_proc.fus3;
    I_seed_only(~roi_mask) = 0; 
    seed_map = imgaussfilt(I_seed_only, 4); 

    prep_steps.raw = img_raw_flair;
end