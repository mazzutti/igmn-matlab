% RPM - Rock Physics Model for calculating P-wave velocity (Vp), S-wave velocity (Vs), and density (Rho).
% 
% This function computes the elastic properties of a rock given its porosity, clay volume fraction, 
% and water saturation. It uses a combination of matrix-fluid modeling and a soft sand model 
% to estimate the properties.
% 
% Syntax:
%     [Vp, Vs, Rho] = RPM(Phi, v_clay, sw)
% 
% Inputs:
%     Phi     - Porosity of the rock (fraction, 0 to 1).
%     v_clay  - Volume fraction of clay in the rock (fraction, 0 to 1).
%     sw      - Water saturation (fraction, 0 to 1).
% 
% Outputs:
%     Vp      - P-wave velocity (m/s).
%     Vs      - S-wave velocity (m/s).
%     Rho     - Bulk density of the rock (g/cm^3).
% 
% Internal Parameters:
%     criticalporo - Critical porosity (default: 0.4).
%     coordnumber  - Coordination number (default: 9).
%     pressure     - Effective pressure (default: 0.060 GPa).
% 
% Dependencies:
%     This function relies on the following sub-functions:
%     - MatrixFluidModel: Computes the bulk and shear moduli, and densities of the matrix and fluid.
%     - DensityModel: Computes the bulk density of the rock.
%     - SoftsandModel: Implements the soft sand model to calculate elastic moduli and velocities.
% 
% Example:
%     [Vp, Vs, Rho] = RPM(0.25, 0.2, 0.8);
function [Vp, Vs, Rho] = RPM(Phi ,v_clay, sw)

criticalporo=0.4;
coordnumber=9;
pressure=0.060;


Kminc = [37 21];
Gminc = [45 7];
Rhominc = [2.65 2.58];
Volminc = [ 1-v_clay  v_clay ] ;

Kflc = [3.14 0.53];
Rhoflc = [1.06 0.52];
Sflc = [sw 1-sw];

[Kmat, Gmat, Rhomat, Kfl, Rhofl] = MatrixFluidModel (Kminc, Gminc, Rhominc, Volminc, Kflc, Rhoflc, Sflc, 0);

Rho = DensityModel(Phi, Rhomat, Rhofl);

[Vp, Vs] = SoftsandModel(Phi, Rho, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);