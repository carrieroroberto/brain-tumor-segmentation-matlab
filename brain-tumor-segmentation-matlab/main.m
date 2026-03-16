% =========================================================================
% PROGETTO DI IMAGE PROCESSING (6 CFU) - SEGMENTAZIONE TUMORI CEREBRALI
% Pipeline State-of-the-Art: Region Growing vs Marker-Controlled Watershed
% =========================================================================
clear; clc; close all;

img_dir = 'dataset/Task01_BrainTumour/imagesTr/';
lbl_dir = 'dataset/Task01_BrainTumour/labelsTr/';
output_path = 'results/';

if ~exist(output_path, 'dir'), mkdir(output_path); end

files = dir(fullfile(img_dir, '*.nii.gz'));
num_files = length(files);

if num_files == 0
    error('Nessun file trovato. Controlla il percorso: %s', img_dir);
end

% Inizializzazione Array Metriche
metrics = struct('dice_rg', zeros(num_files,1), 'sens_rg', zeros(num_files,1), 'prec_rg', zeros(num_files,1), ...
                 'dice_ws', zeros(num_files,1), 'sens_ws', zeros(num_files,1), 'prec_ws', zeros(num_files,1));

fprintf('=== AVVIO PIPELINE DI ELABORAZIONE AVANZATA ===\n');

for i = 1:num_files
    try
        name_img = fullfile(img_dir, files(i).name);
        name_gt  = fullfile(lbl_dir, files(i).name); 
        clean_name = strrep(files(i).name, '.nii.gz', '');

        % MODULO 1: Preprocessing Aggressivo
        [I_proc, mask_gt, I_orig, I_seed_map, prep_steps] = preprocessing(name_img, name_gt);

        % MODULO 2: Segmentazione (Otsu -> Custom RG -> WS)
        [mask_rg_raw, mask_ws_raw] = segmentation(I_proc, I_seed_map);

        % MODULO 3: Postprocessing Morfologico
        mask_rg = postprocessing(mask_rg_raw);
        mask_ws = postprocessing(mask_ws_raw);

        % MODULO 4: Calcolo Metriche (Dice, Sensitivity/Recall, Precision)
        % Metriche Region Growing
        TP_rg = sum(mask_rg(:) & mask_gt(:));
        FP_rg = sum(mask_rg(:) & ~mask_gt(:));
        FN_rg = sum(~mask_rg(:) & mask_gt(:));
        
        metrics.dice_rg(i) = (2 * TP_rg) / (2 * TP_rg + FP_rg + FN_rg + eps);
        metrics.sens_rg(i) = TP_rg / (TP_rg + FN_rg + eps);
        metrics.prec_rg(i) = TP_rg / (TP_rg + FP_rg + eps);

        % Metriche Watershed
        TP_ws = sum(mask_ws(:) & mask_gt(:));
        FP_ws = sum(mask_ws(:) & ~mask_gt(:));
        FN_ws = sum(~mask_ws(:) & mask_gt(:));
        
        metrics.dice_ws(i) = (2 * TP_ws) / (2 * TP_ws + FP_ws + FN_ws + eps);
        metrics.sens_ws(i) = TP_ws / (TP_ws + FN_ws + eps);
        metrics.prec_ws(i) = TP_ws / (TP_ws + FP_ws + eps);

        % Stampa a schermo per singolo paziente
        fprintf('[%d/%d] %s | RG -> Dice: %.3f, Sens: %.3f, Prec: %.3f | WS -> Dice: %.3f\n', ...
            i, num_files, clean_name, metrics.dice_rg(i), metrics.sens_rg(i), metrics.prec_rg(i), metrics.dice_ws(i));

        % MODULO 5: Plotting (Salva le immagini per TUTTI i pazienti per analisi robusta)
        %save_file = fullfile(output_path, sprintf('%s_analysis.png', clean_name));
        %plotting(I_orig, mask_gt, mask_rg, mask_ws, metrics.dice_rg(i), metrics.dice_ws(i), prep_steps, clean_name, save_file);

    catch ME
        fprintf('[%d/%d] ERRORE su %s: %s\n', i, num_files, files(i).name, ME.message);
    end
end

% Stampa Statistiche Finali
fprintf('\n================ RISULTATI GLOBALI ================\n');
fprintf('REGION GROWING (Custom):\n');
fprintf(' - Dice Score Medio:  %.4f\n', mean(metrics.dice_rg, 'omitnan'));
fprintf(' - Sensitivity Media: %.4f\n', mean(metrics.sens_rg, 'omitnan'));
fprintf(' - Precision Media:   %.4f\n', mean(metrics.prec_rg, 'omitnan'));
fprintf('---------------------------------------------------\n');
fprintf('WATERSHED (Marker-Controlled):\n');
fprintf(' - Dice Score Medio:  %.4f\n', mean(metrics.dice_ws, 'omitnan'));
fprintf(' - Sensitivity Media: %.4f\n', mean(metrics.sens_ws, 'omitnan'));
fprintf(' - Precision Media:   %.4f\n', mean(metrics.prec_ws, 'omitnan'));
fprintf('===================================================\n');

% Salvataggio vettori nel workspace
%save(fullfile(output_path, 'risultati_finali.mat'), 'metrics');