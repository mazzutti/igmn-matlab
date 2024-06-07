function[filteredSignal, h] =  highPassFilter(signal, Ts, Ncoef, cutFreq)
    % highPassFilter(signal, Ts, Ncoef, cutFreq)
    % signal - Sinal 2d, matriz de impedancia no caso.
    %       obs. signal deve ser uma matriz ou um vetor coluna. No caso da
    %       cada coluna que ser· filtrada
    % Ts - Intervalo de amostragem  em ms
    % Ncoef - Numero de coeficientes do filtro (analogo ao overlap do Jason)
    % cutFreq - Frequencia de corte em HZ
    %
    % Exemplo  dado_filtrado = highPassFilter2(signal, 4, 110, 8);
    
    Ts = Ts * 1e-3;
    Fnorm = cutFreq*2*Ts;
    
    h = fir1(Ncoef,Fnorm,'high')';
    
    signalMod(1:Ncoef) = signal(1);
    signalMod(Ncoef+1:Ncoef+length(signal)) = signal(1:end);
    signalMod(Ncoef+length(signal)+1:2*Ncoef+length(signal)+1) = signal(end);
    
    filteredSignal = filter(h, 1, signalMod);
    filteredSignal = filteredSignal((3*Ncoef/2+1):(length(signal)+(3*Ncoef/2)));
end
