clear; clc; close all;
addpath(genpath(pwd));

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
recall_rg_all = zeros(num_pazienti, 1);
prec_rg_all = zeros(num_pazienti, 1);
acc_rg_all = zeros(num_pazienti, 1);

dice_ws_all = zeros(num_pazienti, 1);
recall_ws_all = zeros(num_pazienti, 1);
prec_ws_all = zeros(num_pazienti, 1);
acc_ws_all = zeros(num_pazienti, 1);

valid_count = 0; 

for i = 1:num_pazienti
    base_name = files(i).name;
    fileName = fullfile(img_dir, base_name);
    gtName   = fullfile(gt_dir, base_name);
    
    fprintf("[%d/%d] Elaborazione Fusion: %s... ", i, num_pazienti, base_name);
    
    [img_2d, mask_gt] = data_loader(fileName, gtName);
    
    if isempty(img_2d)
        fprintf("Saltato.\n");
        continue; 
    end
    
    img_median = denoising(img_2d, 'median');
    
    [seed_pt, m_int, m_ext, img_roi] = otsu_initialization(img_median);
    
    active_pixels = img_median(img_median > 0.05);
    if isempty(active_pixels)
        otsu_level = 0.1;
    else
        otsu_level = graythresh(active_pixels);
    end
    
    seed_val = img_median(seed_pt(1), seed_pt(2));
    tolleranza_dinamica = max(0.05, seed_val - otsu_level);
    
    mask_rg_raw = region_growing(img_roi, seed_pt, tolleranza_dinamica);
    mask_ws_raw = marked_watershed(img_roi, m_int, m_ext);
    
    mask_rg_clean = refinement(mask_rg_raw);
    mask_ws_clean = refinement(mask_ws_raw);
    
    stats_rg = evaluation(mask_rg_clean, mask_gt);
    stats_ws = evaluation(mask_ws_clean, mask_gt);
    
    valid_count = valid_count + 1;
    
    dice_rg_all(valid_count)   = stats_rg.dice;
    recall_rg_all(valid_count) = stats_rg.recall;
    prec_rg_all(valid_count)   = stats_rg.precision;
    acc_rg_all(valid_count)    = stats_rg.accuracy;
    
    dice_ws_all(valid_count)   = stats_ws.dice;
    recall_ws_all(valid_count) = stats_ws.recall;
    prec_ws_all(valid_count)   = stats_ws.precision;
    acc_ws_all(valid_count)    = stats_ws.accuracy;
    
    [~, name_temp, ~] = fileparts(base_name); 
    [~, clean_name, ~]  = fileparts(name_temp); 
    save_file = fullfile(out_plot_dir, clean_name + ".png");
    
    plot_manager(img_2d, mask_rg_clean, mask_ws_clean, mask_gt, clean_name, save_file);
    
    fprintf("Analizzato. (Dice RG: %.2f | Precision: %.2f | Recall: %.2f)\n", ...
            stats_rg.dice, stats_rg.precision, stats_rg.recall);
end

dice_rg_all = dice_rg_all(1:valid_count);
recall_rg_all = recall_rg_all(1:valid_count);
prec_rg_all = prec_rg_all(1:valid_count);
acc_rg_all = acc_rg_all(1:valid_count);

dice_ws_all = dice_ws_all(1:valid_count);
recall_ws_all = recall_ws_all(1:valid_count);
prec_ws_all = prec_ws_all(1:valid_count);
acc_ws_all = acc_ws_all(1:valid_count);

fprintf('\n==================================================\n');
fprintf('  RISULTATI GLOBALI DATASET (%d pazienti validi)\n', valid_count);
fprintf('==================================================\n');
fprintf('REGION GROWING (Media):\n');
fprintf('  > Dice Score: %.4f\n', mean(dice_rg_all));
fprintf('  > Precision:  %.4f\n', mean(prec_rg_all));
fprintf('  > Recall:     %.4f\n', mean(recall_rg_all));
fprintf('  > Accuracy:   %.4f\n', mean(acc_rg_all));
fprintf('--------------------------------------------------\n');
fprintf('WATERSHED (Media):\n');
fprintf('  > Dice Score: %.4f\n', mean(dice_ws_all));
fprintf('  > Precision:  %.4f\n', mean(prec_ws_all));
fprintf('  > Recall:     %.4f\n', mean(recall_ws_all));
fprintf('  > Accuracy:   %.4f\n', mean(acc_ws_all));
fprintf('==================================================\n\n');