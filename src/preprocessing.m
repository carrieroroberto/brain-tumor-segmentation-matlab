%% DEMO PREPROCESSING STATE-OF-THE-ART (All-in-One)
%  Autore: Roberto Carriero
%  Descrizione: Carica N volumi, applica pipeline ottimizzata (Median + Homomorphic + ZScore)
%               e visualizza il confronto Prima/Dopo.

clc; clear; close all;

%% 1. CONFIGURAZIONE
config.dataDir = '../dataset/Task01_BrainTumour/imagesTr/'; % Percorso dataset
config.numFilesToProcess = 3;  % Quanti pazienti vuoi vedere?
config.visualize = true;       % Vuoi i grafici?

% Parametri "State of the Art"
params.denoising = 'median';   % 'median' (nitido) vs 'gaussian' (sfocato)
params.kernel_size = [3 3];    % Dimensione kernel mediano
params.cutoff_freq = 15;       % Taglio per filtro omomorfico (Bias Field)

%% 2. LOOP DI CARICAMENTO E PROCESSING
% Cerca file validi (ignora i file nascosti ._)
files = dir(fullfile(config.dataDir, '*.nii*'));
validFiles = files(~startsWith({files.name}, '._'));

if isempty(validFiles)
    error('Nessun file trovato in %s', config.dataDir);
end

count = 0;
for i = 1:length(validFiles)
    if count >= config.numFilesToProcess, break; end
    
    fileName = validFiles(i).name;
    fullPath = fullfile(config.dataDir, fileName);
    
    fprintf('\n[%d/%d] Elaborazione: %s ...\n', i, config.numFilesToProcess, fileName);
    
    try
        % --- A. CARICAMENTO ---
        info = niftiinfo(fullPath);
        V_4D = niftiread(info);
        
        % Estrazione FLAIR (Canale 1 nel Medical Decathlon standard)
        % Se i tuoi colori sono invertiti, prova canale 4
        V_raw = double(V_4D(:,:,:,1)); 
        
        % --- B. PREPROCESSING AVANZATO ---
        % Chiama la funzione locale definita in fondo allo script
        [V_prep, mask] = local_preprocess_pipeline(V_raw, params);
        
        % --- C. VISUALIZZAZIONE CONFRONTO ---
        if config.visualize
            show_comparison(V_raw, V_prep, mask, fileName);
        end
        
        count = count + 1;
        
    catch ME
        fprintf('  ERRORE: %s\n', ME.message);
    end
end

fprintf('\nDemo completata.\n');


%% ---------------------------------------------------------
%  LOCAL FUNCTIONS (Tutto incluso in questo file)
%  ---------------------------------------------------------

function [V_out, mask_brain] = local_preprocess_pipeline(V_in, params)
    % Implementazione della pipeline ottimizzata
    
    V_out = zeros(size(V_in));
    mask_brain = false(size(V_in));
    
    % Loop Slice-by-Slice (2D processing)
    for z = 1:size(V_in, 3)
        slice = V_in(:,:,z);
        
        % Saltiamo slice vuote
        if max(slice(:)) == 0, continue; end 
        
        % 1. DENOISING (Median Filter -> Edge Preserving)
        %    Mantiene i bordi nitidi a differenza del Gaussiano
        if strcmp(params.denoising, 'median')
            slice_den = medfilt2(slice, params.kernel_size);
        else
            slice_den = imgaussfilt(slice, 0.5); % Fallback light gaussian
        end
        
        % 2. BIAS FIELD CORRECTION (Homomorphic)
        slice_log = log(slice_den + 1);
        [M, N] = size(slice);
        H = make_homomorphic_filter(M, N, params.cutoff_freq);
        
        F = fftshift(fft2(slice_log));
        slice_homo = real(ifft2(ifftshift(F .* H)));
        slice_corr = exp(slice_homo) - 1;
        
        % 3. MASK REFINEMENT (Assumendo dati pre-stripped)
        %    Soglia minima per rimuovere il 'nero digitale' sporco
        mask = slice_corr > 0.01; 
        mask = imfill(mask, 'holes'); % Riempie ventricoli
        mask = bwareafilt(mask, 1);   % Tiene solo il cervello (rimuove polvere)
        
        mask_brain(:,:,z) = mask;
        
        % 4. NORMALIZZAZIONE Z-SCORE ROBUSTA
        %    Calcolata SOLO sui pixel del cervello
        vals = slice_corr(mask);
        if ~isempty(vals)
            mu = mean(vals);
            sigma = std(vals);
            
            slice_norm = (slice_corr - mu) / (sigma + eps);
            
            % Sfondo pulito al valore minimo
            bg_val = min(slice_norm(mask));
            slice_norm(~mask) = bg_val;
            
            V_out(:,:,z) = slice_norm;
        end
    end
end

function H = make_homomorphic_filter(M, N, D0)
    % Crea filtro Butterworth Passa-Alto
    u = 0:(M-1); v = 0:(N-1);
    idx_u = find(u > M/2); u(idx_u) = u(idx_u) - M;
    idx_v = find(v > N/2); v(idx_v) = v(idx_v) - N;
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);
    
    n = 2;      % Ordine
    gH = 1.2;   % Enfatizza dettagli
    gL = 0.5;   % Attenua bias (basse frequenze)
    
    H = (gH - gL) .* (1 ./ (1 + (D0 ./ (D + eps)).^(2*n))) + gL;
end

function show_comparison(V_raw, V_prep, mask, titleStr)
    % Visualizza slice centrale e istogrammi (VERSIONE CORRETTA)
    mid = round(size(V_raw, 3) / 2);
    
    % 1. Estraiamo le slice 2D SPECIFICHE (Fondamentale!)
    slice_raw  = V_raw(:,:,mid);
    slice_prep = V_prep(:,:,mid);
    slice_mask = mask(:,:,mid);
    
    % Ruota per visualizzazione (solo per le immagini)
    img_raw  = rot90(slice_raw);
    img_prep = rot90(slice_prep);
    
    figure('Name', ['Analisi: ' titleStr], 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.2 0.8 0.5]);
    
    % A. Immagini
    subplot(2,3,1); imshow(img_raw, []); title('1. Originale (Raw)');
    subplot(2,3,2); imshow(img_prep, []); title('2. Processed (Median+Homo+ZScore)');
    
    % B. Differenza
    subplot(2,3,3); 
    diff = imabsdiff(rescale(img_raw), rescale(img_prep));
    imshow(diff, []); colormap(gca, 'jet'); colorbar; % Cambio colore in JET per vedere meglio
    title('3. Differenza (Rumore rimosso)');
    
    % C. Istogrammi (ORA CORRETTI)
    subplot(2,3,4); 
    % Prende i pixel SOLO dalla slice corrente dove la maschera è vera
    vals = slice_raw(slice_mask); 
    histogram(vals, 100, 'FaceColor', 'r', 'EdgeColor', 'none'); 
    title('Istogramma Raw (Intensità Reali)'); grid on; axis tight;
    
    subplot(2,3,5); 
    vals_p = slice_prep(slice_mask);
    histogram(vals_p, 100, 'FaceColor', 'b', 'EdgeColor', 'none'); 
    title('Istogramma Z-Score (Deve essere centrato)'); grid on; 
    xlim([-4 4]); % Z-score tipico
    
    % D. Info
    subplot(2,3,6); axis off;
    text(0, 0.6, {'PIPELINE INFO:', ...
                  '- Denoising: Median Filter [3x3]', ...
                  '- Bias Corr: Homomorphic', ...
                  '- Norm: Z-Score'}, 'FontSize', 12);
    drawnow;
end