function m = meanf(x)
    % x(x > 2) = nan;
    tfValid = ~isnan(x) ;
    n = sum(tfValid, "all");
    if n == 0
        % prevent divideByZero warnings
        m = NaN;
    else
        % Sum up non-NaNs, and divide by the number of non-NaNs.
        m = sum(x(tfValid), "all") ./ n;
    end
end % 
