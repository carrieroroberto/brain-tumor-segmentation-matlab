%% CHECK SKULL STRIPPING STATUS
%  Autore: Roberto Carriero
%  Obiettivo: Verificare se i dati Medical Decathlon sono già "puliti" (skull-stripped)
%  o se è necessario applicare il modulo di skull stripping previsto nella proposta.

clc; clear; close all;

% 1. SELEZIONA FILE
fprintf('Seleziona un file "grezzo" (dalla cartella imagesTr)...\n');
[file, path] = uigetfile({'*.nii;*.nii.gz'}, 'Seleziona Volume MRI');
if isequal(file, 0), return; end

% 2. CARICA SLICE CENTRALE
try
    info = niftiinfo(fullfile(path, file));
    V_all = niftiread(info);
    
    % Gestione 4D vs 3D
    if ndims(V_all) == 4
        % Prendiamo il FLAIR (Canale 1) per il test
        slice_idx = round(size(V_all, 3) / 2);
        slice = double(V_all(:, :, slice_idx, 1));
    else
        % Se è già 3D
        slice_idx = round(size(V_all, 3) / 2);
        slice = double(V_all(:, :, slice_idx));
    end
    
    % Rotazione per visualizzazione corretta
    slice = rot90(slice);
    
catch ME
    errordlg(['Errore lettura file: ' ME.message]);
    return;
end

% 3. APPLICA OTSU SEMPLICE 
% Riscaliamo tra 0 e 1 per graythresh
slice_norm = rescale(slice); 
level = graythresh(slice_norm);
mask_otsu = imbinarize(slice_norm, level);

% 4. VISUALIZZAZIONE DIAGNOSTICA
figure('Name', 'Analisi Skull Stripping', 'Color', 'w', 'Position', [100 100 1200 500]);

% A. Immagine Originale
subplot(1, 3, 1);
imshow(slice, []);
title('1. Immagine Originale');
xlabel('Guarda i bordi esterni');

% B. Maschera Otsu
subplot(1, 3, 2);
imshow(mask_otsu);
title(['2. Maschera Otsu (Soglia: ' num2str(level, '%.2f') ')']);
xlabel('Bianco = Tessuto rilevato');

% C. Sovrapposizione Bordi
subplot(1, 3, 3);
imshow(slice, []); hold on;
% Disegna il contorno della maschera in rosso
[B,L] = bwboundaries(mask_otsu, 'noholes');
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end
title('3. Contorni Otsu (Rosso)');
xlabel('Il rosso segue il cervello o il cranio?');

fprintf('Analisi completata su %s\n', file);