clear all; %#ok<CLALL> 
close all;
clc;
rng('default');


addpath(genpath('../../../igmn/'));
addpath(genpath('../../../SeReM/'));
load Data/data4

% Initial parameters
Rhomat=2.65;
Rhofl=1;
Kmat=36; 
Gmat=45;
Kfl=2.25;
% Gfl=0;

% Phi = Phi(1:10, :);
% Depth = Depth(1:10, :);


%% Granular media models
% Initial parameters
criticalporo=0.4;
coordnumber=7;
pressure=0.02;

% Density
% Rho = DensityModel(Phi, Rhomat, Rhofl);
% 
% Vp = SoftsandModel(Phi, Rho, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);
num_vars = 8;

% fitness = @(params) evaluate(params, targets, Kmat, Gmat, Kfl, criticalporo, coordnumber, pressure);

optOptions = optimizeoptions( ...
    Algorithm='pso', ...
    UseParallel=false, ...
    PopulationSize=1000, ...
    StallIterLimit=100, ...
    TolFunValue=1e-18, ...
    MaxIter=10000, ...
    MaxFunEval=1000000, ...
    PlotFuncs={'plotbestf'}, ...
    Display='iter' ...
);

% hpNames = [];
% for i = 1:num_vars
%     hpNames = [hpNames, {sprintf('phi%f', i)}]; %#ok<AGROW>
% end

hpNames = {'Rhomat', 'Rhofl', 'Kmat', 'Gmat', 'Kfl', 'criticalporo', 'coordnumber', 'pressure'};
hpValues = [2.65, 0.5, 36, 45,  2.25, 0.4, 7, 0.02];
lb = [1.5, 0.52, 10, 7, 0.23, 0.29, 5, 0.02]; 
ub = [2.65, 2.06, 37, 45, 3, 0.5, 24, 2]; 
% codegen pso -args {optOptions, lb, ub, num_vars, hpNames, targets, Phi}
% options = optimoptions('ga','PlotFcn', @gaplotbestf, ...
%     'Display', 'iter', 'UseParallel',true , 'FunctionTolerance', 1e-18);

% fitness = @(params) evaluate(params, varargs{:});
% lb = zeros(1, num_vars);
% ub = zeros(1, num_vars);
% lb(:) = min(Phi);
% ub(:) = max(Phi);
% x0 = rand(1, 329) .* 0.4;
% fit = ga(fitness, num_vars, [], [], [], [], lb, ub, [], options);

tic;
fit = pso(optOptions, lb, ub, num_vars, hpNames, Vp, Phi);
toc

% tic;
% fit = pso_mex(optOptions, lb, ub, num_vars, hpNames, varargs{:});
% toc;

Rho = DensityModel(Phi, fit(1), fit(2));
vpfit = StiffsandModel(Phi, Rho, fit(3), fit(4), fit(5), fit(6),  fit(7), fit(8));

% figure
% colormap(jet)
% scatter(Vp, vpfit, 50, Phi, 'o');
% grid on; box on;
% % xlim([0 0.3]); ylim([1.5 6.5]); 
% xlabel('Porosity'); ylabel('P-wave velocity (km/s)');
% legend('Soft sand model')

figure
colormap(jet);
plot(Vp, Depth);
hold on;
plot(vpfit, Depth);
% xlim([0 0.3]); ylim([1.5 6.5]); 
xlabel('P-wave velocity (km/s)'); ylabel('Depth');
legend('Vp', 'Vpfit')


disp('Real x Pred. Constants')
for i = 1:num_vars
    fprintf('%s: %f | ', hpNames{i}, hpValues(i))
end
fprintf('\n')
for i = 1:num_vars
    fprintf('%s: %f | ', hpNames{i}, fit(i))
end

