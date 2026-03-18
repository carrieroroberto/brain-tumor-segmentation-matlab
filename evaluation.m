function [dice, sens, prec] = evaluation(mask_pred, mask_gt)
% File: evaluation.m
% Calcola le metriche di valutazione della segmentazione: Dice Score, Sensitivity (Recall) e Precision.
%
% INPUT:
% mask_pred - maschera predetta (binaria)
% mask_gt - maschera ground truth (binaria)
%
% OUTPUT:
% dice - Dice Score (0-1)
% sens - Sensitivity (0-1)
% prec - Precision (0-1)

    % calcolo dei true positive (TP), false positive (FP) e false negative (FN)
    % TP: pixel predetti correttamente come tumore
    % FP: pixel predetti come tumore ma non presenti nella GT
    % FN: pixel non predetti come tumore ma presenti nella GT
    TP = sum(mask_pred(:) & mask_gt(:));
    FP = sum(mask_pred(:) & ~mask_gt(:));
    FN = sum(~mask_pred(:) & mask_gt(:));
    
    % dice score: misura di similarità tra predizione e ground truth
    dice = (2 * TP) / (2 * TP + FP + FN);
    
    % sensitivity: frazione di veri positivi rilevati sul totale dei positivi
    sens = TP / (TP + FN);   
    
    % precision: frazione di veri positivi rilevati sul totale dei positivi predetti
    prec = TP / (TP + FP);   
    
end