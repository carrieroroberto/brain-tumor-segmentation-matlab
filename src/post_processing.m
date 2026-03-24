function mask_clean = post_processing(mask_raw, I_proc, seq_name, filename)
% File: post_processing.m
% Applica operazioni morfologiche per la regolarizzazione dei contorni e
% il riempimento delle cavità. Genera il grafico di confronto prima/dopo.
%
% INPUT:
% mask_raw - maschera binaria grezza di input
% I_proc - immagini delle sequenze MRI come background per i grafici
% seq_name - sequenza corrente da elaborare
% filename - nome del file da analizzare
%
% OUTPUT:
% mask_clean - maschera binaria rifinita

    % creazione del percorso di destinazione per il salvataggio dei grafici di post-processing
    post_processing_dir = "results/plots/" + filename + "/post_processing/";
    mkdir(post_processing_dir);
    
    % definizione di un elemento strutturante a forma di disco simmetrico
    se = strel("disk", 3);
    
    % esecuzione dell'operazione morfologica di chiusura per migliorare i confini
    mask_clean = imclose(mask_raw, se);
    
    % riempimento dei vuoti interni eventuali
    mask_clean = imfill(mask_clean, "holes");
    
    % filtraggio delle componenti connesse per preservare esclusivamente la massa tumorale
    mask_clean = bwareafilt(mask_clean, 1);
    
    % inizializzazione della figura (non visibile) per l'esportazione del confronto
    fig = figure("Visible", "off");
        
    % visualizzazione della maschera grezza di partenza sovrapposta all'immagine originale
    subplot(1, 2, 1);
    imshow(I_proc, []);
    hold on;
    visboundaries(mask_raw, "Color", "r");
    title("Prima - Maschera Watershed Grezza");
        
    % visualizzazione della maschera finale post-processata
    subplot(1, 2, 2);
    imshow(I_proc, []);
    hold on;
    visboundaries(mask_clean, "Color", "g");
    title("Dopo - Maschera con Operazioni Morfologiche");
        
    % aggiunta del titolo e chiusura della figura
    sgtitle("Post-Processing " + seq_name + " - Paziente: " + filename);
    saveas(fig, post_processing_dir + seq_name + "_post_processing.png");
    close(fig);
end