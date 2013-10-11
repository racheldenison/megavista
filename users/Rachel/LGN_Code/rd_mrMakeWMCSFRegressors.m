% rd_mrMakeWMCSFRegressors.m

%% setup
dt = 1;
scans = 1:14;
rois = {'WM','CSF','wholebrain'};

getRawData = 1;

for scan = scans
    %% Open hidden Inplane
    vw = initHiddenInplane(dt, scan, rois);
    
    %% Get mean tseries
    [tSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);
    
    %% Store tseries
    wm{scan} = tSeries{strcmp(rois,'WM')};
    csf{scan} = tSeries{strcmp(rois,'CSF')};
    wholebrain{scan} = tSeries{strcmp(rois,'wholebrain')};
end

% save nuisanceTSeries.mat wm csf wholebrain
