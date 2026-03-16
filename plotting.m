function plotting(I_orig, mask_gt, mask_rg, mask_ws, dice_rg, dice_ws, prep_steps, patient_name, save_path)
    fig = figure('Visible', 'off', 'Position', [100, 100, 1600, 800], 'Color', 'w');
    
    % Auto-Cropping globale basato sulla maschera di GT per avere uno zoom perfetto
    props = regionprops(mask_gt, 'BoundingBox');
    if ~isempty(props)
        bb = props(1).BoundingBox;
        pad = 30;
        x_min = max(1, floor(bb(1)) - pad);
        y_min = max(1, floor(bb(2)) - pad);
        x_max = min(size(I_orig, 2), ceil(bb(1) + bb(3)) + pad);
        y_max = min(size(I_orig, 1), ceil(bb(2) + bb(4)) + pad);
    else
        x_min=1; y_min=1; x_max=size(I_orig,2); y_max=size(I_orig,1);
    end

    % Funzione helper per croppare
    crop = @(img) img(y_min:y_max, x_min:x_max);

    % RIGA 1: PREPROCESSING STEPS
    subplot(2, 4, 1); imshow(crop(prep_steps.raw)); title('1. Raw FLAIR');
    subplot(2, 4, 2); imshow(crop(prep_steps.roi)); title('2. ROI Cropped');
    subplot(2, 4, 3); imshow(crop(prep_steps.fused)); title('3. Multimodal Fusion');
    subplot(2, 4, 4); imshow(crop(prep_steps.enhanced)); title('4. Enhanced & Filtered');

    % RIGA 2: CONFRONTI SEGMENTAZIONE
    c_gt = [0 1 0]; c_pred = [1 0 0]; 
    p_gt = bwperim(crop(mask_gt)); p_rg = bwperim(crop(mask_rg)); p_ws = bwperim(crop(mask_ws));
    img_bg = crop(I_orig);

    subplot(2, 4, 5);
    imshow(img_bg); hold on; visboundaries(p_gt, 'Color', c_gt, 'LineWidth', 1.5);
    title('Ground Truth');

    subplot(2, 4, 6);
    imshow(img_bg); hold on; 
    visboundaries(p_gt, 'Color', c_gt, 'LineWidth', 1); visboundaries(p_rg, 'Color', c_pred, 'LineWidth', 1.5);
    title(sprintf('Region Growing\nDice: %.3f', dice_rg));

    subplot(2, 4, 7);
    imshow(img_bg); hold on; 
    visboundaries(p_gt, 'Color', c_gt, 'LineWidth', 1); visboundaries(p_ws, 'Color', c_pred, 'LineWidth', 1.5);
    title(sprintf('Watershed\nDice: %.3f', dice_ws));

    sgtitle(sprintf('Analisi Paziente: %s', patient_name), 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 16);

    exportgraphics(fig, save_path, 'Resolution', 300);
    close(fig);
end