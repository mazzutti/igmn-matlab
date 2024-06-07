function bhattDist = bhattDistance( ...
    meanX, meanY, covX, covY, useRankOne, logDetX, logDetY) %# codegen
    dmu =  bsxfun(@minus, meanX, meanY);
    factor = 0.125;
    if useRankOne
        numerator = covX * dmu';
        denominator = 1 + dmu * numerator;
        invCov = covX - (numerator * numerator') / denominator;
        firstTerm = dot(invCov * dmu', dmu);
        logdet = logDetX * denominator;
        secondTerm = logdet / sqrt(logDetX * logDetY);
    else
        factor = factor / 2;
        C = bsxfun(@rdivide, bsxfun(@plus, covX, covY), 2);
        dmu = dmu / computeChol(C);
        firstTerm = (dmu * dmu');
        secondTerm = det(bsxfun( ...
            @mrdivide, C, computeChol(bsxfun(@mtimes, covX, covY))));
    end
    if secondTerm > 0; secondTerm = log(secondTerm); end
    bhattDist = factor * firstTerm + 0.5 * secondTerm;
end
