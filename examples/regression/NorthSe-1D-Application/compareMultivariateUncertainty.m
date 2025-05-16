function summary = compareMultivariateUncertainty(XA, XB)
    % XA, XB: N×d or M×d samples from two models

    
    % Number of dimensions
    d = size(XA, 2);
    
    % Add small regularization to covariance matrices to ensure numerical stability
    epsilon = 1e-5;
    covA = cov(XA) + epsilon * eye(d);
    covB = cov(XB) + epsilon * eye(d);

 
    % Check for NaN values in the data
    if any(isnan(XA(:))) || any(isnan(XB(:)))
        error('Input data contains NaN values.');
    end
    
    % Empirical means and covariances
    muA = mean(XA);  muB = mean(XB);
    
    % KL Divergence: N(muA, covA) || N(muB, covB)
    try
        KL_AB = 0.5 * (log(det(covB)) - log(det(covA)) ...
            - d + trace(covB \ covA) ...
            + (muB - muA) * (covB \ (muB - muA)'));
    catch
        KL_AB = NaN;
    end
    
    % KL Divergence reverse
    try
        KL_BA = 0.5 * (log(det(covA)) - log(det(covB)) ...
            - d + trace(covA \ covB) ...
            + (muA - muB) * (covA \ (muA - muB)'));
    catch
        KL_BA = NaN;
    end
    
    % Jensen-Shannon Divergence
    covM = 0.5 * (covA + covB);
    muM = 0.5 * (muA + muB);
    
    try
        KL_A_M = 0.5 * (log(det(covM)) - log(det(covA)) ...
            - d + trace(covM \ covA) ...
            + (muM - muA) * (covM \ (muM - muA)'));
    catch
        KL_A_M = NaN;
    end
    
    try
        KL_B_M = 0.5 * (log(det(covM)) - log(det(covB)) ...
            - d + trace(covM \ covB) ...
            + (muM - muB) * (covM \ (muM - muB)'));
    catch
        KL_B_M = NaN;
    end
    
    JS = 0.5 * (KL_A_M + KL_B_M);
    
    % Wasserstein-1 Approximate via samples
    D = pdist2(XA, XB);  % N × M distance matrix
    if any(isnan(D(:)))
        error('Distance matrix contains NaN values.');
    end
    W1 = mean(min(D, [], 2));  % From each point in A to closest in B
    
    % Assemble table
    summary = table(KL_AB, KL_BA, JS, W1, ...
        'VariableNames', {'KL_AB', 'KL_BA', 'JSDivergence', 'Wasserstein1'});
end
