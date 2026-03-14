function mask_final = refinement(mask_raw)
    % REFINEMENT: Pulizia morfologica delle maschere segmentate
    
    % 1. Hole Filling (Fondamentale per il Region Growing)
    % Riempie i buchi neri all'interno della massa bianca.
    % Spesso il centro del tumore è necrotico (più scuro) e il RG lo salta.
    mask_filled = imfill(mask_raw, 'holes');
    
    % 2. Apertura Morfologica (Opening)
    % Rimuove piccoli "ponti" o appendici sottili che non sono tumore.
    % Usa un elemento strutturante a disco.
    se_open = strel('disk', 2);
    mask_opened = imopen(mask_filled, se_open);
    
    % 3. Chiusura Morfologica (Closing)
    % Sigilla i contorni e leviga la superficie esterna.
    se_close = strel('disk', 4);
    mask_final = imclose(mask_opened, se_close);
    
    % 4. Rimozione di oggetti piccoli residui
    % Se sono rimasti dei "pixel vaganti" fuori dal tumore, li cancelliamo.
    mask_final = bwareafilt(logical(mask_final), 1);
end