function mask_clean = post_processing(mask_raw)
% File: post_processing.m
% Applica operazioni di algebra morfologica per la regolarizzazione dei contorni,
% il riempimento delle cavità e la rimozione del rumore nella maschera segmentata.
%
% INPUT:
% mask_raw - maschera binaria grezza ottenuta dalla pipeline di segmentazione
%
% OUTPUT:
% mask_clean - maschera binaria finale post-processata e ripulita

    % definizione dell'elemento strutturante (un disco di raggio 3 pixel)
    se = strel("disk", 3);
    
    % applica l'operazione di chiusura morfologica (closing)
    % per smussare i bordi frastagliati e chiudere eventuali piccole insenature
    mask_clean = imclose(mask_raw, se);
    
    % riempimento dei buchi interni alla regione segmentata 
    % (necessario per includere il core necrotico scuro all'interno del tumore)
    mask_clean = imfill(mask_clean, "holes");
    
    % estrae e mantiene esclusivamente la singola componente connessa con area maggiore
    % (questo passaggio elimina piccoli artefatti o falsi positivi isolati nel cervello)
    mask_clean = bwareafilt(mask_clean, 1);
        
end