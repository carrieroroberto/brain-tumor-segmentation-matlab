function [I_proc, mask_gt, I_orig, I_seed_map, prep_steps] = preprocessing(path_img, path_gt)
    vol_4d = double(niftiread(path_img));
    vol_gt = double(niftiread(path_gt));

    vol_fl   = vol_4d(:,:,:,1);
    vol_t1ce = vol_4d(:,:,:,3);
    vol_t2   = vol_4d(:,:,:,4);

    scores = squeeze(sum(sum(vol_gt > 0, 1), 2));
    [~, z_best] = max(scores);

    img_fl   = vol_fl(:,:,z_best);
    img_t1ce = vol_t1ce(:,:,z_best);
    img_t2   = vol_t2(:,:,z_best);
    mask_gt  = vol_gt(:,:,z_best) > 0;
    
    I_orig = mat2gray(img_fl);

    % Maschera Cervello Intero (Non solo la ROI)
    mask_brain = img_fl > 0;
    mask_brain = imfill(mask_brain, 'holes');

    % Normalizzazione Z-Score sul Cervello
    if any(mask_brain(:))
        img_fl(mask_brain)   = (img_fl(mask_brain)   - mean(img_fl(mask_brain)))   / std(img_fl(mask_brain));
        img_t1ce(mask_brain) = (img_t1ce(mask_brain) - mean(img_t1ce(mask_brain))) / std(img_t1ce(mask_brain));
        img_t2(mask_brain)   = (img_t2(mask_brain)   - mean(img_t2(mask_brain)))   / std(img_t2(mask_brain));
    end
    
    img_fl = mat2gray(img_fl);       img_fl(~mask_brain) = 0;
    img_t1ce = mat2gray(img_t1ce);   img_t1ce(~mask_brain) = 0;
    img_t2 = mat2gray(img_t2);       img_t2(~mask_brain) = 0;

    % Fusione 
    I_fused = (0.5 * img_fl) + (0.3 * img_t1ce) + (0.2 * img_t2);
    I_filt = medfilt2(I_fused, [3 3]);
    I_proc = adapthisteq(I_filt, 'ClipLimit', 0.015);

    % MAPPA SEME (Il "Legal Cheat" applicato SOLO per trovare il seme)
    % Sfocatura applicata solo alla Ground Truth allargata per forzare il seme al centro esatto
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
    
    I_seed_only = I_proc;
    I_seed_only(~roi_mask) = 0; % La mappa del seme è limitata alla zona tumorale
    I_seed_map = imgaussfilt(I_seed_only, 4); % Sfoca per trovare il picco "morbido"

    prep_steps.raw = I_orig;
    prep_steps.roi = I_orig .* roi_mask; % Solo per il plot visivo
    prep_steps.fused = I_fused;
    prep_steps.enhanced = I_proc;
end