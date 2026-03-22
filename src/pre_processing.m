function [imgs_proc, mask_gt, seed_map] = pre_processing(path_img, path_gt)
% File: pre_processing.m
% Estrae la slice ottimale dalla MRI e genera 5 configurazioni per lo studio comparativo.
% Include normalizzazione z-score, filtro mediano e CLAHE.
%
% INPUT:
% path_img - percorso al file NIfTI delle immagini MRI
% path_gt - percorso al file NIfTI della ground truth
%
% OUTPUT:
% imgs_proc - struct contenente le immagini preprocessate per FLAIR, T1, T1c, T2, Fus2 e Fus3
% mask_gt - maschera binaria della ground truth
% seed_map - mappa dei semi sfocata (gaussian smoothing) per region growing

    % lettura dei volumi
    vol_4d = double(niftiread(path_img));
    vol_gt = double(niftiread(path_gt));

    % estrazione della slice ottimale (quella con più pixel positivi nella ground truth)
    slice_scores = squeeze(sum(sum(vol_gt > 0, 1), 2));
    [~, z_best] = max(slice_scores);

    img_fl = vol_4d(:,:,z_best,1); % flair
    img_t1 = vol_4d(:,:,z_best,2); % t1
    img_t1c = vol_4d(:,:,z_best,3); % t1c
    img_t2 = vol_4d(:,:,z_best,4); %t2
    mask_gt = vol_gt(:,:,z_best) > 0;

    % creazione maschera del tessuto cerebrale
    mask_brain = img_fl > 0; % pixel non nulli
    mask_brain = imfill(mask_brain, "holes"); % riempie eventuali buchi

    % normalizzazione z-score per canale (solo tessuto cerebrale)
    img_fl(mask_brain) = (img_fl(mask_brain) - mean(img_fl(mask_brain))) / std(img_fl(mask_brain));
    img_t1(mask_brain) = (img_t1(mask_brain) - mean(img_t1(mask_brain))) / std(img_t1(mask_brain));
    img_t1c(mask_brain) = (img_t1c(mask_brain) - mean(img_t1c(mask_brain))) / std(img_t1c(mask_brain));
    img_t2(mask_brain) = (img_t2(mask_brain) - mean(img_t2(mask_brain))) / std(img_t2(mask_brain));

    % scaling lineare tra 0 e 1
    img_fl(~mask_brain) = 0;
    img_t1(~mask_brain) = 0;
    img_t1c(~mask_brain) = 0;
    img_t2(~mask_brain) = 0;

    img_fl = mat2gray(img_fl);
    img_t1 = mat2gray(img_t1);
    img_t1c = mat2gray(img_t1c);
    img_t2 = mat2gray(img_t2);

    % filtro mediano per preservare i bordi e contrast enhancement per
    % sequenza
    img_fl = medfilt2(img_fl, [3 3]);
    img_fl = adapthisteq(img_fl, "ClipLimit", 0.015);

    img_t1 = medfilt2(img_t1, [3 3]);
    img_t1 = adapthisteq(img_t1, "ClipLimit", 0.015);

    img_t1c = medfilt2(img_t1c, [3 3]);
    img_t1c = adapthisteq(img_t1c, "ClipLimit", 0.015);

    img_t2 = medfilt2(img_t2, [3 3]);
    img_t2 = adapthisteq(img_t2, "ClipLimit", 0.015);

    % generazione configurazioni per l'analisi
    imgs_proc.flair = img_fl;
    imgs_proc.t1 = img_t1;
    imgs_proc.t1c = img_t1c;
    imgs_proc.t2 = img_t2;
    imgs_proc.fus2 = 0.6*img_fl + 0.4*img_t1c; % fusione bimodale
    imgs_proc.fus3 = 0.54*img_fl + 0.16*img_t1c + 0.30*img_t2; % fusione multimodale

    % generazione della seed map per il region growing
    % sfocatura gaussiana per facilitare l'individuazione del seme
    seed_map = imgaussfilt(imgs_proc.fus3, 3);

end