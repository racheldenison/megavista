function rd_plotMPROIConnectivity(roi1Name, analStr, scanName, voxelSelection, seedHemi, measures, saveFigs)
%
% rd_plotMPROIConnectivity(roi1Name, analStr, scanName, voxelSelection, seedHemi, measures, saveFigs)
%
% Example inputs:
% roi1Name = 'lgnROI1_M';
% analStr = 'rfng';
% scanName = 'fix 1';
% voxelSelection = 'all';
% seedHemi = 1; % will plot connectivity between M and P ROIs in this hemisphere and all other ROIs
% measures = {'roiCorr','roiCoh'};

%% deal with inputs
if nargin<4 || isempty(voxelSelection)
    voxelSelection = '';
    fprintf('\nNo voxelSelection string given -- will not appear in plot\n\n')
end
if nargin<5 || isempty(seedHemi)
    seedHemi = 1;
    fprintf('\nSetting seedHemi to 1 by default\n\n')
end
if nargin<6 || isempty(measures)
    measures = {'roiCorr'};
end
if nargin<7 || isempty(saveFigs)
    saveFigs = 0;
end

if seedHemi==1
    seedHemiStr = 'L';
elseif seedHemi==2
    seedHemiStr = 'R';
else
    error('seedHemi not recognized')
end

%% determine scan type
if strfind(scanName,'fix')
    scanType = 'f';
elseif strfind(scanName,'M')
    scanType = 'm';
elseif strfind(scanName,'P')
    scanType = 'p';
else
    error('scanName not recognized')
end
scanName(strfind(scanName,' ')) = '';

%% find and load data (results of mrMeanCorrelation analysis)
dataDir = sprintf('ConnectivityAnalysis/left-right');
dataFileTemplate = sprintf('%s_%s_etal_%s_*', scanName, roi1Name, analStr);
dataFile = dir(sprintf('%s/%s', dataDir, dataFileTemplate));

if numel(dataFile)==1
    C = load(sprintf('%s/%s', dataDir, dataFile.name));
else
    error('Too many or too few data files.')
end

%% ROIs
roiNames = C.rois;

mROIPatt = sprintf('lgnROI%d\\S*M$', seedHemi); % regexp: any non-whitespace character (\S) (\\ because appears in sprintf statement) any number of times (*) with M at the end (M$)
pROIPatt = sprintf('lgnROI%d\\S*P$', seedHemi);

mpIdx(1) = find(~cellfun('isempty', regexp(roiNames, mROIPatt))); 
mpIdx(2) = find(~cellfun('isempty', regexp(roiNames, pROIPatt)));
% mpIdx(1) = find(strcmp(roiNames,'lgnROI2_M'));
% mpIdx(2) = find(strcmp(roiNames,'lgnROI2_P'));

nonMPIdx = 1:numel(roiNames);
nonMPIdx = setdiff(nonMPIdx, mpIdx);

%% Fig file I/O
figDir = sprintf('ConnectivityAnalysis/figures/%s/left-right', scanName);
roiSetName = sprintf('%s_etal',roi1Name);
figFileBase = sprintf('mpROIBars_%s_%s_%s_%s', roiSetName, analStr, voxelSelection, seedHemiStr);

%% colors
fixCol = [.3 .3 .3]; % gray
MCol = [220 20 60]./255; % red
PCol = [0 0 205]./255; % medium blue
colors = {MCol, PCol};

switch scanType
    case 'f'
        scanColor = fixCol;
    case 'm'
        scanColor = MCol;
    case 'p'
        scanColor = PCol;
    otherwise
        error('scanType not recognized')
end

%% just M and P connectivity
for iM = 1:numel(measures)
    m = measures{iM};
    mpC.(m) = C.results.(m)(:,mpIdx);
    
    % M ROI - P ROI connectivity difference
    mpD.(m) = mpC.(m)(:,1) - mpC.(m)(:,2);
end

%% plot just M ROI and P ROI connectivity
for iM = 1:numel(measures)
    f1(iM) = figure;
    m = measures{iM};

    bar(mpC.(m)(nonMPIdx,:))
    colormap([colors{1}; colors{2}])
    ylabel(m)
    title(sprintf('%s scan', scanName))
    legend('M ROI','P ROI')

    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(nonMPIdx))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s %s', analStr, voxelSelection, seedHemiStr));
    rd_raiseAxis(gca);
end

%% plot M-P ROI connectivity difference
for iM = 1:numel(measures)
    f2(iM) = figure; 
    m = measures{iM};
    vals = mpD.(m)(nonMPIdx,:);
    bar(vals)
    colormap(scanColor)
    ylabel('connectivity difference (M ROI - P ROI)')
    legend(sprintf('%s scan', scanName),'Location','best')

    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(nonMPIdx))
    rotateticklabel(gca);
    title(sprintf('%s %s %s %s %s', roi1Name, m(4:end), analStr, voxelSelection, seedHemiStr));
end

%% save figures
if saveFigs
    for iF = 1:numel(f1)
        figFilePath = sprintf('%s/%s_%s_mpc', ...
            figDir, figFileBase, measures{iF});
        print(f1(iF), '-djpeg', figFilePath)
    end
    for iF = 1:numel(f2)
        figFilePath = sprintf('%s/%s_%s_mpd', ...
            figDir, figFileBase, measures{iF});
        print(f2(iF), '-djpeg', figFilePath)
    end
end
