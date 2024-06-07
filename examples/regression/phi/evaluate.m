% function fit = evaluate(params, targets, Rhomat, Rhofl, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure)
% 
%     Rho = DensityModel(params, Rhomat, Rhofl);
%     outputs = SoftsandModel(params, Rho, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);
%     fit = sum(sqrt(mean((targets' - outputs) .^ 2)), 'all');
% end

function fit = evaluate(params, targets, Phi)

    % Density
    Rho = DensityModel(Phi, params(1), params(2));

    
    outputs = StiffsandModel(Phi, Rho, params(3), params(4), params(5), params(6), params(7), params(8));

    fit = sum(sqrt(mean((targets - outputs) .^ 2)), 'all');
end
