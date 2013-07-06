function [meanCoherence, meanPhase] = rd_coherency(A, freqRange, window, noverlap, Fs)

if notDefined('freqRange'), freqRange = []; end
if notDefined('window'),       window = []; end
if notDefined('noverlap'),   noverlap = []; end %TODO: what should this be?
if notDefined('Fs'),               Fs = []; end

% one column of A at a time
for i = 1:size(A, 2)  
    % [pxx,f] = pwelch(x,window,noverlap,f,fs)
    [Pxx(:,i), F] = pwelch(A(:,i), window, noverlap, [], Fs);
end

emptyMatrix = zeros(size(F, 1), size(A, 2), size(A, 2));
Pxy         = emptyMatrix;
coherence   = emptyMatrix;
phase       = emptyMatrix;

for i = 1:size(A, 2)
    for j = 1:size(A, 2) % i:size(A, 2) to do half the work
        Pxy(:, j, i) = cpsd(A(:,i), A(:,j), window, noverlap, [], Fs);
        coherence(:, j, i) = (abs(Pxy(:, j, i)) .^ 2) ./ (Pxx(:,i) .* Pxx(:,j));
        phaseRad = angle(Pxy(:, j, i)); % in radians
        phase(:, j, i) = phaseRad./(2*pi*F);
    end
end

% Take only those frequencies in the specified range
if isempty('freqRange')
    freqRange = [F(1) F(end)]; 
end

meanCoherence = squeeze(mean(coherence(F>=freqRange(1) & F<=freqRange(2),:,:)));
meanPhase     = squeeze(mean(phase(F>=freqRange(1) & F<=freqRange(2),:,:)));
