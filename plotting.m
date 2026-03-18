function plotting(imgs_proc, mask_gt, masks, dices, filename, save_path)

% File: plotting.m
% Visualizza in una singola figura la segmentazione di immagini MRI multi-sequenza.
% Vengono mostrate la ground truth e le predizioni per le diverse sequenze, con titoli
% dinamici contenenti i valori Dice e la legenda colore.
%
% INPUT:
% imgs_proc - struct di tutte le sequenze MRI preprocessate (2D)
% mask_gt - maschera ground truth (binaria)
% masks - cell array contenente le predizioni (binario)
% dices - vettore numrico dei valori dice per ogni predizione
% filename - nome del paziente
% save_path - path completo dove salvare la figura

    % creazione della figura invisibile
    fig = figure("Visible", "off");
    
    % definizione dei titoli per ciascun subplot
    % il primo elemento è la ground truth, gli altri sono i valori dice delle diverse sequenze
    titles = ["Ground Truth (T1)", ...
              "FLAIR | Dice: " + dices(1), ...
              "T1c | Dice: " + dices(2), ...
              "T2 | Dice: " + dices(3), ...
              "Fus2 (FLAIR+T1c) | Dice: " + dices(4), ...
              "Fus3 (FLAIR+T1c+T2) | Dice: " + dices(5)];
    
    % converte la struct in un cell array (per la ground truth usa la t1 generica)
    imgs_proc = {imgs_proc.t1, imgs_proc.flair, imgs_proc.t1c, imgs_proc.t2, imgs_proc.fus2, imgs_proc.fus3};
    
    % ciclo unico per creare tutti i subplot (2 righe x 3 colonne)
    for i = 1:6
        subplot(2,3,i); % seleziona il subplot i-esimo
        imshow(imgs_proc{i}, []); % mostra l'immagine MRI originale
        hold on; % mantiene gli overlay

        % disegna il contorno della ground truth in verde
        h_gt = visboundaries(mask_gt, "Color", "g");

        if i > 1
            % per i subplot 2-6 aggiunge anche il contorno della predizione in rosso
            h_pr = visboundaries(masks{i-1}, "Color", "r");
            
            % solo nell'ultimo subplot aggiunge la legenda
            if i == 6
                lg = legend([h_gt h_pr], ["Ground Truth", "Predizione"], "Location", "southeast");
                lg.Position(2) = 0.08; % sposta la legenda verso il basso
            end
        end
        
        % aggiorna il titolo del subplot
        title(titles(i));
    end
    
    % titolo globale della figura con il nome del paziente
    sgtitle("Segmentazione Multi-Sequenza MRI - Paziente: " + filename);
    
    % salvataggio della figura
    saveas(fig, save_path);
    
    % chiusura della figura
    close(fig);

end