%% MAIN_PROJECT - Brain Tumor Segmentation Pipeline
%  Autore: Roberto Carriero
%  Corso: Image Processing, Poliba
%  Descrizione: Pipeline per confronto tecniche di segmentazione (Thresholding, Region, Edge)
%  e validazione tramite SVM.

clc; clear; close all;
addpath('modules'); % Cartella contenente le funzioni

%% 1. Configurazione
dataDir = './dataset/imagesTr/'; % Percorso dataset Medical Decathlon
resultsDir = './results/';
if ~exist(resultsDir, 'dir'), mkdir(resultsDir); end

% Selezione parametri 
params.denoisingMethod = 'gaussian'; % 'gaussian' o 'median'
params.segMethod = 'region_growing'; % 'otsu', 'region_growing', 'canny'
params.visualize = true; % Flag per visualizzare i risultati intermedi

%% 2. Caricamento e Processing dei Volumi
files = dir(fullfile(dataDir, '*.nii.gz')); % Assumendo formato NIfTI
numPatients = length(files);
metricsTable = [];

% Esempio: Loop sui primi 5 pazienti per test
for i = 1:min(5, numPatients)
    fprintf('Processing Volume %d/%d: %s...\n', i, numPatients, files(i).name);
    
    % Caricamento Volume (Richiede Medical Imaging Toolbox o niftiread)
    volInfo = niftiinfo(fullfile(dataDir, files(i).name));
    V = niftiread(volInfo);
    
    % Estrazione canali di interesse: FLAIR e T1c 
    % Nota: Nel Decathlon 4D, il canale 4 è solitamente FLAIR (verificare header)
    V_flair = double(V(:,:,:,4)); 
    
    %% 3. Preprocessing 
    % Pipeline: Denoising -> Bias Field (Homomorphic) -> Skull Strip -> Norm
    [V_preproc, mask_brain] = preprocess_pipeline(V_flair, params);
    
    %% 4. Segmentazione 
    % Applica la tecnica scelta (slice-by-slice o volumetrica)
    V_seg = segmentation_pipeline(V_preproc, mask_brain, params.segMethod);
    
    % Post-processing morfologico 
    V_seg = postprocess_morphology(V_seg);
    
    %% 5. Valutazione e Feature Extraction 
    % (Qui assumeremmo di avere la Ground Truth 'GT' caricata dal dataset)
    % GT = double(niftiread(gt_path));
    % scores = calculate_metrics(V_seg, GT);
    % metricsTable = [metricsTable; scores];
    
    %% 6. Visualizzazione (Slice centrale)
    if params.visualize
        midSlice = round(size(V_preproc, 3)/2);
        figure(1); clf;
        subplot(1,3,1); imshow(V_flair(:,:,midSlice), []); title('Originale FLAIR');
        subplot(1,3,2); imshow(V_preproc(:,:,midSlice), []); title('Preprocessato');
        subplot(1,3,3); imshow(V_seg(:,:,midSlice), []); title(['Segmentazione: ' params.segMethod]);
        drawnow;
    end
end

% Salva risultati
save(fullfile(resultsDir, 'metrics_results.mat'), 'metricsTable');
fprintf('Elaborazione completata.\n');