%% Segmentazione di Tumori Cerebrali in MRI: Analisi Comparativa tra Approcci a Sequenza Singola e Multi-Sequenza
% Studente: Roberto Carriero - Matricola: 601240
% Esame: Image Processing - A.A. 2025/2026
%
% File: main.m
% Script principale che gestisce l'intera pipeline di segmentazione.
% Esegue l'elaborazione su tutti i pazienti, coordinando pre-processing, 
% segmentazione, calcolo delle metriche e generazione dei report grafici.

clear; clc; close all; % pulizia workspace, command window e figure
warning("off", "all"); % disabilita i warning di sistema per pulizia command window
addpath("src"); % aggiunge la cartella contenente le funzioni custom al progetto

% definizione dei percorsi contenenti i volumi e le ground truth
img_dir = "dataset/Task01_BrainTumour/imagesTr/";
gt_dir = "dataset/Task01_BrainTumour/labelsTr/";
files = dir(img_dir + "*.nii.gz");
num_files = length(files);

% array di struct per il salvataggio delle metriche numeriche
metrics(num_files) = struct( ...
    "paziente", "", "flair_dice", 0, "flair_sens", 0, "flair_prec", 0, ...
    "t1c_dice", 0, "t1c_sens", 0, "t1c_prec", 0, "t2_dice", 0, "t2_sens", 0, "t2_prec", 0, ...
    "fus2_dice", 0, "fus2_sens", 0, "fus2_prec", 0, "fus3_dice", 0, "fus3_sens", 0, "fus3_prec", 0 ...
);

disp("======================================== AVVIO ANALISI COMPARATIVA =========================================");
for i = 1:num_files
    % impostazione dei percorsi specifici per il paziente corrente
    filename = files(i).name;
    file_dir = "results/plots/" + filename + "/";
    path_img = img_dir + filename;
    path_gt = gt_dir + filename;
    metrics(i).paziente = filename;
    
    % fase 1: pre-processing (estrazione slice, normalizzazione, filtraggio e fusione multimodale)
    [imgs_proc, gt_mask, seed_map] = pre_processing(path_img, path_gt, filename);
    
    % fase 2: segmentazione per ciascuna delle 5 configurazioni
    flair_mask = segmentation(imgs_proc.flair, seed_map, "FLAIR", filename);
    t1c_mask = segmentation(imgs_proc.t1c, seed_map, "T1c", filename);
    t2_mask = segmentation(imgs_proc.t2, seed_map, "T2", filename);
    fus2_mask = segmentation(imgs_proc.fus2, seed_map, "Fusion2", filename);
    fus3_mask = segmentation(imgs_proc.fus3, seed_map, "Fusion3", filename);
    
    % fase 3: valutazione quantitativa delle predizioni rispetto alla ground truth
    [flair_dice, flair_sens, flair_prec] = evaluation(flair_mask, gt_mask);
    [t1c_dice, t1c_sens, t1c_prec] = evaluation(t1c_mask, gt_mask);
    [t2_dice, t2_sens, t2_prec] = evaluation(t2_mask, gt_mask);
    [fus2_dice, fus2_sens, fus2_prec] = evaluation(fus2_mask, gt_mask);
    [fus3_dice, fus3_sens, fus3_prec] = evaluation(fus3_mask, gt_mask);
    
    % archiviazione delle metriche calcolate all'interno della struct
    % FLAIR
    metrics(i).flair_dice = flair_dice;
    metrics(i).flair_sens = flair_sens;
    metrics(i).flair_prec = flair_prec;
    
    % T1c
    metrics(i).t1c_dice = t1c_dice;
    metrics(i).t1c_sens = t1c_sens;
    metrics(i).t1c_prec = t1c_prec;
    
    % T2
    metrics(i).t2_dice = t2_dice;
    metrics(i).t2_sens = t2_sens;
    metrics(i).t2_prec = t2_prec;
    
    % Fusion2 (FLAIR+T1c)
    metrics(i).fus2_dice = fus2_dice;
    metrics(i).fus2_sens = fus2_sens;
    metrics(i).fus2_prec = fus2_prec;
    
    % Fusion3 (FLAIR+T1c+T2)
    metrics(i).fus3_dice = fus3_dice;
    metrics(i).fus3_sens = fus3_sens;
    metrics(i).fus3_prec = fus3_prec;
    
    % stampa nella command window dell'avanzamento dell'elaborazione
    fprintf("[%03d/%03d] %s -> Dice = FLAIR: %.3f | T1c: %.3f | T2: %.3f | Fus2: %.3f | Fus3: %.3f\n", ...
        i, num_files, filename, flair_dice, t1c_dice, t2_dice, fus2_dice, fus3_dice);
    
    % fase 4: generazione e salvataggio del plot comparativo finale
    masks = {flair_mask, t1c_mask, t2_mask, fus2_mask, fus3_mask};
    imgs = {imgs_proc.t1, imgs_proc.flair, imgs_proc.t1c, imgs_proc.t2, imgs_proc.fus2, imgs_proc.fus3};
    titles = ["Ground Truth (su T1)", ...
              sprintf("Solo FLAIR - Dice: %.3f", flair_dice), ...
              sprintf("Solo T1c - Dice: %.3f", t1c_dice), ...
              sprintf("Solo T2 - Dice: %.3f", t2_dice), ...
              sprintf("Fus2 (FLAIR+T1c) - Dice: %.3f", fus2_dice), ...
              sprintf("Fus3 (FLAIR+T1c+T2) - Dice: %.3f", fus3_dice)
             ];
    
    % inizializzazione della figura (non visibile) per il rendering
    fig = figure("Visible", "off");
    for j = 1:6
        % posizionamento e rendering del subplot corrente
        subplot(2, 3, j);
        imshow(imgs{j}, []);
        hold on;
        title(titles(j));
        
        % overlay dei contorni della ground truth (colore verde)
        h_gt = visboundaries(gt_mask, "Color", "g");
        
        % aggiunta dell'overlay dei contorni predetti (colore rosso) per i subplot non-GT
        if j > 1
            h_pr = visboundaries(masks{j-1}, "Color", "r");
            
            % inserimento della legenda globale in basso a destra solo nell'ultimo subplot
            if j == 6
                lg = legend([h_gt h_pr], ["Ground Truth", "Predizione"], "Location", "southeast");
                lg.Position(2) = 0.03;
            end
        end
    end
    
    % inserimento del titolo e chiusura della figura
    sgtitle("Confronto Risultati Segmentazione - Paziente: " + filename);
    saveas(fig, file_dir + "comparison_results.png");
    close(fig);
    
    fprintf("Elaborazione terminata, figure salvate.\n\n");
