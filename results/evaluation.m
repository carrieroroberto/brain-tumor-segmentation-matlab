function stats = evaluation(mask_pred, mask_gt)
    mask_pred = logical(mask_pred);
    mask_gt = logical(mask_gt);
    
    TP = sum(mask_pred & mask_gt, 'all');
    FP = sum(mask_pred & ~mask_gt, 'all');
    FN = sum(~mask_pred & mask_gt, 'all');
    
    stats.dice = (2 * TP) / (2 * TP + FP + FN);
    
    stats.iou = TP / (TP + FP + FN);
    
    stats.sensitivity = TP / (TP + FN);
end