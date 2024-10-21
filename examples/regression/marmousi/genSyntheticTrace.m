function trace = genSyntheticTrace(theta, traceSize, Time, tl, Vp, Vs, Rho, timeSeis, wavelet, lowFreqFilter)
    
    VpInterp = interp1(tl, Vp, Time);
    VsInterp =  interp1(tl, Vs, Time);
    RhoInterp = interp1(tl, Rho, Time);
    Seis = SeismicModel(VpInterp, VsInterp, RhoInterp, Time, theta, wavelet);
    Vp =  VpInterp(2:end, :);
    Vs = VsInterp(2:end, :);
    Rho = RhoInterp(2:end, :);

    lowFreqData = [lowFreqFilter(Vp)', lowFreqFilter(Vs)', lowFreqFilter(Rho)']; 

    nd = length(Time)-1;
    Seis = reshape(Seis, nd, []);
    SeisNoisy = s_noise(Seis, {'ratio', 1}, {'type','gaussian'}, {'amplitude', 'median'}).traces;

    trace = nan(traceSize, 1, numel(theta) + 11);
    trace(1:nd, 1, :) = [reshape(Seis, nd, []), lowFreqData, Vp, Vs, Rho, Time(2:end), timeSeis, SeisNoisy];
end