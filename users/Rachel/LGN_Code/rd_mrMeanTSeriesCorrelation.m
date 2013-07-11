% rd_mrMeanTSeriesCorrelation.m

%% setup
dt = 1;
scan = 1;
rois = {'ROI101','LV1','L_hMTplus','ROI201','RV1','R_hMTplus'};
% rois = {'LLGN_ecc0','LLGN_ecc14','LV1_ecc0-2','LV1_ecc10-18',...
%     'RLGN_ecc2','RLGN_ecc9','RV1_ecc1-3','RV1_ecc7-11'};

getRawData = 1;
filterTSeries = 0;
regressNuisance = 0;
regressGlobal = 0; % if regressNuisance is 0, this won't matter
% filterBeforeCor = 0; % use a filtered tseries for the correlation?
freqRange = [0.009 0.08]; % [0.009 0.08] from Fox 2005

saveFigs = 1;

%% File I/O
figDir = 'ConnectivityAnalysis/figures';

%% Open hidden Inplane and get sampling frequency
vw = initHiddenInplane(dt, scan, rois);
Fs = 1/mrSESSION.functionals(scan).framePeriod; % 1/TR

%% Get ROI mean tseries
[roiTSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);
roiTSeries = cell2mat(roiTSeries);

%% Filter tseries
if filterTSeries
    tSeries = rd_bandpass(double(roiTSeries), freqRange, Fs);
else
    tSeries = roiTSeries;
end

%% Regress out motion, motion derivatives, wm, csf
if regressNuisance
    if filterTSeries
        X = rd_getNuisanceRegressors(scan, regressGlobal, freqRange, Fs);
    else
        X = rd_getNuisanceRegressors(scan, regressGlobal);
    end
    
    for iROI = 1:numel(rois)
        [b(:,iROI), bint, resids(:,iROI)] = regress(tSeries(:,iROI),X);
    end
    
    % use the residuals for the connectivity analysis
    tSeries = resids;
end

%% Filter tseries
% if filterBeforeCor
%     corTSeries = rd_bandpass(double(tSeries), freqRange, Fs);
% else
%     corTSeries = tSeries;
% end

%% Calulcate correlation between all tseries
roiCorr = corr(tSeries);

%% Calculate coherency between all tseries
% calculates coherence and phase between all columns of roiTSeries
[roiCoh, roiPhase] = rd_coherency(tSeries, freqRange, [], [], Fs);

%% Generate analysis string
analStr = '';
if getRawData
    analStr = [analStr 'r'];
end
if filterTSeries
    analStr = [analStr 'f'];
end
if regressNuisance
    analStr = [analStr 'n'];
    if regressGlobal
        analStr = [analStr 'g'];
    end
end

%% Plot correlation
f(1) = figure;
clim = rd_zeroCenterCLim(roiCorr);
% imagesc(tril(roiCorr),clim);
imagesc(roiCorr,clim);
axis equal
axis tight
title(sprintf('Correlation %s', analStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)

%% Plot coherence
f(2) = figure;
clim = rd_zeroCenterCLim(roiCoh);
imagesc(roiCoh,clim);
axis equal
axis tight
title(sprintf('Coherence %s', analStr),...
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
title(sprintf('Phase %s', analStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)

%% Save figs
figNames = {'cor','coh','ph'};
roiSetName = sprintf('%s_etal',rois{1});
if saveFigs
    for iF = 1:numel(f)
        figFileName = sprintf('%s/%s_%s_%s', ...
            figDir, roiSetName, analStr, figNames{iF});
        print(f(iF), '-djpeg', figFileName)
    end
end


