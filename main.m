%% Titolo: Segmentazione di Tumori Cerebrali in MRI: Analisi Comparativa tra Approcci a Sequenza Singola e Multi-Sequenze
% Studente: Roberto Carriero - Matricola: 601240
% Esame: Image Processing - A.A. 2025/2026
%
% File: main.m
% Script principale per lo studio comparativo tra singole sequenze MRI (FLAIR, T1c, T2)
% e fusioni multimodali (Fus2, Fus3). L'elaborazione comprende preprocessing,
% segmentazione, calcolo metriche, generazione di report visivi e esportazione
% dei risultati in formato CSV.

clear; clc; close all; % pulisce workspace, command window e figure precedenti

%% ------------------------------ PARAMETRI -------------------------------
img_dir = "dataset/Task01_BrainTumour/imagesTr/"; % cartella contenente le immagini MRI
lbl_dir = "dataset/Task01_BrainTumour/labelsTr/"; % cartella contenente le ground truth
output_path = "results/"; % cartella di output per grafici e CSV

% lista tutti i file NIfTI presenti nella cartella immagini
files = dir(img_dir + "*.nii.gz");
num_files = length(files); % numero totale di file da elaborare

% creazione di un array di struct per memorizzare le metriche di ciascun paziente
metrics(num_files) = struct( ...
    "paziente", "", ...
    "flair_dice", 0, "flair_sens", 0, "flair_prec", 0, ...
    "t1c_dice", 0,   "t1c_sens", 0,  "t1c_prec", 0, ...
    "t2_dice", 0,    "t2_sens", 0,   "t2_prec", 0, ...
    "fus2_dice", 0,  "fus2_sens", 0, "fus2_prec", 0, ...
    "fus3_dice", 0,  "fus3_sens", 0, "fus3_prec", 0);

%% ---------------------- PIPELINE DI ANALISI -----------------------------
disp("======================================== INIZIO STUDIO COMPARATIVO ========================================");

for i = 1:num_files
    % nome e percorso del file corrente
    filename = files(i).name;
    path_img = img_dir + filename;
    path_gt = lbl_dir + filename;
    
    % salva il nome del paziente nella struct
    metrics(i).paziente = filename;

    % preprocessing
    [imgs_proc, mask_gt, seed_map, prep] = pre_processing(path_img, path_gt);
    
    % segmentazione e post-processing
    flair_mask = post_processing(segmentation(imgs_proc.flair, seed_map));
    t1c_mask = post_processing(segmentation(imgs_proc.t1c, seed_map));
    t2_mask = post_processing(segmentation(imgs_proc.t2, seed_map));
    fus2_mask = post_processing(segmentation(imgs_proc.fus2, seed_map));
    fus3_mask = post_processing(segmentation(imgs_proc.fus3, seed_map));

    % calcolo metriche
    [flair_dice, flair_sens, flair_prec] = evaluation(flair_mask, mask_gt);
    [t1c_dice, t1c_sens, t1c_prec] = evaluation(t1c_mask, mask_gt);
    [t2_dice, t2_sens, t2_prec] = evaluation(t2_mask, mask_gt);
    [fus2_dice, fus2_sens, fus2_prec] = evaluation(fus2_mask, mask_gt);
    [fus3_dice, fus3_sens, fus3_prec] = evaluation(fus3_mask, mask_gt);

    % salvataggio metriche flair
    metrics(i).flair_dice = flair_dice;
    metrics(i).flair_sens = flair_sens;
    metrics(i).flair_prec = flair_prec;

    % salvataggio metriche t1c
    metrics(i).t1c_dice = t1c_dice;
    metrics(i).t1c_sens = t1c_sens;
    metrics(i).t1c_prec = t1c_prec;

    % salvataggio metriche t2
    metrics(i).t2_dice = t2_dice;
    metrics(i).t2_sens = t2_sens;
    metrics(i).t2_prec = t2_prec;

    % salvataggio metriche fusion2 (flair+t1c)
    metrics(i).fus2_dice = fus2_dice;
    metrics(i).fus2_sens = fus2_sens;
    metrics(i).fus2_prec = fus2_prec;

    % salvataggio metriche fusion2 (flair+t1c+t2)
    metrics(i).fus3_dice = fus3_dice;
    metrics(i).fus3_sens = fus3_sens;
    metrics(i).fus3_prec = fus3_prec;

    % stampa nel terminale
    fprintf("[%03d/%03d] %s | FLAIR: %.3f | T1c: %.3f | T2: %.3f | FLAIR+T1c: %.3f | FLAIR+T1c+T2: %.3f\n", ...
            i, num_files, filename, flair_dice, t1c_dice, t2_dice, fus2_dice, fus3_dice);

    % generazione report grafico
    save_path_fig = output_path + "plots/" + filename + "_results.png";
    masks_cell = {flair_mask, t1c_mask, t2_mask, fus2_mask, fus3_mask};
    dices_vec  = [flair_dice, t1c_dice, t2_dice, fus2_dice, fus3_dice];
    %plotting(imgs_proc, mask_gt, masks_cell, dices_vec, filename, save_path_fig);
