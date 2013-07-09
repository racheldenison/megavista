% rd_mrMeanTSeriesCorrelation.m

%% setup
dt = 1;
scan = 1;
rois = {'ROI101','LV1','L_hMTplus','ROI201','RV1','R_hMTplus'};
% rois = {'LLGN_ecc0','LLGN_ecc14','LV1_ecc0-2','LV1_ecc10-18',...
%     'RLGN_ecc2','RLGN_ecc9','RV1_ecc1-3','RV1_ecc7-11'};

getRawData = 1;
% filterBeforeCor = 0; % use a filtered tseries for the correlation?
freqRange = [0.009 0.08]; % [0.009 0.08] from Fox 2005

%% Open hidden Inplane and get sampling frequency
vw = initHiddenInplane(dt, scan, rois);
Fs = 1/mrSESSION.functionals(scan).framePeriod; % 1/TR

%% Get ROI mean tseries
[roiTSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);
roiTSeries = cell2mat(roiTSeries);

%% Filter tseries
tSeriesFiltered = rd_bandpass(double(roiTSeries), freqRange, Fs);

%% Regress out motion, motion derivatives, wm, csf
X = rd_getNuisanceRegressors(scan, freqRange, Fs);

for iROI = 1:numel(rois)
    y = roiTSeries(:,iROI);
    [b(:,iROI), bint, resids(:,iROI)] = regress(y,X);
end

% use the residuals for the connectivity analysis
tSeries = resids;

%% Filter tseries
% if filterBeforeCor
%     corTSeries = rd_bandpass(double(tSeries), freqRange, Fs);
% else
%     corTSeries = tSeries;
% end

%% Calulcate correlation between all tseries
roiCorr = corr(tSeries);

%% Plot
f(1) = figure;
clim = rd_zeroCenterCLim(roiCorr);
% imagesc(tril(roiCorr),clim);
imagesc(roiCorr,clim);
axis equal
axis tight
title('Correlation',...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)


%% Calculate coherency between all tseries
% calculates coherence and phase between all columns of roiTSeries
[roiCoh, roiPhase] = rd_coherency(tSeries, freqRange, [], [], Fs);

%% Plot
f(2) = figure;
clim = rd_zeroCenterCLim(roiCoh);
imagesc(roiCoh,clim);
axis equal
axis tight
title('Coherence',...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)

f(3) = figure;
clim = rd_zeroCenterCLim(roiPhase);
imagesc(roiPhase,clim);
axis equal
axis tight
title('Phase',...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)


