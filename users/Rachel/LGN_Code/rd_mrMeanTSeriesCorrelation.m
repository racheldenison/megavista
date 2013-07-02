% rd_mrMeanTSeriesCorrelation.m

%% setup
dt = 1;
scan = 1;
% rois = {'ROI101','LV1','L_hMTplus','ROI201','RV1','R_hMTplus'};
rois = {'LLGN_ecc0','LLGN_ecc14','LV1_ecc0-2','LV1_ecc10-18',...
    'RLGN_ecc2','RLGN_ecc9','RV1_ecc1-3','RV1_ecc7-11'};

getRawData = 1;

%% Open hidden Inplane
vw = initHiddenInplane(dt, scan, rois);

%% Get ROI mean tseries
[roiTSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);

%% Calulcate correlation between all tseries
roiTSeries = cell2mat(roiTSeries);
roiCorr = corr(roiTSeries);

%% Plot
f = figure;
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
freqRange = [0.01 0.15];
Fs = 1/mrSESSION.functionals(scan).framePeriod; % 1/TR

% calculates coherence and phase between all columns of roiTSeries
[roiCoh, roiPhase] = rd_coherency(roiTSeries, freqRange, [], [], Fs);

%% Plot
f = figure;
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




