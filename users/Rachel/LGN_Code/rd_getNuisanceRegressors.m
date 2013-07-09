function X = rd_getNuisanceRegressors(scan, freqRange, Fs)

% X = rd_getNuisanceRegressors(scan, freqRange, Fs)
%
% Make a design matrix X containing motion, motion derivative, wm, csf
% regressors

%% deal with inputs
if nargin==1
    filterTSeries = 0;
elseif nargin == 2
    error('If you want to filter, you must supply both freqRange and Fs')
elseif nargin ==3
    filterTSeries = 1;
end

%% load nuisance data
mo = load('motionParams.mat');
nu = load('nuisanceTSeries.mat');

motionParams = mo.motionParams{scan};
nuisanceTSeries = [nu.wm{scan} nu.csf{scan}];
dc = ones(size(motionParams,1),1);

motionDerivs = [diff(motionParams); zeros(1,size(motionParams,2))];

if filterTSeries
    nuisanceTSeries = rd_bandpass(double(nuisanceTSeries), freqRange, Fs);
end
    
%% make a matrix with all the regressors
X = [motionParams motionDerivs nuisanceTSeries];

% rescale columns of X
xmin = repmat(min(X),size(X,1),1);
xmax = repmat(max(X),size(X,1),1);
X = (X-xmin)./(xmax-xmin);

% add constant column
X = [X dc]; 
