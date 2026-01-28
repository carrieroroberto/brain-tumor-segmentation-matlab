function svmModel = classification(features, labels)
    % TRAIN_SVM
    % Input: features (Matrice N x M), labels (Vettore N x 1: 1=Tumor, 0=Non-Tumor)
    
    fprintf('Training SVM con Grid Search e Cross-Validation...\n');
    
    % Definizione iperparametri per Grid Search
    template = templateSVM('KernelFunction', 'rbf', 'Standardize', true);
    
    % Ottimizzazione bayesiana automatica di BoxConstraint e KernelScale
    svmModel = fitcsvm(features, labels, ...
        'OptimizeHyperparameters', {'BoxConstraint', 'KernelScale'}, ...
        'HyperparameterOptimizationOptions', struct('AcquisitionFunctionName', 'expected-improvement-plus'), ...
        'KernelFunction', 'rbf', ...
        'Standardize', true, ...
        'ClassNames', [0, 1]);
        
    % Cross-Validation 
    cvModel = crossval(svmModel, 'KFold', 5);
    accuracy = 1 - kfoldLoss(cvModel);
    
    fprintf('SVM Accuracy (5-fold CV): %.2f%%\n', accuracy * 100);
end