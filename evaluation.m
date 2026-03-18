function [dice, sens, prec] = evaluation(mask_pred, mask_gt)
% EVALUATION: Calcola Dice Score, Sensitivity (Recall) e Precision.
    TP = sum(mask_pred(:) & mask_gt(:));
    FP = sum(mask_pred(:) & ~mask_gt(:));
    FN = sum(~mask_pred(:) & mask_gt(:));
    
    dice = (2 * TP) / (2 * TP + FP + FN + eps);
    sens = TP / (TP + FN + eps);   
    prec = TP / (TP + FP + eps);   
end