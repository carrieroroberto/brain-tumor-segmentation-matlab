function mask = region_growing(img, seed)
    % REGION_GROWING: Segmentazione per crescita di regione (8-connettività)
    %
    % Input:
    %   img  : Immagine pre-processata [0, 1]
    %   seed : Coordinate del punto iniziale [riga, colonna]
    
    [rows, cols] = size(img);
    mask = false(rows, cols);
    
    % 1. Parametri di crescita
    % La tolleranza definisce quanto un pixel può essere "diverso" dal seme.
    % 0.15 è un valore robusto per le iper-intensità FLAIR.
    tolerance = 0.35; 
    seed_val = img(seed(1), seed(2));
    
    % 2. Inizializzazione Coda FIFO (Pre-allocazione per velocità)
    % Usiamo due vettori per memorizzare le coordinate da esplorare
    queue_r = zeros(rows * cols, 1);
    queue_c = zeros(rows * cols, 1);
    head = 1; % Puntatore all'elemento da processare
    tail = 1; % Puntatore alla fine della coda
    
    % Inseriamo il primo punto (il seme)
    queue_r(tail) = seed(1);
    queue_c(tail) = seed(2);
    mask(seed(1), seed(2)) = true;
    tail = tail + 1;
    
    % 3. Definizione degli 8 vicini (spostamenti riga/colonna)
    % Questo definisce la 8-connettività
    dr = [-1, 1, 0, 0, -1, -1, 1, 1];
    dc = [0, 0, -1, 1, -1, 1, -1, 1];
    
    % 4. Ciclo di espansione
    while head < tail
        % Estraiamo il pixel corrente dalla testa della coda
        curr_r = queue_r(head);
        curr_c = queue_c(head);
        head = head + 1;
        
        % Esaminiamo gli 8 vicini
        for i = 1:8
            neighbor_r = curr_r + dr(i);
            neighbor_c = curr_c + dc(i);
            
            % Controllo: il vicino è dentro i bordi dell'immagine?
            if neighbor_r >= 1 && neighbor_r <= rows && ...
               neighbor_c >= 1 && neighbor_c <= cols
                
                % Controllo: è già stato visitato?
                if ~mask(neighbor_r, neighbor_c)
                    
                    % Criterio di omogeneità: la differenza è sotto la tolleranza?
                    diff = abs(img(neighbor_r, neighbor_c) - seed_val);
                    
                    if diff <= tolerance
                        % Aggiungiamo alla maschera e alla coda
                        mask(neighbor_r, neighbor_c) = true;
                        queue_r(tail) = neighbor_r;
                        queue_c(tail) = neighbor_c;
                        tail = tail + 1;
                    end
                end
            end
        end
    end
end