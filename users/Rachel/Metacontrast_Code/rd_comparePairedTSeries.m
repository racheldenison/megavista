% rd_comparePairedTSeries.m

%% setup
vw = INPLANE{1};
scans = 3:12;
roi = 'targetVmask_LV1';

saveFigs = 1;

%% file i/o
figDir = sprintf('ROIAnalysis/%s/figures', roi);
figNames = {'runPairTSCorrelations', 'runPairTSCorrHist'};

%% get tseries
for iScan = 1:numel(scans)
    scan = scans(iScan);
    tSeries(:,iScan) = meanTSeries(vw, scan, roi, 0);
end

%% calculate tseries correlations
tsCorr = corr(tSeries);
pairedRunCorr = [tsCorr(1,10) tsCorr(2,9) tsCorr(3,8) tsCorr(4,7) tsCorr(5,6)];
allRunCorr = tril(tsCorr);
allRunCorr = allRunCorr(:);
allRunCorr(allRunCorr==0 | allRunCorr==1) = [];

%% plot correlations
f(1) = figure;
clim = rd_zeroCenterCLim(tsCorr);
imagesc(tsCorr,clim);
colormap(rdbumap)
axis equal tight
colorbar
xlabel('scan')
ylabel('scan')
title(sprintf('%s time series correlations', roi))

%% hist
f(2) = figure;
[n, x] = hist(allRunCorr);
bar(x,n,1)
hold on
[n, x] = hist(pairedRunCorr,x);
bar(x,n,1,'r')
legend('all runs','paired runs')
xlabel('time series correlation')
ylabel('number of run pairs')
title(roi)

%% save figs
if saveFigs
    for iF = 1:numel(f)
        name = sprintf('%s/%s_%s', figDir, figNames{iF}, datestr(now,'yyyymmdd'));
        print(f(iF), '-dpng', name)
    end
end
