function mask = region_growing(I, seedY, seedX, thresh)
% File: region_growing.m
% Esegue la segmentazione di un'immagine a partire da un punto iniziale (seme),
% espandendo la regione ai pixel adiacenti che soddisfano un criterio di intensità.
%
% INPUT:
% I - matrice dell'immagine (in scala di grigi) da segmentare
% seedY - coordinata Y (riga) del pixel di partenza (seme)
% seedX - coordinata X (colonna) del pixel di partenza (seme)
% thresh - valore di soglia minima di intensità per includere un pixel nella regione
%
% OUTPUT:
% mask - maschera binaria risultante (true per i pixel appartenenti alla regione)

    % estrazione delle dimensioni dell'immagine
    [rows, cols] = size(I);
    
    % inizializzazione della maschera di output e della matrice dei pixel visitati
    mask = false(rows, cols);
    visited = false(rows, cols);
    
    % pre-allocazione della coda statica per le coordinate dei pixel da esplorare
    max_pixels = rows * cols;
    Q_row = zeros(max_pixels, 1);
    Q_col = zeros(max_pixels, 1);
    
    % inizializzazione dei puntatori della coda (head per estrarre, tail per inserire)
    head = 1; tail = 1;
    
    % inserimento del seme iniziale nella coda come punto di partenza
    Q_row(tail) = seedY; Q_col(tail) = seedX;
    tail = tail + 1;
    
    % segna il seme come appartenente alla regione e già visitato
    mask(seedY, seedX) = true;
    visited(seedY, seedX) = true;
    
    % definizione dei vettori di spostamento per esplorare gli 8 vicini
    % (spostamenti orizzontali, verticali e diagonali)
    dRow = [-1, 1, 0, 0, -1, -1, 1, 1];
    dCol = [0, 0, -1, 1, -1, 1, -1, 1];
    
    % ciclo principale: continua finché la coda non è vuota
    while head < tail
        % estrae le coordinate del pixel corrente dalla testa della coda
        currY = Q_row(head);
        currX = Q_col(head);
        head = head + 1;
        
        % itera su tutti gli 8 pixel vicini a quello corrente
        for i = 1:8
            nY = currY + dRow(i);
            nX = currX + dCol(i);
            
            % assicura che nY e nX non escano dai bordi dell'immagine
            if (nY > 0 && nY <= rows) && (nX > 0 && nX <= cols)

                % se il vicino non è ancora stato analizzato, lo segna
                % comoe tale
                if ~visited(nY, nX)
                    visited(nY, nX) = true;
                    
                    % se il valore di intensità del pixel supera la soglia (thresh),
                    % esso entra a far parte della regione
                    if I(nY, nX) > thresh
                       mask(nY, nX) = true;
                       
                       % accoda il nuovo pixel per espandere ulteriormente la ricerca
                       Q_row(tail) = nY; Q_col(tail) = nX;
                       tail = tail + 1;
                    end
                end
            end
        end
    end
    
end