% rd_mrMeanTSeriesCorrelation.m
%
% Note: Must be in the correct mrSession folder when running this

%% setup
% subject = 'SB';
[upDir, subject] = fileparts(pwd);
dt = 1;
voxelSelection = 'extreme'; % 'all','extreme'
% scan = 1;
% rois = {'ROI101','LV1','L_hMTplus','ROI201','RV1','R_hMTplus'};
% rois = {'LLGN_ecc0','LLGN_ecc14','LV1_ecc0-2','LV1_ecc10-18',...
%     'RLGN_ecc2','RLGN_ecc9','RV1_ecc1-3','RV1_ecc7-11'};
% rois = {'lgnROI1_betaM-P_prop20_varThresh040_groupM',...
%     'lgnROI1_betaM-P_prop20_varThresh040_groupP',...
%     'LV1','LV2v','LV2d','LV3v','LV3d',...
%     'LV3a','L_hMTplus','LIPS0','LIPS1','LIPS2','LIPS3','LIPS4','LIPS5'};
% rois = {'lgnROI2_betaM-P_prop20_varThresh050_groupM',...
%     'lgnROI2_betaM-P_prop20_varThresh050_groupP',...
%     'RV1','RV2v','RV2d','RV3v','RV3d',...
%     'RV3AB_rd','R_hMTplus','RIPS0','RIPS1_rd','RIPS2_rd','RIPS3_rd','RIPS4_rd'};
% rois = {'lgnROI1_M','lgnROI1_P','LV1','lgnROI2_M','lgnROI2_P','RV1'};

switch voxelSelection
    case 'all'
        LLGN_M = 'lgnROI1_betaM-P_prop20_varThresh000_groupM';
        LLGN_P = 'lgnROI1_betaM-P_prop20_varThresh000_groupP';
        RLGN_M = 'lgnROI2_betaM-P_prop20_varThresh000_groupM';
        RLGN_P = 'lgnROI2_betaM-P_prop20_varThresh000_groupP';
    case 'extreme'
        LLGN_M = 'lgnROI1_betaM-P_prop10_varThresh000_groupM';
        LLGN_P = 'lgnROI1_betaM-P_prop60_varThresh000_groupP';
        RLGN_M = 'lgnROI2_betaM-P_prop10_varThresh000_groupM';
        RLGN_P = 'lgnROI2_betaM-P_prop60_varThresh000_groupP';
    otherwise
        error('voxelSelection not recognized')
end

