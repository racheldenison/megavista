% rd_mrMeanTSeriesCorrelation.m

%% setup
dt = 1;
scan = 13;
% rois = {'ROI101','LV1','L_hMTplus','ROI201','RV1','R_hMTplus'};
% rois = {'LLGN_ecc0','LLGN_ecc14','LV1_ecc0-2','LV1_ecc10-18',...
%     'RLGN_ecc2','RLGN_ecc9','RV1_ecc1-3','RV1_ecc7-11'};
rois = {'lgnROI1_M','lgnROI1_P','LV1','LV2v','LV2d','LV3v','LV3d',...
    'LV3a','L_hMTplus','LIPS0','LIPS1','LIPS2','LIPS3','LIPS4','LIPS5'};

getRawData = 1;
filterTSeries = 1;
regressNuisance = 1;
regressGlobal = 1; % if regressNuisance is 0, this won't matter
% filterBeforeCor = 0; % use a filtered tseries for the correlation?
freqRange = [0.009 0.08]; % [0.009 0.08] from Fox 2005

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

%% File I/O
figDir = sprintf('ConnectivityAnalysis/figures/%s', scanName);
analDir = 'ConnectivityAnalysis';
roiSetName = sprintf('%s_etal',rois{1});
figFileBase = sprintf('%s_%s', roiSetName, analStr);
analysisFileName = sprintf('%s_%s_%s_%s.mat', ...
    scanName, roiSetName, analStr, datestr(now,'yyyymmdd'));

%% Get ROI mean tseries
fprintf('Getting ROI tseries ... ')
[roiTSeries, tSerr] = meanTSeries(vw, scan, rois, getRawData);
roiTSeries = cell2mat(roiTSeries);
fprintf('done\n')

%% Filter tseries
fprintf('Preprocessing\n')
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
fprintf('Calculating correlation\n')
roiCorr = corr(tSeries);

%% Calculate coherency between all tseries
% calculates coherence and phase between all columns of roiTSeries
fprintf('Calculating coherency\n')
[roiCoh, roiPhase] = rd_coherency(tSeries, freqRange, [], [], Fs);

%% Plot correlation
f(1) = figure;
clim = rd_zeroCenterCLim(roiCorr);
% imagesc(tril(roiCorr),clim);
imagesc(roiCorr,clim);
axis equal
axis tight
title(sprintf('Correlation %s %s', scanName, analStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(rois))
set(gca,'YTick',1:numel(rois))
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)
rotateticklabel(gca,90,'image')

%% Plot coherence
f(2) = figure;
clim = rd_zeroCenterCLim(roiCoh);
imagesc(roiCoh,clim);
axis equal
axis tight
title(sprintf('Coherence %s %s', scanName, analStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(rois))
set(gca,'YTick',1:numel(rois))
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)
rotateticklabel(gca,90,'image')

f(3) = figure;
clim = rd_zeroCenterCLim(roiPhase);
imagesc(roiPhase,clim);
axis equal
axis tight
title(sprintf('Phase %s %s', scanName, analStr),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(rois))
set(gca,'YTick',1:numel(rois))
set(gca,'XTickLabel',rois)
set(gca,'YTickLabel',rois)
rotateticklabel(gca,90,'image')

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
    preproc.analStr = analStr;
    
    results.roiCorr = roiCorr;
    results.roiCoh = roiCoh;
    results.roiPhase = roiPhase;
    results.whenAnalyzed = datestr(now);
    
    % save
    save(sprintf('%s/%s', analDir, analysisFileName), ...
        'scanInfo','rois','preproc','results')
end

%% Save figs
figNames = {'cor','coh','ph'};
if saveFigs
    for iF = 1:numel(f)
        figFilePath = sprintf('%s/%s_%s', ...
            figDir, figFileBase, figNames{iF});
        print(f(iF), '-djpeg', figFilePath)
    end
end


