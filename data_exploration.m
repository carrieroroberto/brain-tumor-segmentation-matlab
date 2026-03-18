% File: data_exploration.m
% Effettua Exploratory Data Analysis (EDA) sul dataset. Visualizza le 4
% sequenze MRI, i corrispondenti istogrammi e il rendering 3D del volume
% FLAIR.

clear; clc; close all; % rimuove variabili, pulisce la command window e chiude tutte le figure

%% ---------------------------- PARAMETRI ---------------------------------
% identificazione del paziente da analizzare
id = "006"; % ID del paziente
filename = "BRATS_" + id + ".nii.gz"; % nome file NIfTI corrispondente
path_img = "dataset/Task01_BrainTumour/imagesTr/" + filename; % percorso immagini MRI
path_gt  = "dataset/Task01_BrainTumour/labelsTr/" + filename; % percorso ground truth
slice = 78; % slice selezionata per analisi esplorativa

disp("Inizio analisi esplorativa sul paziente: " + filename);

%% -------------------------- CARICAMENTO DATI ----------------------------
% legge il volume 4D delle immagini MRI e le maschere GT, convertendo in double
vol_4d = double(niftiread(path_img)); % dimensione: [H x W x slices x 4 sequenze]
vol_gt = double(niftiread(path_gt)); % ground truth tumorale

%% ----------------- ESTRAZIONE SLICE E SEQUENZA MRI ---------------------
% seleziona la slice di interesse per ciascuna sequenza
img_fl  = vol_4d(:,:,slice,1); % flair
img_t1  = vol_4d(:,:,slice,2); % t1
img_t1c = vol_4d(:,:,slice,3); % t1 con contrasto
img_t2  = vol_4d(:,:,slice,4); % t2

% maschera del cervello: esclude lo sfondo nero per gli istogrammi
brain_mask = img_fl > 0; % logico 1 per pixel cerebrali, 0 per sfondo

%% ---------------------- PLOT 1: SEQUENZA + ISTOGRAMMI ----------------
fig1 = figure("Name", "Analisi Sequenze MRI"); % crea nuova figura

% cell array per iterare sulle immagini
imgs = {img_fl, img_t1, img_t1c, img_t2}; % ogni cella contiene una slice
titles = ["FLAIR", "T1", "T1c", "T2"]; % titoli corrispondenti

for i = 1:4
    % sottoplot riga 1: immagini MRI
    subplot(2, 4, i); % organizza figure in 2 righe x 4 colonne
    imshow(mat2gray(imgs{i})); % normalizza la slice tra 0 e 1 per visualizzazione
    title(titles(i)); % imposta titolo della sequenza
    
    % sottoplot riga 2: istogramma intensità pixel
    subplot(2, 4, i + 4);
    data = imgs{i}(brain_mask); % considera solo pixel > 0 (tessuto cerebrale)
    
    histogram(data); % costruisce istogramma
    xlabel("Intensità"); % etichetta asse X
    ylabel("Numero Pixel"); % etichetta asse Y
end

% titolo globale della figura
sgtitle("Analisi Sequenze MRI - Paziente: " + filename);

%% -------------------------- PLOT 2: VOLUME 3D ---------------------------
% visualizzazione rendering 3D
volshow(vol_4d(:,:,:,1));

disp("Analisi esplorativa completata.");