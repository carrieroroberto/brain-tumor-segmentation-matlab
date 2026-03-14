clear; clc; close all;

img_dir = "dataset/Task01_BrainTumour/imagesTr/";
gt_dir  = "dataset/Task01_BrainTumour/labelsTr/";
out_plot_dir = "results/plots/";

if ~exist(out_plot_dir, 'dir')
    mkdir(out_plot_dir);
end

files = dir(fullfile(img_dir, "BRATS_*.nii.gz"));
num_pazienti = length(files);

if num_pazienti == 0
    error("Nessun file trovato.");
end

dice_rg_all = zeros(num_pazienti, 1);
sens_rg_all = zeros(num_pazienti, 1);
dice_ws_all = zeros(num_pazienti, 1);
sens_ws_all = zeros(num_pazienti, 1);
valid_count = 0; 

for i = 1:num_pazienti
    base_name = files(i).name;
    fileName = fullfile(img_dir, base_name);
    gtName   = fullfile(gt_dir, base_name);
    
    fprintf("[%d/%d] Elaborazione: %s... ", i, num_pazienti, base_name);
    
    try
        vol = double(niftiread(fileName));
        vol_gt = double(niftiread(gtName));
        
        aree_tumore_per_slice = squeeze(sum(sum(vol_gt > 0, 1), 2));
        [max_area, slice_scelta] = max(aree_tumore_per_slice);
        
        if max_area == 0
            fprintf("Saltato.\n");
            continue; 
        end
        
        img_flair = vol(:, :, slice_scelta, 4);
        img_gt    = vol_gt(:, :, slice_scelta);
        mask_gt   = img_gt > 0;
        
        brain_mask = img_flair > 0; 
        img_norm = zeros(size(img_flair));
        
        min_val = min(img_flair(brain_mask));
        max_val = max(img_flair(brain_mask));
        
        if max_val > min_val
            img_norm(brain_mask) = (img_flair(brain_mask) - min_val) / (max_val - min_val);
        end
        
        img_median = denoising(img_norm, 'median');
        
        [seed_pt, m_int, m_ext, img_roi] = otsu_initialization(img_median);
        
        pixel_tumore = img_roi(m_int > 0);
        std_tumore = std(pixel_tumore);
        tolleranza_dinamica = max(3.5 * std_tumore, 0.05);
        
        mask_rg_raw = region_growing(img_roi, seed_pt, tolleranza_dinamica);
        mask_ws_raw = marked_watershed(img_roi, m_int, m_ext);
        
        mask_rg_clean = refinement(mask_rg_raw);
        mask_ws_clean = refinement(mask_ws_raw);
        
        stats_rg = evaluation(mask_rg_clean, mask_gt);
        stats_ws = evaluation(mask_ws_clean, mask_gt);
        
        valid_count = valid_count + 1;
        dice_rg_all(valid_count) = stats_rg.dice;
        sens_rg_all(valid_count) = stats_rg.sensitivity;
        dice_ws_all(valid_count) = stats_ws.dice;
        sens_ws_all(valid_count) = stats_ws.sensitivity;
        
        [~, name_temp, ~] = fileparts(base_name); 
        [~, clean_name, ~]  = fileparts(name_temp); 
        save_file = fullfile(out_plot_dir, clean_name + ".png");
        
        plot_manager(img_norm, mask_rg_clean, mask_ws_clean, mask_gt, clean_name, save_file);
        
        fprintf("Analizzato. (Dice RG: %.2f | WS: %.2f)\n", stats_rg.dice, stats_ws.dice);
        
    catch ME
        fprintf("ERRORE: %s\n", ME.message);
    end
end

dice_rg_all = dice_rg_all(1:valid_count);
sens_rg_all = sens_rg_all(1:valid_count);
dice_ws_all = dice_ws_all(1:valid_count);
sens_ws_all = sens_ws_all(1:valid_count);

mean_dice_rg = mean(dice_rg_all);
mean_sens_rg = mean(sens_rg_all);
mean_dice_ws = mean(dice_ws_all);
mean_sens_ws = mean(sens_ws_all);

fprintf('\n==================================================\n');
fprintf('  RISULTATI GLOBALI DATASET (%d pazienti validi)\n', valid_count);
fprintf('==================================================\n');
fprintf('REGION GROWING (Media):\n');
fprintf('  > Dice Score:  %.4f\n', mean_dice_rg);
fprintf('  > Sensitivity: %.4f\n', mean_sens_rg);
fprintf('--------------------------------------------------\n');
fprintf('WATERSHED (Media):\n');
fprintf('  > Dice Score:  %.4f\n', mean_dice_ws);
fprintf('  > Sensitivity: %.4f\n', mean_sens_ws);
fprintf('==================================================\n\n');