function X = rd_getNuisanceRegressors(scan, useGlobal, freqRange, Fs, filtN)

% X = rd_getNuisanceRegressors(scan, [useGlobal], [freqRange], [Fs], [filtN])
%
% Make a design matrix X containing motion, wm, csf, whole brain
% regressors and their derivatives (first-order differences)
%
% INPUTS
% scan: scan number
% useGlobal: 1 if you want to include the whole brain mean signal
% regressor, 0 if not (optional, default 0)
% freqRange: 2-element vector given frequency range for bandpass filtering
% of the nuisance time series
% Fs: sampling frequency of the nuisance time series
% freqRange and Fs are optional, but if you include one, you must supply
% both. If you include neither, the time series will not be filtered.
% filtN: the filter order (n) supplied to filtfilt. data must be 3x as
% long as this. optional or empty to use default.
%
% OUTPUTS
% X: design matrix of nuisance regressors, [motion moDerivs nuisance
% nuDerivs dc], where dc is a column of ones

%% deal with inputs
if nargin==1
    useGlobal = 0;
end
if nargin<3
    filterTSeries = 0;
elseif nargin==3
    error('If you want to filter, you must supply both freqRange and Fs')
elseif nargin>3
    filterTSeries = 1;
end
if nargin<5
    filtN = [];
end

%% load nuisance data
mo = load('motionParams.mat');
nu = load('nuisanceTSeries.mat');

motionParams = mo.motionParams{scan};
if useGlobal
    nuisanceTSeries = [nu.wm{scan} nu.csf{scan} nu.wholebrain{scan}];
else
    nuisanceTSeries = [nu.wm{scan} nu.csf{scan}];
end
dc = ones(size(motionParams,1),1);

if filterTSeries
    nuisanceTSeries = rd_bandpass(double(nuisanceTSeries), freqRange, Fs, filtN);
end

motionDerivs = [diff(motionParams); zeros(1,size(motionParams,2))];
nuisanceDerivs = [diff(nuisanceTSeries); zeros(1,size(nuisanceTSeries,2))];
    
%% make a matrix with all the regressors
X = [motionParams motionDerivs nuisanceTSeries nuisanceDerivs];

% rescale columns of X
xmin = repmat(min(X),size(X,1),1);
xmax = repmat(max(X),size(X,1),1);
X = (X-xmin)./(xmax-xmin);

% add constant column
X = [X dc]; 

