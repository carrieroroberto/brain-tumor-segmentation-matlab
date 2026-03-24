function [imgs_proc, mask_gt, seed_map] = pre_processing(path_img, path_gt, filename)
% File: pre_processing.m
% Esegue il pre-processing delle sequenze MRI: estra la slice più rilevante,
% applica la normalizzazione z-score, riduce il rumore con filtro mediano,
% genera le fusioni multimodali e crea la seed map per facilitare la
% segmentazione.
%
% INPUT:
% path_img - percorso al volume NIfTI
% path_gt - percorso alla ground truth
% filename - identificativo del paziente
%
% OUTPUT:
% imgs_proc - struct contenente le immagini preprocessate
% mask_gt - maschera ground truth della slice selezionata
% seed_map - mappa di probabilità sfocata per Region Growing

    % creazione del percorso di destinazione per il salvataggio dei grafici
    pre_processing_dir = "results/plots/" + filename + "/pre_processing/";
    mkdir(pre_processing_dir);
    
    % lettura dei volumi e conversione in formato double
    vol_4d = double(niftiread(path_img));
    vol_gt = double(niftiread(path_gt));
    
    % calcolo dell'estensione del tumore per ogni slice e selezione di
    % quella migliore
    slice_scores = squeeze(sum(sum(vol_gt > 0, 1), 2));
    [~, z_best] = max(slice_scores);
    
    % estrazione delle singole sequenze dalla slice con maggiore area tumorale
    img_fl = vol_4d(:,:, z_best, 1);   % FLAIR
    img_t1 = vol_4d(:,:, z_best, 2);   % T1
    img_t1c = vol_4d(:,:, z_best, 3);  % T1c
    img_t2 = vol_4d(:,:, z_best, 4);   % T2
    mask_gt = vol_gt(:,:, z_best) > 0; % maschera GT binaria
    
    % estrazione della maschera cerebrale dalla sequenza FLAIR
    mask_brain = imfill(img_fl > 0, "holes");
    
    % normalizzazione z-score applicata esclusivamente ai pixel appartenenti al cervello
    img_fl(mask_brain) = (img_fl(mask_brain) - mean(img_fl(mask_brain))) / std(img_fl(mask_brain));
    img_t1c(mask_brain) = (img_t1c(mask_brain) - mean(img_t1c(mask_brain))) / std(img_t1c(mask_brain));
    img_t2(mask_brain) = (img_t2(mask_brain) - mean(img_t2(mask_brain))) / std(img_t2(mask_brain));
    
    % soppressione del background azzerando i pixel esterni alla maschera cerebrale
    img_fl(~mask_brain) = 0;
    img_t1c(~mask_brain) = 0;
    img_t2(~mask_brain) = 0;
    img_t1(~mask_brain) = 0;
    
    % mappatura lineare delle intensità nel range [0,1] per le successive operazioni
    img_fl_norm = mat2gray(img_fl);
    img_t1c_norm = mat2gray(img_t1c);
    img_t2_norm = mat2gray(img_t2);
    img_t1_norm = mat2gray(img_t1);
    
    % riduzione del rumore tramite l'applicazione di un filtro mediano con kernel 3x3
    img_fl_filt = medfilt2(img_fl_norm, [3 3]);
    img_t1_filt = medfilt2(img_t1_norm, [3 3]);
    img_t1c_filt = medfilt2(img_t1c_norm, [3 3]);
    img_t2_filt = medfilt2(img_t2_norm, [3 3]);
    
    % archiviazione delle sequenze preprocessate all'interno della struct di output
    imgs_proc.flair = img_fl_filt;
    imgs_proc.t1 = img_t1_filt;
    imgs_proc.t1c = img_t1c_filt;
    imgs_proc.t2 = img_t2_filt;
    
    % calcolo delle fusioni multimodali combinando linearmente le sequenze
    imgs_proc.fus2 = 0.6*img_fl_filt + 0.4*img_t1c_filt; % bimodale
    imgs_proc.fus3 = 0.5*img_fl_filt + 0.2*img_t1c_filt + 0.3*img_t2_filt; % trimodale
    
    % sfocatura della fusione trimodale tramite filtro gaussiano per generare la seed map
    seed_map = imgaussfilt(imgs_proc.fus3, 3);
    
    % inizializzazione della figura (non visibile) per il salvataggio dell'analisi
    fig_raw = figure("Visible", "off");
    imgs = {img_fl, img_t1, img_t1c, img_t2};
    titles = ["FLAIR Originale", "T1 Originale", "T1c Originale", "T2 Originale"];
    
    for k = 1:4
        % riga superiore: visualizzazione dell'immagine grezza
        subplot(2, 4, k);
        imshow(imgs{k});
        title(titles(k));
        
        % riga inferiore: plot della distribuzione delle intensità dei pixel cerebrali
        subplot(2, 4, k+4);
        histogram(imgs{k}(mask_brain));
        xlabel("Intensità");
        ylabel("Conteggio Pixel");
    end
    sgtitle("Analisi Sequenze Grezze - Paziente: " + filename);
    saveas(fig_raw, pre_processing_dir + "raw_histogram.png");
    close(fig_raw);
    
    % esportazione grafica dei vari step di pre-processing per ciascuna sequenza
    plot_pre_step(img_fl, img_fl_norm, img_fl_filt, mask_brain, "FLAIR", filename, pre_processing_dir);
    plot_pre_step(img_t1c, img_t1c_norm, img_t1c_filt, mask_brain, "T1c", filename, pre_processing_dir);
    plot_pre_step(img_t2, img_t2_norm, img_t2_filt, mask_brain, "T2", filename, pre_processing_dir);
    
    % esportazione grafica delle fasi di fusione multimodale
    plot_fus2_step(imgs_proc.flair, imgs_proc.t1c, imgs_proc.fus2, mask_brain, filename, pre_processing_dir);
    plot_fus3_step(imgs_proc.flair, imgs_proc.t1c, imgs_proc.t2, imgs_proc.fus3, mask_brain, filename, pre_processing_dir);
    
    % salvataggio della mappa di probabilità sfocata (seed map)
    fig_seed = figure("Visible", "off");
    imshow(seed_map, []);
    colormap(jet);
    colorbar;
    title("Fusion3 Seed Map (Sfocatura Gaussiana) - Paziente: " + filename);
    saveas(fig_seed, pre_processing_dir + "seed_map.png");
    close(fig_seed);
