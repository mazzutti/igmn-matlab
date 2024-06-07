function [L, diagL, cov] = computeChol(cov) %#codegen
    coder.inline('always');
    [L, f] = chol(cov,  'lower');
    if f ; [L, cov] = mchol(cov); end
    diagL = diag(L);
end
