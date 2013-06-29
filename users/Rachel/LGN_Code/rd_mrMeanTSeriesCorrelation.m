% rd_mrMeanTSeriesCorrelation.m

dt = 1;
scan = 1;
rois = {'ROI1','ROI2','ROI3'};

getRawData = 1;

% Open hidden Inplane
vw = initHiddenInplane(dt, scan, rois);

[roiTSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);

roiTSeries = cell2mat(roiTSeries);
roiCorr = corr(roiTSeries);