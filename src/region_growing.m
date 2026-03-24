function mask = region_growing(I, seedY, seedX, thresh)
% File: region_growing.m
% Esegue la segmentazione di un'immagine a partire da un punto iniziale,
% espandendo la regione ai pixel adiacenti che soddisfano un criterio di intensità.
% L'implementazione utilizza una coda statica.
%
% INPUT:
% I - matrice dell'immagine (in scala di grigi) da segmentare
% seedY - coordinata Y (riga) del pixel di partenza (seme)
% seedX - coordinata X (colonna) del pixel di partenza (seme)
% thresh - valore di soglia minima di intensità per includere un pixel nella regione
%
% OUTPUT:
% mask - maschera binaria risultante (true per i pixel appartenenti alla regione)

    % estrazione delle dimensioni spaziali dell'immagine in analisi
    [rows, cols] = size(I);
    
    % inizializzazione della maschera logica di output e della mappa dei pixel visitati
    mask = false(rows, cols);
    visited = false(rows, cols);
    
    % coda statica per gestire le coordinate dei pixel da esplorare
    max_pixels = rows * cols;
    Q_row = zeros(max_pixels, 1);
    Q_col = zeros(max_pixels, 1);
    
    % inizializzazione dei puntatori per la gestione della coda (head: estrazione, tail: inserimento)
    head = 1; tail = 1;
    
    % accodamento delle coordinate del seed iniziale come punto di partenza dell'algoritmo
    Q_row(tail) = seedY; Q_col(tail) = seedX;
    tail = tail + 1;
    
    % marcatura del seed iniziale come appartenente alla regione tumorale e già analizzato
    mask(seedY, seedX) = true;
    visited(seedY, seedX) = true;
    
    % definizione dei vettori di offset per l'esplorazione dei pixel vicini (8-connesso)
    dRow = [-1, 1, 0, 0, -1, -1, 1, 1];
    dCol = [0, 0, -1, 1, -1, 1, -1, 1];
    
    % ciclo iterativo, termina quando la coda è vuota
    while head < tail
        % estrazione delle coordinate del pixel corrente dalla testa della coda
        currY = Q_row(head);
        currX = Q_col(head);
        head = head + 1;
        
        % iterazione sull'intorno spaziale di 8 pixel adiacenti a quello in analisi
        for i = 1:8
            nY = currY + dRow(i);
            nX = currX + dCol(i);
            
            % verifica dei limiti dell'immagine
            if (nY > 0 && nY <= rows) && (nX > 0 && nX <= cols)
                % controllo dello stato di visita del pixel adiacente per evitare loop infiniti
                if ~visited(nY, nX)
                    visited(nY, nX) = true;
                    
                    % valutazione del criterio di inclusione basato sulla soglia minima di intensità
                    if I(nY, nX) > thresh
                       mask(nY, nX) = true;
                       
                       % accodamento del pixel validato per procedere con la propagazione
                       Q_row(tail) = nY; Q_col(tail) = nX;
                       tail = tail + 1;
                    end
                end
            end
        end
    end
end