switch subject
    case 'SB'
        scan = 8; % fix
        rois = {'lgnROI1_betaM-P_prop10_varThresh000_groupM',...
            'lgnROI1_betaM-P_prop60_varThresh000_groupP',...
            'LV1','LV2v','LV2d','LV3v','LV3d','LV4_cons','LV4_lib','LV3A','LV3B',...
            'LhMTplus','LhMTplus_vol','LLO1','LLO2',...
            'LIPS0','LIPS1','LIPS2','LIPS3','LIPS4','LIPS5',...
            'LOFA','LFFA','LpScene','LaScene',...
            'lgnROI2_betaM-P_prop10_varThresh000_groupM',...
            'lgnROI2_betaM-P_prop60_varThresh000_groupP',...
            'RV1','RV2v','RV2d','RV3v','RV3d','RV4_cons','RV4_lib','RV3A','RV3B',...
            'RhMTplus','RhMTplus_vol','RLO1','RLO2','RTO1','RTO2',...
            'RIPS0','RIPS1','RIPS2',...
            'ROFA','RFFA','RpScene','RaScene'};
    case 'JN'
        scan = 13; % 1=fix, 12=M, 13=P
        rois = {'lgnROI1_betaM-P_prop20_varThresh040_groupM',...
            'lgnROI1_betaM-P_prop20_varThresh040_groupP',...
            'LV1','LV2v','LV2d','LV3v','LV3d','LV4_cons','LV4_lib','LV3AB',...
            'LhMTplus','LLO1','LLO2',...
            'LIPS0','LIPS1','LIPS2','LIPS3','LIPS4','LIPS5',...
            'LOFA','LFFA','LfSTS','LpScene','LmScene','LaScene',...
            'lgnROI2_betaM-P_prop20_varThresh050_groupM',...
            'lgnROI2_betaM-P_prop20_varThresh050_groupP',...
            'RV1','RV2v','RV2d','RV3v','RV3d','RV4_cons','RV4_lib','RV3A','RV3B',...
            'RhMTplus','RLO1','RLO2','RTO1','RTO2',...
            'RIPS0','RIPS1','RIPS2','RIPS3','RIPS4',...
            'ROFA','RFFA','RfAT','RpScene','RmScene','RaScene'};
    case 'AV_20130922' % 7T2
        scan = 1; % 1,13,14=fix, 12=M, 11=P
        rois = {LLGN_M,...
            LLGN_P,...
            'LV1','LV2v','LV2d','LV3v','LV3d','LV4','LV3AB',...
            'LhMTplus','LLO1','LLO2','LTO1','LTO2',...
            'LIPS0','LIPS1','LIPS2','LIPS3','LIPS4','LIPS5',...
            RLGN_M,...
            RLGN_P,...
            'RV1','RV2v','RV2d','RV3v','RV3d','RV4',...
            'RV3A','RV3B',...
            'RhMTplus','RLO1','RLO2','RTO1',...
            'RIPS0','RIPS1','RIPS2','RIPS3','RIPS4','RIPS5'};
    case 'RD_20130921' % 7T2
        scan = 1; % 1,11,14=fix, 12=M, 13=P
        rois = {LLGN_M,...
            LLGN_P,...
            'LV1','LV2v','LV2d','LV3v','LV3d','LV4','LV3A',...
            'LhMTplus','LLO1','LLO2','LTO1','LTO2',...
            'LIPS0','LIPS1','LIPS2','LIPS3','LIPS4','LIPS5',...
            RLGN_M,...
            RLGN_P,...
            'RV1','RV2v','RV2d','RV3v','RV3d','RV4_cons','RV4_lib',...
            'RV3A','RV3B',...
            'RhMTplus','RLO1','RLO2','RVO1','RVO2',...
            'RIPS0','RIPS1','RIPS2','RIPS3','RIPS4','RIPS5'};
    otherwise
        error('subject not recognized')
end

roiNames = rois;
% roiNames{1} = 'lgnROI2_M';
% roiNames{2} = 'lgnROI2_P';
% selectStr = rois{1}(9:end-7);
selectStr = '';

getRawData = 1;
filterTSeries = 1;
regressNuisance = 1;
regressGlobal = 1; % if regressNuisance is 0, this won't matter
freqRange = [0.009 0.08]; % [0.009 0.08] from Fox 2005
filtN = 50; % filter order, data must have 3x this length

saveFigs = 1;
saveAnalysis = 1;

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

%% Open hidden Inplane and get sampling frequency
vw = initHiddenInplane(dt, scan, rois);
Fs = 1/mrSESSION.functionals(scan).framePeriod; % 1/TR
scanName = dataTYPES(dt).scanParams(scan).annotation;
scanName(scanName==' ') = []; % remove spaces from scan name
fprintf('%s, %s voxels\n', scanName, voxelSelection)

%% File I/O
figDir = sprintf('ConnectivityAnalysis/figures/%s/left-right', scanName);
analDir = 'ConnectivityAnalysis/left-right';
roiSetName = sprintf('%s_etal',rois{1});
figFileBase = sprintf('%s_%s', roiSetName, analStr);
analysisFileName = sprintf('%s_%s_%s_%s.mat', ...
    scanName, roiSetName, analStr, datestr(now,'yyyymmdd'));

%% Get ROI mean tseries
fprintf('[%s] Getting ROI tseries ... ', datestr(now))
[roiTSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);
roiTSeries = cell2mat(roiTSeries);
fprintf('done\n')

