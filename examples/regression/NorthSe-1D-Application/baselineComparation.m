function baselineComparation(X_train, y_train, y_pred_igmn, y_cov_igmn, y_true)
    gprMdl = fitrgp(X_train, y_train, ...
        'KernelFunction', 'squaredexponential', ...
        'BasisFunction', 'constant', ...
        'Sigma', 1e-3, ...
        'Standardize', true);
    [y_gpr, y_std] = predict(gprMdl, X_test);  % y_std = standard deviation

    % z = 1.96; % 95% confidence level
    % ci_lower_gpr = y_gpr - z * y_std;
    % ci_upper_gpr = y_gpr + z * y_std;
    
    % Metrics
    % inside_gpr = (y_true >= ci_lower_gpr) & (y_true <= ci_upper_gpr);
    % picp_gpr = mean(inside_gpr);
    % mpiw_gpr = mean(ci_upper_gpr - ci_lower_gpr);
    % range_y = max(y_true) - min(y_true);
    % nmpiw_gpr = mpiw_gpr / range_y;
    % gamma = double(picp_gpr < 0.95);
    % cwc_gpr = nmpiw_gpr * (1 + gamma * exp(-50 * (picp_gpr - 0.95)));

    figure;
    subplot(2,1,1);
    plot_confidence(y_pred_igmn, y_cov_igmn, y_true, 'IGMN');
    
    subplot(2,1,2);
    plot_confidence(y_gpr, y_std.^2, y_true, 'GPR');

end


function plot_confidence(mu, var, y_true, titleText)
    z = 1.96;
    ci_lower = mu - z * sqrt(var);
    ci_upper = mu + z * sqrt(var);
    plot(y_true, 'k', 'DisplayName', 'True');
    hold on;
    plot(mu, 'b', 'DisplayName', 'Prediction');
    fill([1:length(mu), fliplr(1:length(mu))], ...
         [ci_upper', fliplr(ci_lower')], ...
         [0.8 0.8 1], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    title(titleText);
    legend;
end

