% rd_metacontrastFitHRF.m


load sample_figData

%% Make X as in glm_convolve_1s.m
if notDefined('nFrames')
    nFrames = trials.onsetFrames(end);
end

% params
nConds = length(unique(trials.cond(trials.cond>0)));
nRuns = length(unique(trials.run));

TR = trials.TR;
nSecs = nFrames*TR;

 % init design matrix
% RD: let the time resolution be 1 s
X = zeros(nSecs, nConds+nRuns);

% RD: change frames to secs
% set up delta functions of onset frames for each condition
% (first nConds columns)
for i = 1:nConds
    ind = trials.onsetSecs(trials.cond==i) + params.onsetDelta + 1; % add 1, since onsetSecs starts at 0 = scan start
%     ind = ind(ind>0 & ind<nSecs); % RD: this could lead to invisible errors
    X(ind,i) = 1;
end

%% Get data into the right form for Fit_Canonical_HRF
% collapse X to make Run
r{1} = sum(X(:,1:5),2); % sum only across certain conditions

% get timecourse
wholeTc = figData.wholeTc';

% interpolate timecourse to get 1-s resolution
interpTc = interp(wholeTc, TR);

%% Fit HRF using Canonical HRF + 2 derivatives
FWHM = 4; % default from Example.m  
T = 30;
canonMode = 3; % Options: mode=1 - only canonical HRF
%          mode=2 - canonical + temporal derivative
%          mode=3 - canonical + time and dispersion derivative
hrfTR = 1;
      
[h, fit, e, param, info] = Fit_Canonical_HRF(interpTc, hrfTR, r, T, canonMode);
[pv sres sres_ns] = ResidScan(e, FWHM);
[PowLoss] = PowerLoss(e, fit, (len-p), interpTc, hrfTR, r, alpha);

hold on; han(4) = plot(fit,'m');

legend(han,{'Data' 'IL' 'sFIR' 'DD'})


disp('Summary: Canonical + 2 derivatives');

disp('Amplitude'); disp(param(1));
disp('Time-to-peak'); disp(param(2)*hrfTR);
disp('Width'); disp(param(3)*hrfTR);

disp('MSE:'); disp((1/(len-1)*sum(e.^2)));
disp('Mis-modeling'); disp(pv);
disp('Power Loss:'); disp(PowLoss);

%% Fit HRF using FIR-model
% Choose mode (FIR/sFIR)
firMode = 1;   % 0 - FIR 
            % 1 - smooth FIR
            
[h2, fit2, e2, param] = Fit_sFIR(interpTc,1,r,T,firMode);
[pv sres sres_ns2] = ResidScan(e2, FWHM);
[PowLoss2] = PowerLoss(e2, fit2, (len-T) , tc, TR, Runc, alpha);

hold on; han(3) = plot(fit2,'g');

disp('Summary: FIR');

disp('Amplitude'); disp(param(1));
disp('Time-to-peak'); disp(param(2)*TR);
disp('Width'); disp(param(3)*TR);

disp('MSE:'); disp((1/(len-1)*sum(e2.^2)));
disp('Mis-modeling'); disp(pv);
disp('Power Loss:'); disp(PowLoss2);

%% Make HRF file for mrVista
hrf = h;
timeWindow = 0:T-1;
tr = 1;
% Save the HRF in the Anatomicals/../HRF directory
% save HRF/canonDerifFit_targetVMask_LV1.mat hrf timeWindow tr