%% Filter tseries
fprintf('[%s] Preprocessing\n', datestr(now))
if filterTSeries
    tSeries = rd_bandpass(double(roiTSeries), freqRange, Fs, filtN);
else
    tSeries = roiTSeries;
end

%% Regress out motion, motion derivatives, wm, csf
b = []; resids = [];
if regressNuisance
    if filterTSeries
        X = rd_getNuisanceRegressors(scan, regressGlobal, freqRange, Fs, filtN);
    else
        X = rd_getNuisanceRegressors(scan, regressGlobal);
    end
    
    for iROI = 1:numel(rois)
        [b(:,iROI), bint, resids(:,iROI)] = regress(tSeries(:,iROI),X);
    end
    
    % use the residuals for the connectivity analysis
    tSeries = resids;
end

%% Calulcate correlation between all tseries
fprintf('[%s] Calculating correlation\n', datestr(now))
roiCorr = corr(tSeries);

%% Calculate coherency between all tseries
% calculates coherence and phase between all columns of roiTSeries
fprintf('[%s] Calculating coherency\n', datestr(now))
[roiCoh, roiPhase] = rd_coherency(tSeries, freqRange, [], [], Fs);

%% Plot correlation
f(1) = figure;
clim = rd_zeroCenterCLim(roiCorr);
% imagesc(tril(roiCorr),clim);
imagesc(roiCorr,clim);
axis equal
axis tight
title(sprintf('Correlation %s %s\n%s', scanName, analStr, selectStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(rois))
set(gca,'YTick',1:numel(rois))
set(gca,'XTickLabel',roiNames)
set(gca,'YTickLabel',roiNames)
rotateticklabel(gca,90,'image');

%% Plot coherence
f(2) = figure;
clim = rd_zeroCenterCLim(roiCoh);
imagesc(roiCoh,clim);
axis equal
axis tight
title(sprintf('Coherence %s %s\n%s', scanName, analStr, selectStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(rois))
set(gca,'YTick',1:numel(rois))
set(gca,'XTickLabel',roiNames)
set(gca,'YTickLabel',roiNames)
rotateticklabel(gca,90,'image');

f(3) = figure;
clim = rd_zeroCenterCLim(roiPhase);
imagesc(roiPhase,clim);
axis equal
axis tight
title(sprintf('Phase %s %s\n%s', scanName, analStr, selectStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(rois))
set(gca,'YTick',1:numel(rois))
set(gca,'XTickLabel',roiNames)
set(gca,'YTickLabel',roiNames)
rotateticklabel(gca,90,'image');

%% Save analysis
if saveAnalysis
    % Store analysis info and results
    scanInfo.dt = dt;
    scanInfo.scan = scan;
    scanInfo.scanName = scanName;
    scanInfo.Fs = Fs;
    
    preproc.getRawData = getRawData;
    preproc.filterTSeries = filterTSeries;
    preproc.regressNuisance = regressNuisance;
    preproc.regressGlobal = regressGlobal;
    preproc.freqRange = freqRange;
    preproc.filtN = filtN;
    preproc.analStr = analStr;
    
    resuts.tSeries = tSeries;
    results.roiCorr = roiCorr;
    results.roiCoh = roiCoh;
    results.roiPhase = roiPhase;
    results.whenAnalyzed = datestr(now);
    
    % save
    % make directory, if it doesn't already exist
    if ~exist(analDir,'dir')
        mkdir(analDir)
    end
    save(sprintf('%s/%s', analDir, analysisFileName), ...
        'scanInfo','rois','preproc','results')
end

%% Save figs
figNames = {'cor','coh','ph'};
if saveFigs
    % make directory, if it doesn't already exist
    if ~exist(figDir,'dir')
        mkdir(figDir)
    end
    for iF = 1:numel(f)
        figFilePath = sprintf('%s/%s_%s', ...
            figDir, figFileBase, figNames{iF});
        print(f(iF), '-djpeg', figFilePath)
    end
end


