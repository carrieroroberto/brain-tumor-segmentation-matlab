function stats = evaluation(mask_pred, mask_gt)
    % EVALUATION: Calcolo metriche di validazione spaziale (Dice, IoU, Sens)
    
    % Conversione in logico per operazioni booleane
    mask_pred = logical(mask_pred);
    mask_gt = logical(mask_gt);
    
    % Calcolo componenti base
    TP = sum(mask_pred & mask_gt, 'all');    % True Positives
    FP = sum(mask_pred & ~mask_gt, 'all');   % False Positives
    FN = sum(~mask_pred & mask_gt, 'all');   % False Negatives
    
    % 1. Dice Coefficient (F1-Score)
    % Misura la sovrapposizione armonica tra le due maschere
    stats.dice = (2 * TP) / (2 * TP + FP + FN);
    
    % 2. Jaccard Index (Intersection over Union - IoU)
    % Rapporto tra area comune e area totale occupata
    stats.iou = TP / (TP + FP + FN);
    
    % 3. Sensitivity (True Positive Rate)
    % Capacità dell'algoritmo di non "mancare" il tumore reale
    stats.sensitivity = TP / (TP + FN);
    
    % Se non ci sono pixel nel GT (caso raro), evitiamo divisioni per zero
    if isnan(stats.dice), stats.dice = 0; end
end