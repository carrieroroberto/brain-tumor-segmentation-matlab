% File: data_exploration.m
% Esegue l'Exploratory Data Analysis (EDA) su uno specifico paziente.
% Fornisce visualizzazioni delle immagini origiali (prima/dopo enhancement CLAHE)
% e degli istogrammi di intensità.
% Mostra il rendering interattivo del volume 3D e salva le figure generate
% nel percorso dedicato al paziente selezionato.

clear; clc; close all; % pulizia workspace, command window e figure
warning("off", "all"); % disabilita i warning di sistema per mantenere pulito l'output in console

id = "001"; % identificativo del paziente campione per l'analisi
filename = "BRATS_" + id + ".nii.gz";
path_img = "dataset/Task01_BrainTumour/imagesTr/" + filename;
path_gt  = "dataset/Task01_BrainTumour/labelsTr/" + filename;
slice = 78; % slice centrale usata per la visualizzazione
disp("Inizio analisi esplorativa sul paziente: " + filename);

% percorso per il salvataggio delle figure
eda_dir = "results/plots/" + filename + "/data_exploration/";
mkdir(eda_dir);

% lettura dei volumi in formato double
vol_4d = double(niftiread(path_img)); % dimensione: [H x W x slices x 4 canali]
vol_gt = double(niftiread(path_gt));

% estrazione slice e sequenze MRI
img_fl  = vol_4d(:,:,slice,1); % sequenza FLAIR: evidenzia edema
img_t1  = vol_4d(:,:,slice,2); % sequenza T1: dettaglio anatomico base
img_t1c = vol_4d(:,:,slice,3); % sequenza T1c: evidenzia barriera emato-encefalica (core)
img_t2  = vol_4d(:,:,slice,4); % sequenza T2: dettaglio fluidi e confini

% creazione della maschera per l'isolamento del cervello
brain_mask = img_fl > 0;

% figura 1: sequenze originali e relativi istogrammi
imgs = {img_fl, img_t1, img_t1c, img_t2};
titles = ["FLAIR", "T1", "T1c", "T2"];

fig_raw = figure();
for i = 1:4
    img = mat2gray(imgs{i});
    
    % riga superiore: visualizzazione spaziale della risonanza magnetica
    subplot(2, 4, i);
    imshow(img);
    title(titles(i));
    
    % riga inferiore: distribuzione statistica delle intensità dei pixel
    subplot(2, 4, i + 4);
    data = img(brain_mask); % isolamento esclusivo dei pixel appartenenti al cervello
    histogram(data);
    xlabel("Intensità");
    ylabel("Numero Pixel");
end
sgtitle("Analisi Sequenze MRI - Paziente: " + filename);
saveas(fig_raw, eda_dir + "Raw_sequences.png");

fig_clahe = figure();
for i = 1:4
    % applicazione dell'algoritmo CLAHE per l'equalizzazione adattiva dell'istogramma
    img_clahe = adapthisteq(mat2gray(imgs{i}), "ClipLimit", 0.015);
    
    % riga superiore: visualizzazione spaziale della risonanza post-equalizzazione
    subplot(2, 4, i);
    imshow(img_clahe);
    title(titles(i));
    
    % riga inferiore: distribuzione statistica delle intensità post-equalizzazione
    subplot(2, 4, i + 4);
    data = img_clahe(brain_mask);
    histogram(data);
    xlabel("Intensità");
    ylabel("Numero Pixel");
end
sgtitle("Analisi Sequenze MRI (CLAHE) - Paziente: " + filename);
saveas(fig_clahe, eda_dir + "CLAHE_sequences.png");

% figura 2: rendering del volume 3D sulla sequenza FLAIR
volshow(vol_4d(:,:,:,1));

disp("Analisi esplorativa completata.");