function y = rd_bandpass(x, freqrange, fs, n)

% y = rd_bandpass(x, freqrange, fs, [n])
%
% Bandpass filters a timeseries x with sampling frequency fs to the
% frequency band given by the 2-element vector freqrange. n is the filter 
% order (default 50); note x must be 3x as long as n. Uses the FIR
% method and filtfilt to achieve zero-phase lag filtering.

% freqrange = [.009 .08];
% fs = 0.5;

if nargin < 4 || isempty(n)
    n = 50;
end

b = fir1(n,freqrange/(fs/2));
y = filtfilt(b,1,x);