end

% fase 5: esportazione dei risultati numerici in file csv
csv_detailed = fopen("results/metrics/detailed.csv", "w");
fprintf(csv_detailed, "filename,flair_dice,flair_sens,flair_prec,t1c_dice,t1c_sens,t1c_prec,t2_dice,t2_sens,t2_prec,fus2_dice,fus2_sens,fus2_prec,fus3_dice,fus3_sens,fus3_prec\n");

% scrittura iterativa delle righe del csv per paziente
for i = 1:num_files
    fprintf(csv_detailed, "%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n", ...
        metrics(i).paziente, ...
        metrics(i).flair_dice, metrics(i).flair_sens, metrics(i).flair_prec, ...
        metrics(i).t1c_dice, metrics(i).t1c_sens, metrics(i).t1c_prec, ...
        metrics(i).t2_dice, metrics(i).t2_sens, metrics(i).t2_prec, ...
        metrics(i).fus2_dice, metrics(i).fus2_sens, metrics(i).fus2_prec, ...
        metrics(i).fus3_dice, metrics(i).fus3_sens, metrics(i).fus3_prec);
end
fclose(csv_detailed);

% calcolo delle medie globali su tutto il dataset
mean_flair = [mean([metrics.flair_dice]), mean([metrics.flair_sens]), mean([metrics.flair_prec])];
mean_t1c = [mean([metrics.t1c_dice]), mean([metrics.t1c_sens]), mean([metrics.t1c_prec])];
mean_t2 = [mean([metrics.t2_dice]), mean([metrics.t2_sens]), mean([metrics.t2_prec])];
mean_fus2 = [mean([metrics.fus2_dice]), mean([metrics.fus2_sens]), mean([metrics.fus2_prec])];
mean_fus3 = [mean([metrics.fus3_dice]), mean([metrics.fus3_sens]), mean([metrics.fus3_prec])];

% apertura ed intestazione del file csv per le metriche medie globali
csv_global = fopen("results/metrics/global.csv", "w");
fprintf(csv_global, "seq,dice_avg,sens_avg,prec_avg\n");

% scrittura delle medie calcolate
fprintf(csv_global, "flair,%.3f,%.3f,%.3f\n", mean_flair(1), mean_flair(2), mean_flair(3));
fprintf(csv_global, "t1c,%.3f,%.3f,%.3f\n", mean_t1c(1), mean_t1c(2), mean_t1c(3));
fprintf(csv_global, "t2,%.3f,%.3f,%.3f\n", mean_t2(1), mean_t2(2), mean_t2(3));
fprintf(csv_global, "fus2,%.3f,%.3f,%.3f\n", mean_fus2(1), mean_fus2(2), mean_fus2(3));
fprintf(csv_global, "fus3,%.3f,%.3f,%.3f\n", mean_fus3(1), mean_fus3(2), mean_fus3(3));
fclose(csv_global);

% fase 6: stampa nella command window delle medie finali
disp("=========================================== MEDIA DEI RISULTATI ===========================================");
fprintf("FLAIR                  | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_flair(1), mean_flair(2), mean_flair(3));
fprintf("T1c                    | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_t1c(1), mean_t1c(2), mean_t1c(3));
fprintf("T2                     | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_t2(1), mean_t2(2), mean_t2(3));
fprintf("Fusion2 (FLAIR+T1c)    | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_fus2(1), mean_fus2(2), mean_fus2(3));
fprintf("Fusion3 (FLAIR+T1c+T2) | Dice Score: %.3f | Sensitivity: %.3f | Precision: %.3f\n", mean_fus3(1), mean_fus3(2), mean_fus3(3));

fprintf("\nAnalisi completata, metriche singole e globali salvate.\n\n");