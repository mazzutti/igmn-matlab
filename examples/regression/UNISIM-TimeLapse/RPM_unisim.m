% RPM_unisim - Rock Physics Model for Unisim Data
% 
% This function calculates the P-wave velocity (Vp), S-wave velocity (Vs), 
% and density (Rho) of a rock sample based on porosity (Phi), water saturation (sw), 
% and critical porosity (criticalporo) using a rock physics model.
% 
% Inputs:
%     Phi          - Porosity array (fractional values, e.g., 0.0 to 0.4).
%                    Values less than 0 are set to their absolute values.
%                    Values greater than 0.4 are capped at 0.4.
%     sw           - Water saturation array (fractional values, e.g., 0.0 to 1.0).
%                    Values less than 0 are set to their absolute values.
%                    Values greater than 1.0 are capped at 1.0.
%     criticalporo - Critical porosity value (scalar).
% 
% Outputs:
%     Vp  - P-wave velocity (m/s), reshaped to match the input size of Phi.
%     Vs  - S-wave velocity (m/s), reshaped to match the input size of Phi.
%     Rho - Density (g/cm³), reshaped to match the input size of Phi.
% 
% Notes:
%     - The function internally uses the MatrixFluidModel, DensityModel, 
%       and SoftsandModel to compute the outputs.
%     - The velocities (Vp and Vs) are converted from km/s to m/s.
%     - The outputs are reshaped to match the original dimensions of the input Phi.
% 
% Dependencies:
%     - MatrixFluidModel: Computes matrix and fluid properties.
%     - DensityModel: Computes the density of the rock.
%     - SoftsandModel: Computes the velocities using the soft sand model.
% 
% Example:
%     [Vp, Vs, Rho] = RPM_unisim(Phi, sw, criticalporo);
% 
function [Vp, Vs, Rho] = RPM_unisim(Phi, sw, criticalporo)

SIZE = size(Phi);

Phi(Phi <= 0) = -Phi(Phi <= 0);
Phi(Phi >= 0.40) = Phi(Phi >= 0.40) - (Phi(Phi >= 0.40) - 0.4);

sw(sw <= 0) =  -sw(sw <= 0);
sw(sw >= 1.0) = sw(sw >= 1.0) - (sw(sw >= 1.0) - 1);

Phi = Phi(:);
sw = sw(:);

coordnumber = 9;
pressure = 0.060;

Kminc = 37;
Gminc = 44;
Rhominc = 2.65;
Volminc = ones(size(sw));

Kflc = [3.14 0.53];
Rhoflc = [1.06 0.52];
Sflc = [sw 1-sw];

[Kmat, Gmat, Rhomat, Kfl, Rhofl] = MatrixFluidModel (Kminc, Gminc, Rhominc, Volminc, Kflc, Rhoflc, Sflc, 0);

Rho = DensityModel(Phi, Rhomat, Rhofl);

[Vp, Vs] = SoftsandModel(Phi, Rho, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);

Vp = Vp * 1000;
Vs = Vs * 1000;

Vp  = reshape(Vp, SIZE);
Vs  = reshape(Vs, SIZE);
Rho = reshape(Rho, SIZE);

