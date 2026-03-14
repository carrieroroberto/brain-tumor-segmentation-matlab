%% MAIN PIPELINE: Brain Tumor Segmentation (BraTS Dataset)
% Autore: AI Collaborator & You
% Descrizione: Segmentazione automatica di edema/tumore su sequenze FLAIR
% tramite approcci per similarità (Region Growing) e topografici (Watershed).

clear; clc; close all;

% Aggiunta automatica di tutte le sottocartelle al path di MATLAB
addpath(genpath(pwd)); 

disp("--- INIZIALIZZAZIONE PIPELINE ---");

%% 0. CARICAMENTO DEI DATI
fprintf("0. Caricamento dati in corso...\n");
fileName = "dataset/Task01_BrainTumour/imagesTr/BRATS_001.nii.gz";
gtName   = "dataset/Task01_BrainTumour/labelsTr/BRATS_001.nii.gz"; % Percorso Ground Truth

vol = double(niftiread(fileName));
vol_gt = double(niftiread(gtName));

% Estrazione slice centrale e canale FLAIR (4)
[~, ~, num_slices, ~] = size(vol);
slice_centrale = round(num_slices / 2);

img_flair = vol(:, :, slice_centrale, 4);
img_gt    = vol_gt(:, :, slice_centrale); % Maschera reale del medico

% Normalizzazione min-max in [0, 1]
img_norm = (img_flair - min(img_flair(:))) / (max(img_flair(:)) - min(img_flair(:)));

% Trasformazione GT in binario (Whole Tumor: etichette 1, 2 e 3)
mask_gt = img_gt > 0;


%% 1. FASE DI PRE-PROCESSING
fprintf("1. Esecuzione Pre-processing...\n");

% A. Confronto Denoising (Gaussiano vs Mediano)
img_gaussian = denoising(img_norm, 'gaussian');
img_median   = denoising(img_norm, 'median');

% B. Enhancement (CLAHE sul risultato del Mediano)
img_clahe = enhancement(img_median, 0.015);

% --- DASHBOARD FASE 1 ---
figure("Name", "Analisi Fase 1: Pre-Processing", "Position", [100, 100, 1400, 800]);
subplot(2,3,1); imshow(img_norm, []); title("1. Originale");
subplot(2,3,2); imshow(img_gaussian, []); title("2. Gaussiano (Sfoca i bordi)");
subplot(2,3,3); imshow(img_median, []); title("3. Mediano (Preserva i bordi - SCELTO)");
subplot(2,3,4); 
hist_med = img_median(img_median > 0.05);
histogram(hist_med, 100, 'FaceColor', '#0072BD'); title("Istogramma Post-Mediano");
subplot(2,3,5); imshow(img_clahe, []); title("4. Enhancement (CLAHE)");
subplot(2,3,6); 
hist_clahe = img_clahe(img_clahe > 0.05);
histogram(hist_clahe, 100, 'FaceColor', '#D95319'); title("Istogramma Post-CLAHE");


%% 2. FASE DI SEGMENTAZIONE (LOGICA OTSU)
fprintf("2. Segmentazione in corso (Otsu-driven)...\n");

% 2.1 Inizializzazione automatica Marker e Seed tramite Otsu
% Usiamo img_median per mantenere il miglior gradiente possibile
[seed_pt, marker_int, marker_ext] = otsu_initialization(img_median);

% 2.2 Seeded Region Growing (Approccio per Similarità)
mask_rg_raw = region_growing(img_median, seed_pt);

% 2.3 Marker-Controlled Watershed (Approccio Topografico)
mask_ws_raw = marked_watershed(img_median, marker_int, marker_ext);


%% 3. FASE DI POST-PROCESSING (RIFINITURA MORFOLOGICA)
fprintf("3. Rifinitura maschere...\n");

mask_rg_clean = refinement(mask_rg_raw);
mask_ws_clean = refinement(mask_ws_raw);


%% 4. VALUTAZIONE E CONFRONTO METRICHE
fprintf("4. Calcolo metriche di validazione (Dice Coefficient)...\n");

% Calcolo statistiche tramite evaluation.m
stats_rg = evaluation(mask_rg_clean, mask_gt);
stats_ws = evaluation(mask_ws_clean, mask_gt);

% --- REPORT IN CONSOLE ---
fprintf(['\n', repmat('=',1,40), '\n']);
fprintf('       RISULTATI CLINICI (Dice)\n');
fprintf([repmat('=',1,40), '\n']);
fprintf('FILE: %s | SLICE: %d\n', "BRATS_001", slice_centrale);
fprintf([repmat('-',1,40), '\n']);
fprintf('REGION GROWING:\n');
fprintf('  > Dice Score:  %.4f\n', stats_rg.dice);
fprintf('  > Sensitivity: %.4f\n', stats_rg.sensitivity);
fprintf([repmat('-',1,40), '\n']);
fprintf('WATERSHED:\n');
fprintf('  > Dice Score:  %.4f\n', stats_ws.dice);
fprintf('  > Sensitivity: %.4f\n', stats_ws.sensitivity);
fprintf([repmat('=',1,40), '\n\n']);


%% 5. VISUALIZZAZIONE FINALE
fprintf("5. Generazione Dashboard Risultati.\n");

% Dashboard finale sovrapposta
plot_manager(img_norm, mask_rg_clean, mask_ws_clean, mask_gt, "BRATS_001");

disp("--- PIPELINE COMPLETATA CON SUCCESSO ---");