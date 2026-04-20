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
    
    % calcolo del gradiente dell'immagine
    [Gmag, ~] = imgradient(I_proc);
    
    % dilata il Region Growing di 5 pixel, per creare uno spazio in cui rifinire il bordo
    se = strel("disk", 5);
    mask_rg_dilated = imdilate(mask_rg, se);
    
    % definisce i marcatori di sfondo
    bg_marker = ~mask_rg_dilated;
    
    % unisce i marcatori interni ed esterni
    markers = mask_otsu | bg_marker;
    
    % impone i minimi nei marcatori individuati
    D_mod = imimposemin(Gmag, markers);
    
    % esegue il Watershed
    L = watershed(D_mod);
    
    % il tumore è il bacino in cui si trova la coordinata del seme iniziale
    id_tumore = L(seedY, seedX);
    mask_raw = (L == id_tumore);
    
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