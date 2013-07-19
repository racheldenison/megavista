% rd_comparePairedTSeries.m

%% setup
vw = INPLANE{1};
scans = 2:11;
roi = 'Target_V1';

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
figure
clim = rd_zeroCenterCLim(tsCorr);
imagesc(tsCorr,clim);
colormap(rdbumap)
axis equal tight
colorbar
xlabel('scan')
ylabel('scan')

%% hist
figure
[n, x] = hist(allRunCorr);
bar(x,n,1)
hold on
[n, x] = hist(pairedRunCorr,x);
bar(x,n,1,'r')
legend('all runs','paired runs')
xlabel('time series correlation')
ylabel('number of run pairs')
