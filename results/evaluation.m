function stats = evaluation(mask_pred, mask_gt)
    P = logical(mask_pred);
    G = logical(mask_gt);
    
    TP = sum(P(:) & G(:));
    FP = sum(P(:) & ~G(:));
    FN = sum(~P(:) & G(:));
    TN = sum(~P(:) & ~G(:));
    
    if (sum(P(:)) + sum(G(:))) == 0
        stats.dice = 1; 
    else
        stats.dice = (2 * TP) / (2 * TP + FP + FN);
    end
    
    if (TP + FN) == 0
        stats.recall = 1;
    else
        stats.recall = TP / (TP + FN);
    end
    
    if (TP + FP) == 0
        stats.precision = 1;
    else
        stats.precision = TP / (TP + FP);
    end
    
    totale_pixel = TP + TN + FP + FN;
    if totale_pixel == 0
        stats.accuracy = 1;
    else
        stats.accuracy = (TP + TN) / totale_pixel;
    end
end