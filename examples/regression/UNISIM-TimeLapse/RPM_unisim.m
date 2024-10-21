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

