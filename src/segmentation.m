function mask_clean = segmentation(I_proc, seed_map, seq_name, filename)
%% File: segmentation.m
% Implementa l'algoritmo in cascata per l'estrazione della maschera
% tumorale % (Otsu -> Region Growing -> Marked-Watershed)
%
% INPUT:
% I_proc - immagine MRI bidimensionale post-processata
% seed_map - mappa di intensità sfocata per la localizzazione automatica
% seq_name - sequenza MRI corrente da analizzare
% filename - nome del file NIfTI analizzato
%
% OUTPUT:
% mask_clean - maschera finale pulita

    % creazione del percorso di destinazione per il salvataggio dei grafici di segmentazione
    segmentation_dir = "results/plots/" + filename + "/segmentation/";
    mkdir(segmentation_dir);
    
    % ricerca del picco di intensità sulla seed map per ottenere le
    % coordinate iniziali del seme
    [~, maxIdx] = max(seed_map(:));
    [seedY, seedX] = ind2sub(size(I_proc), maxIdx);
    
    % segmentazione multilivello tramite Otsu per isolare l'area tumorale
    levels = multithresh(I_proc, 2);
    mask_otsu = I_proc > levels(2);
    
    % calcolo della soglia dinamica basata sul 6° percentile e avvio del RG
    thresh_rg = prctile(I_proc(mask_otsu), 6);
    mask_rg = region_growing(I_proc, seedY, seedX, thresh_rg);
    
    % costruzione del bacino topografico con trasformata della distanza inversa
    D = -bwdist(~mask_rg);
    
    % imposizione dei minimi locali per forzare l'algoritmo watershed sui marker di Otsu
    D_mod = imimposemin(D, mask_otsu);
    
    % esecuzione dell'algoritmo Watershed
    L = watershed(D_mod);
    
    % rimozione dei confini di separazione
    mask_raw = mask_rg;
    mask_raw(L == 0) = 0;
    
    % isolamento della componente morfologica connessa contenente il seed iniziale
    mask_raw = bwselect(mask_raw, seedX, seedY, 8);
    
    % inizializzazione della figura per il salvataggio dell'analisi
    fig = figure("Visible", "off");
    
    % visualizzazione della maschera ottenuta tramite Otsu
    subplot(2, 2, 1);
    imshow(I_proc, []);
    hold on;
    visboundaries(mask_otsu, "Color", "y");
    title("Otsu");
    
    % visualizzazione della maschera ottenuta tramite Region Growing
    subplot(2, 2, 2);
    imshow(I_proc, []);
    hold on;
    visboundaries(mask_rg, "Color", "c");
    title("Region Growing");
    
    % visualizzazione della maschera ottenuta tramite Watershed marcato
    subplot(2, 2, 3);
    imshow(I_proc, []);
    hold on;
    visboundaries(mask_raw, "Color", "m");
    title("Watershed Marcato");
    
    % visualizzazione della maschera finale
    subplot(2, 2, 4);
    imshow(I_proc, []);
    hold on;
    visboundaries(mask_raw, "Color", "r");
    title("Maschera Finale");
    
    % aggiunta del titolo e chiusura della figura
    sgtitle("Segmentazione " + seq_name + " - Paziente: " + filename);
    saveas(fig, segmentation_dir + seq_name + "_segmentation.png");
    close(fig);
    
    % chiamata alla funzione di post-processing morfologico
    mask_clean = post_processing(mask_raw, I_proc, seq_name, filename);
end