function mask = marked_watershed(img, marker_int, marker_ext)
    % MARKED_WATERSHED: Segmentazione topografica guidata da marker.
    % Evita la sovra-segmentazione forzando i minimi locali.
    
    % 1. Calcolo del Gradiente Morfologico
    % Il gradiente evidenzia i bordi (le "creste" delle montagne).
    % Si ottiene sottraendo l'erosione dalla dilatazione dell'immagine.
    se = strel('disk', 1);
    grad = imdilate(img, se) - imerode(img, se);
    
    % 2. Imposizione dei Minimi (Impose Minima)
    % Questa è la riga magica. Diciamo all'algoritmo che le uniche 
    % "valli" in cui l'acqua può accumularsi sono i nostri marker.
    % marker_int -> Valle del tumore
    % marker_ext -> Valle dello sfondo
    grad_mod = imimposemin(grad, marker_int | marker_ext);
    
    % 3. Trasformata Watershed
    % Calcola le linee spartiacque sul gradiente modificato.
    L = watershed(grad_mod);
    
    % 4. Estrazione della maschera
    % Il Watershed restituisce un'immagine con label (1, 2, 3...).
    % Noi vogliamo solo la regione che coincide con il nostro marker interno.
    % Troviamo quale label è stata assegnata alla zona del marker_int.
    target_label = median(L(marker_int > 0));
    
    mask = (L == target_label);
end