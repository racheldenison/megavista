function rd_plotMPROIConnectivity(roi1Name, analStr, scanName, voxelSelection)

%% example inputs
% roi1Name = 'lgnROI1_M';
% analStr = 'rfng';
% scanName = 'fix 1';
% voxelSelection = 'all';

%% setup
if nargin==3
    voxelSelection = 'all';
end

% determine scan type
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

% find data file (results of mrMeanCorrelation analysis
dataDir = sprintf('ConnectivityAnalysis/left-right');
dataFileTemplate = sprintf('%s_%s_etal_%s_*', scanName, roi1Name, analStr);
dataFile = dir(sprintf('%s/%s', dataDir, dataFileTemplate));

if numel(dataFile)==1
    C = load(sprintf('%s/%s', dataDir, dataFile.name));
else
    error('Too many or too few data files.')
end

roiNames = C.rois;
measures = {'roiCorr','roiCoh'};

mpIdx(1) = find(strcmp(roiNames,'lgnROI2_M'));
mpIdx(2) = find(strcmp(roiNames,'lgnROI2_P'));

nonMPIdx = 1:numel(roiNames);
nonMPIdx = setdiff(nonMPIdx, mpIdx);

% colors
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
    title(sprintf('%s scan', scanType))
    legend('M ROI','P ROI')

    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(nonMPIdx))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s', analStr, voxelSelection));
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
    legend(sprintf('%s scan', scanType),'Location','best')

    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(nonMPIdx))
    rotateticklabel(gca);
    title(sprintf('%s %s %s %s', roi1Name, m(4:end), analStr, voxelSelection));
end