end

fprintf("\nGrafici salvati nella sotto-cartella 'plots'.");

%% ---------------- CALCOLO METRICHE MEDIE ED ESPORTAZIONE ----------------
% esportazione metriche dettagliate per ogni immagine in CSV
csv_detailed = fopen(output_path + "metrics/detailed.csv", "w");
fprintf(csv_detailed, "filename,flair_dice,flair_sens,flair_prec,t1c_dice,t1c_sens,t1c_prec,t2_dice,t2_sens,t2_prec,fus2_dice,fus2_sens,fus2_prec,fus3_dice,fus3_sens,fus3_prec\n");

for i = 1:num_files
    fprintf(csv_detailed, "%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", ...
        metrics(i).paziente, ...
        metrics(i).flair_dice, metrics(i).flair_sens, metrics(i).flair_prec, ...
        metrics(i).t1c_dice,   metrics(i).t1c_sens,   metrics(i).t1c_prec, ...
        metrics(i).t2_dice,    metrics(i).t2_sens,    metrics(i).t2_prec, ...
        metrics(i).fus2_dice,  metrics(i).fus2_sens,  metrics(i).fus2_prec, ...
        metrics(i).fus3_dice,  metrics(i).fus3_sens,  metrics(i).fus3_prec);
end
fclose(csv_detailed);

% calcolo delle medie globali per ciascuna sequenza
mean_flair = [mean([metrics.flair_dice]), mean([metrics.flair_sens]), mean([metrics.flair_prec])];
mean_t1c   = [mean([metrics.t1c_dice]),   mean([metrics.t1c_sens]),   mean([metrics.t1c_prec])];
mean_t2    = [mean([metrics.t2_dice]),    mean([metrics.t2_sens]),    mean([metrics.t2_prec])];
mean_fus2  = [mean([metrics.fus2_dice]),  mean([metrics.fus2_sens]),  mean([metrics.fus2_prec])];
mean_fus3  = [mean([metrics.fus3_dice]),  mean([metrics.fus3_sens]),  mean([metrics.fus3_prec])];

% esportazione medie globali in CSV
csv_global = fopen(output_path + "metrics/global.csv", "w");
fprintf(csv_global, "seq,dice_avg,sens_avg,prec_avg\n");
fprintf(csv_global, "flair,%.3f,%.3f,%.3f\n", mean_flair(1), mean_flair(2), mean_flair(3));
fprintf(csv_global, "t1c,%.3f,%.3f,%.3f\n", mean_t1c(1), mean_t1c(2), mean_t1c(3));
fprintf(csv_global, "t2,%.3f,%.3f,%.3f\n", mean_t2(1), mean_t2(2), mean_t2(3));
fprintf(csv_global, "fus2,%.3f,%.3f,%.3f\n", mean_fus2(1), mean_fus2(2), mean_fus2(3));
fprintf(csv_global, "fus3,%.3f,%.3f,%.3f\n", mean_fus3(1), mean_fus3(2), mean_fus3(3));
fclose(csv_global);

fprintf("\nMetriche globali e per paziente salvate nella sotto-cartella 'metrics'.\n\n");

% stampa riepilogativa delle medie
disp("=========================================== MEDIA DEI RISULTATI ===========================================");
fprintf("FLAIR                  | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_flair(1), mean_flair(2), mean_flair(3));
fprintf("T1c                    | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_t1c(1), mean_t1c(2), mean_t1c(3));
fprintf("T2                     | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_t2(1), mean_t2(2), mean_t2(3));
fprintf("Fusion2 (FLAIR+T1c)    | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_fus2(1), mean_fus2(2), mean_fus2(3));
fprintf("Fusion3 (FLAIR+T1c+T2) | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_fus3(1), mean_fus3(2), mean_fus3(3));