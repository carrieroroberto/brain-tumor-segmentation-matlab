function [img_2d, mask_gt] = data_loader(fileName, gtName)
    vol = double(niftiread(fileName));
    vol_gt = double(niftiread(gtName));
    
    v_fl = vol(:,:,:,1);
    v_t1 = vol(:,:,:,2); % T1 nativa (tumore scuro)
    
    % Slice con area massima di TUTTO il tumore
    aree_tumore = squeeze(sum(sum(vol_gt > 0, 1), 2));
    [~, slice_scelta] = max(aree_tumore);
    
    if isempty(slice_scelta) || max(aree_tumore) == 0
        img_2d = []; mask_gt = []; return;
    end
    
    slice_fl = v_fl(:,:,slice_scelta);
    slice_t1 = v_t1(:,:,slice_scelta);
    mask_gt = vol_gt(:,:,slice_scelta) > 0;
    
    % Normalizzazione standard
    mask_brain = slice_fl > 0;
    fl_n = zeros(size(slice_fl)); t1_n = zeros(size(slice_t1));
    if any(mask_brain(:))
        fl_n(mask_brain) = (slice_fl(mask_brain)-min(slice_fl(mask_brain)))/(max(slice_fl(mask_brain))-min(slice_fl(mask_brain)));
        t1_n(mask_brain) = (slice_t1(mask_brain)-min(slice_t1(mask_brain)))/(max(slice_t1(mask_brain))-min(slice_t1(mask_brain)));
    end
    
    % FUSIONE INTELLIGENTE: 
    % Diamo forza alla FLAIR ma usiamo la T1 per "scavare" il cervello sano.
    % Il coefficiente 0.5 sulla T1 evita di cancellare l'edema debole.
    img_fusion = fl_n - (0.5 * t1_n); 
    img_fusion(img_fusion < 0) = 0;
    img_fusion(~mask_brain) = 0;
    
    % Normalizzazione finale per riportare il picco a 1
    if max(img_fusion(:)) > 0
        img_2d = img_fusion / max(img_fusion(:));
    else
        img_2d = img_fusion;
    end
end