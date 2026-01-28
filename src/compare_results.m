%% COMPARE RESULTS: Raw vs Preprocessed
%  Autore: Roberto Carriero
%  Descrizione: Confronto visivo e statistico tra immagine originale e processata.

clc; clear; close all;

%% 1. CONFIGURAZIONE
% Inserisci qui il nome del file che vuoi controllare
fileName = 'BRATS_020.nii.gz'; 

% Percorsi (Assicurati che siano gli stessi del batch processing)
dirRaw  = '../dataset/Task01_BrainTumour/imagesTr/';
dirPrep = '../dataset/Task01_BrainTumour/processedTr/';

% File path completi
pathRaw  = fullfile(dirRaw, fileName);
pathPrep = fullfile(dirPrep, ['prep_' fileName]);

%% 2. CARICAMENTO DATI
fprintf('Caricamento file: %s ...\n', fileName);

if ~exist(pathRaw, 'file') || ~exist(pathPrep, 'file')
    error('File non trovati! Controlla i percorsi o esegui prima il Batch Processing.');
end

% Carica Originale (4D -> Estrai FLAIR canale 1)
infoRaw = niftiinfo(pathRaw);
V_raw_4D = niftiread(infoRaw);
V_raw = double(V_raw_4D(:,:,:,1)); % Canale 1 = FLAIR

% Carica Processato (3D -> Già FLAIR)
infoPrep = niftiinfo(pathPrep);
V_prep = double(niftiread(infoPrep));

%% 3. VISUALIZZAZIONE SLICE (SPAZIALE)
% Cerchiamo la slice centrale (dove il cervello è più grande)
midSlice = round(size(V_raw, 3) / 2);

% Ruotiamo di 90 gradi per vederli dritti (MATLAB spesso li carica ruotati)
img_raw  = rot90(V_raw(:,:,midSlice));
img_prep = rot90(V_prep(:,:,midSlice));

figure('Name', ['Confronto: ' fileName], 'Color', 'w', 'Position', [100, 100, 1200, 500]);

% A. Immagine Originale
subplot(1, 3, 1);
imshow(img_raw, []); 
title('Originale (Raw FLAIR)');
xlabel('Nota il cranio e il rumore');

% B. Immagine Processata
subplot(1, 3, 2);
imshow(img_prep, []); 
title('Processata (Skull Strip + Bias Corr)');
xlabel('Solo cervello, contrasto uniforme');

% C. Differenza (Cosa abbiamo tolto?)
% Per visualizzarla, dobbiamo scalare l'originale per renderla comparabile
% (Questa è una visualizzazione qualitativa)
subplot(1, 3, 3);
diff = imabsdiff(rescale(img_raw), rescale(img_prep));
imshow(diff, []); 
title('Differenza (Rumore + Cranio)');
colormap(gca, 'jet'); colorbar;

%% 4. ANALISI ISTOGRAMMI (STATISTICA)
% Questo serve per il report - Dimostra la normalizzazione
figure('Name', 'Analisi Istogrammi', 'Color', 'w', 'Position', [100, 100, 1000, 400]);

% Istogramma Raw (escludiamo lo zero perfetto dello sfondo per chiarezza)
subplot(1, 2, 1);
vals_raw = V_raw(V_raw > 0);
histogram(vals_raw, 100, 'FaceColor', 'r');
grid on;
title('Istogramma Originale (Intensità Grezze)');
xlabel('Intensità Pixel'); ylabel('Conteggio');

% Istogramma Processed (Z-Score)
subplot(1, 2, 2);
% Prendiamo solo i valori dentro la maschera (diversi dal background min)
bg_val = min(V_prep(:));
vals_prep = V_prep(V_prep > bg_val + 0.01); 
histogram(vals_prep, 100, 'FaceColor', 'b');
grid on;
title('Istogramma Processato (Z-Score)');
xlabel('Deviazioni Standard (\sigma)'); ylabel('Conteggio');
xlim([-3 5]); % Z-score tipico è tra -3 e +3/5

fprintf('Visualizzazione completata.\n');