function mask = segmentation(I_proc, seed_map)
% File: segmentation.m
% Implementa una pipeline di segmentazione ibrida.
% Sfrutta Otsu multilivello per i marker, Region Growing per l'espansione e 
% Marker-Controlled Watershed per separare le strutture contigue.
%
% INPUT:
% I_proc - immagine pre-processata in scala di grigi
% seed_map - mappa dei semi (estratta in fase di pre-processing)
%
% OUTPUT:
% mask - maschera binaria finale della regione segmentata

    % individuazione del seme iniziale dal picco massimo della mappa dei semi
    [~, maxIdx] = max(seed_map(:));
    
    % conversione dell'indice lineare in coordinate (riga, colonna)
    [seedY, seedX] = ind2sub(size(I_proc), maxIdx);
    
    % segmentazione multilivello (a 3 classi) per estrarre la componente più luminosa
    levels = multithresh(I_proc, 2);
    mask_otsu = I_proc > levels(2);
    
    % calcolo di una soglia dinamica per il region growing basata sull'intensità dei marker (5° percentile)
    intensities = I_proc(mask_otsu);
    thresh_rg = prctile(intensities, 6);
    
    % esecuzione dell'accrescimento della regione a partire dal seme estratto
    mask_rg = region_growing(I_proc, seedY, seedX, thresh_rg);
    
    % calcolo della trasformata di distanza invertita per creare la mappa topografica
    D = -bwdist(~mask_rg);
    
    % imposizione dei minimi locali in corrispondenza dei marker di Otsu (Marker-Controlled Watershed)
    D_mod = imimposemin(D, mask_otsu);
    
    % esclusione dei pixel di background per impedire l'allagamento al di fuori della ROI
    D_mod(~mask_rg) = -Inf;
    
    % applicazione della trasformata watershed
    L = watershed(D_mod);
    
    % generazione della maschera rimuovendo le linee di separazione
    mask = mask_rg;
    mask(L == 0) = 0;
    
    % estrazione della componente connessa contenente il seme
    % (scarto delle strutture adiacenti tagliate dal watershed)
    mask = bwselect(mask, seedX, seedY, 8);
    
end