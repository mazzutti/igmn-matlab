% Soft sand model
% Stiff sand model
% Inclusion model for spherical pores
% Berryman inclusion model for ellptical pores
% We assume that the solid is 100% quartz and the fluid is 100% water. For
% mixtures of minerals and fluids, the elastic properties can be computed
% using the function Matrix Fluid Model.
% 
clear all
close all

%% Available data and parameters
% Load data (porosity and depth)
addpath(genpath('../SeReM/'))
load Data/data1

FitnessFunction = @Phi_fitness;

Phi_pred=zeros(length(Phi),1);

% Initial parameters
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
Rho = DensityModel(Phi, Rhomat, Rhofl);

% Soft sand model
VpRef = SoftsandModel(Phi, Rho, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);

options = optimoptions('ga','PlotFcn', @gaplotbestf, ...
    'Display', 'iter', 'UseParallel', true , 'FunctionTolerance',1e-18);

tam = length(VpRef);
lb(1:length(VpRef),:)=0.000001;
ub(1:length(VpRef),:)=0.4;
[Phi_pred, fval,exitFlag,output,population,scores] = ga(@(params) Phi_fitness(params, VpRef),tam,[],[],[],[],lb,ub,[],options);

% for i=1:length(VpRef)
%     setGlobal(VpRef(i));
%     tam = length(VpRef(i));
%     lb(1:length(VpRef(i)),:)=0.000001;
%     ub(1:length(VpRef(i)),:)=0.4;
%     [Phi_pred(i), fval(i)] = ga(FitnessFunction,tam,[],[],[],[],lb,ub,[],options);
% end



figure
scatter(Phi_pred, VpRef, 50, Phi, 'o');
grid on; box on;
xlim([0 0.3]); ylim([1.5 6.5]); 
xlabel('Porosity'); ylabel('P-wave velocity (km/s)');
legend('Soft sand model')
