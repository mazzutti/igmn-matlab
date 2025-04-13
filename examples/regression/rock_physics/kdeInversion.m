% kdeInversion - Perform kernel density estimation-based inversion for rock physics data.
%
% Syntax:
%   [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData)
%
% Description:
%   This function performs a non-parametric inversion using kernel density
%   estimation (KDE) to estimate petrophysical properties (e.g., porosity,
%   clay content, and water saturation) from elastic properties (e.g., Vp,
%   Vs, and density). The inversion is based on a probabilistic framework
%   that computes posterior distributions for the petrophysical properties.
%
% Inputs:
%   modelData - A matrix containing the model data. The first columns
%               represent elastic properties (Vp, Vs, Rho), and the
%               remaining columns represent petrophysical properties.
%   wellData  - A matrix containing the well log data. The columns represent
%               depth, Vp, Vs, and density measurements.
%
% Outputs:
%   outputs        - A matrix containing the maximum a posteriori (MAP)
%                    estimates of petrophysical properties (porosity,
%                    clay content, and water saturation) for each sample.
%   probabilities   - A cell array containing the marginal posterior
%                    distributions for porosity, clay content, and water
%                    saturation.
%   outputsDomain   - A cell array containing the discretized domains for
%                    porosity, clay content, and water saturation.
%
% Notes:
%   - The function uses a fixed kernel bandwidth for KDE, which is computed
%     based on the range of the discretized domains.
%   - The inversion is performed for each sample in the well log data.
%
% Example:
%   [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData);
%
% See also:
%   RockPhysicsKDEInversion
function [outputs, probabilities, outputsDomain] = kdeInversion(modelData, wellData)
    %% Non-parametric case (Kernel density estimation)

    % petrophysical domain discretization
    ndiscr = 25;
    phidomain = linspace(0, 0.4, ndiscr)';   
    cdomain = linspace(0, 0.8, ndiscr)';   
    swdomain = linspace(0, 1, ndiscr)';   
    mdomain = [phidomain cdomain swdomain];


    Vp = wellData(:, 2);
    Vs = wellData(:, 3);
    Rho = wellData(:, 4);
    
    % elastic domain discretization
    vpdomain  = linspace(min(Vp), max(Vp), ndiscr)';
    vsdomain = linspace(min(Vs), max(Vs), ndiscr)';
    rhodomain = linspace(min(Rho), max(Rho), ndiscr)';
    ddomain = [vpdomain vsdomain rhodomain];
    
    % kernel bandwidths 
    h = 5;
    hm(1) = (max(phidomain)-min(phidomain))/h;
    hm(2) = (max(cdomain)-min(cdomain))/h;
    hm(3) = (max(swdomain)-min(swdomain))/h;
    hd(1) = (max(vpdomain)-min(vpdomain))/h;
    hd(2) = (max(vsdomain)-min(vsdomain))/h;
    hd(3) = (max(rhodomain)-min(rhodomain))/h;
    
    
    % measured data (elastic logs)
    dcond = wellData(:, 2:4);
    ns = size(dcond,1);
    
    % inversion
    tic;
    Ppost = RockPhysicsKDEInversion(modelData(:, 5:end), modelData(:, 2:4), mdomain, ddomain, dcond, hm, hd);
    toc;
    
    % marginal posterior distributions
    Ppostphi = zeros(ns,length(phidomain));
    Ppostclay = zeros(ns,length(cdomain));
    Ppostsw = zeros(ns,length(swdomain));
    Phimap = zeros(ns,1);
    Cmap = zeros(ns,1);
    Swmap = zeros(ns,1);
    for i=1:ns
        Ppostjoint=reshape(Ppost(i,:),length(phidomain),length(cdomain),length(swdomain));
        Ppostphi(i,:)=sum(squeeze(sum(squeeze(Ppostjoint),3)),2);
        Ppostclay(i,:)=sum(squeeze(sum(squeeze(Ppostjoint),3)),1);
        Ppostsw(i,:)=sum(squeeze(sum(squeeze(Ppostjoint),2)),1);
        Ppostphi(i,:)=Ppostphi(i,:)/sum(Ppostphi(i,:));
        Ppostclay(i,:)=Ppostclay(i,:)/sum(Ppostclay(i,:));
        Ppostsw(i,:)=Ppostsw(i,:)/sum(Ppostsw(i,:));
        [~,Phimapind]=max(Ppostphi(i,:));
        [~,Cmapind]=max(Ppostclay(i,:));
        [~,Swmapind]=max(Ppostsw(i,:));
        Phimap(i)=phidomain(Phimapind);
        Cmap(i)=cdomain(Cmapind);
        Swmap(i)=swdomain(Swmapind);
    end
    outputs = [Phimap Cmap, Swmap];
    probabilities = {Ppostphi, Ppostclay, Ppostsw};
    outputsDomain = {phidomain, cdomain, swdomain};
end

