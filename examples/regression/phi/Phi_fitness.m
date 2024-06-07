function y = Phi_fitness(x, target)

x =x';

Kmat=36; 
Gmat=45;
Rhomat=2.65;
Kfl=2.25;
Gfl=0;
Rhofl=1;

criticalporo=0.4;
coordnumber=7;
pressure=0.02;

% Density
Rho = DensityModel(x(1), Rhomat, Rhofl);



% Soft sand model
VpSoft = SoftsandModel(x, Rho, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);

t1 = (target - VpSoft);


t2 = t1.^2;
t3 = sum(t2);
y = t3/length(x);
end