end

%% Funzioni di plotting ausiliarie

function plot_pre_step(raw, norm, filt, mask, seq, filename, save_path)
% File: plot_pre_step
% visualizza e salva gli step di pre-processing: immagine grezza, dopo
% normalizzazione z-score e dopo denoising con filtro mediano.
%
% INPUT:
% raw - immagine originale
% norm - immagine normalizzata z-score
% filt - immagine filtrata
% mask - maschera del cervello per estrarre l'istogramma
% seq - nome della sequenza MRI
% filename - identificativo del paziente
% save_path - percorso di destinazione per la figura
    fig = figure("Visible", "off");
    imgs = {raw, norm, filt};
    titles = ["Sequenza Grezza", "Normalizzazione Z-Score", "Filtro Rumore Mediano"];
    
    for k = 1:3
        % visualizzazione dell'immagine per lo step corrente
        subplot(2, 3, k);
        imshow(imgs{k});
        title(titles(k));
        
        % calcolo dell'istogramma ristretto ai soli pixel appartenenti al cervello
        subplot(2, 3, k+3);
        histogram(imgs{k}(mask));
        xlabel("Intensità");
    end
    sgtitle("Fasi Pre-Processing " + seq + " - Paziente: " + filename);
    saveas(fig, save_path + seq + "_pre_processing.png");
    close(fig);
end

function plot_fus2_step(fl, t1c, fus, mask, filename, save_path)
% File: plot_fus2_step
% visualizza e salva la generazione della fusione bimodale (FLAIR + T1c).
%
% INPUT:
% fl - immagine FLAIR preprocessata
% t1c - immagine T1c preprocessata
% fus - immagine fusione bimodale (Fusion2)
% mask - maschera del cervello
% filename - identificativo del paziente
% save_path - percorso di destinazione per la figura
    fig = figure("Visible", "off");
    imgs = {fl, t1c, fus};
    titles = ["FLAIR Pre-Processata", "T1c Pre-Processata", "Fusion2 (FLAIR+T1c)"];
    
    for k = 1:3
        % visualizzazione delle sequenze e della fusione risultante
        subplot(2, 3, k);
        imshow(imgs{k});
        title(titles(k));
        
        % calcolo dell'istogramma ristretto ai pixel cerebrali
        subplot(2, 3, k+3);
        histogram(imgs{k}(mask));
        xlabel("Intensità");
    end
    sgtitle("Generazione Fusione Bimodale - Paziente: " + filename);
    saveas(fig, save_path + "Fusion2_pre_processing.png");
    close(fig);
end

function plot_fus3_step(fl, t1c, t2, fus, mask, filename, save_path)
% File: plot_fus3_step
% visualizza e salva la generazione della fusione multimodale (FLAIR + T1c + T2).
%
% INPUT:
% fl - immagine FLAIR preprocessata
% t1c - immagine T1c preprocessata
% t2 - immagine T2 preprocessata
% fus - immagine fusione trimodale (Fusion3)
% mask - maschera del cervello
% filename - identificativo del paziente
% save_path - percorso di destinazione per la figura
    fig = figure("Visible", "off");
    imgs = {fl, t1c, t2, fus};
    titles = ["FLAIR Pre-Processata", "T1c Pre-Processata", "T2 Pre-Processata", "Fusion3 (FLAIR+T1c+T2)"];
    
    for k = 1:4
        % visualizzazione delle sequenze di partenza e della fusione finale
        subplot(2, 4, k);
        imshow(imgs{k});
        title(titles(k));
        
        % andamento della distribuzione delle intensità nell'area cerebrale
        subplot(2, 4, k+4);
        histogram(imgs{k}(mask));
        xlabel("Intensità");
    end
    sgtitle("Generazione Fusione Multimodale - Paziente: " + filename);
    saveas(fig, save_path + "Fusion3_pre_processing.png");
    close(fig);
end