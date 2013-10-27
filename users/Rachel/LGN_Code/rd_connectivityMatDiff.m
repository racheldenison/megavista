function rd_connectivityMatDiff(voxelSelection, seedHemi)

%% setup
% for getting the right data file
hemi = 1;
mapName = 'betaM-P';
groupName = 'M';
% voxelSelection = 'all'; % 'all','varexp','extreme'

% for choosing which lgnROIs to use as seeds
% seedHemi = 2;

scanSet = 'steady'; % 'steady' or 'mpBlock'

% which ROIs to plot connectivity for
selectedROIs = [];
% selectedROIs = 'MP';
% selectedROIs = {'LV4_cons','LV4_lib','LhMTplus',...
%     'RV4_cons','RV4_lib','RhMTplus'}; 

plotAllFigs = 0;

%% find and load data
lgnROI = sprintf('lgnROI%d', hemi);
% switch hemi
%     case 1
%         varthresh = '040';
%     case 2
%         varthresh = '050';
% end
switch voxelSelection
    case 'all'
        prop = 0.2;
        varThresh = 0;
%         analysisExt = 'M_etal_rfng_20130806';
%         analysisExt = 'M_etal_rfng_20130809';
    case 'extreme'
        prop = 0.1;
        varThresh = 0;
%         analysisExt = 'betaM-P_prop10_varThresh000_groupM_etal_rfng_20130806';
    case 'varexp'
        prop = 0.2;
%         analysisExt = sprintf('betaM-P_prop20_varThresh%s_groupM_etal_rfng_20130806', varthresh);
    otherwise
        error('voxelSelection not recognized')
end

threshDescrip = sprintf('%0.03f', varThresh);
voxDescrip = ['varThresh' threshDescrip(3:end)];
            
analysisExt = sprintf('%s_prop%d_%s_group%s', ...
    mapName, round(prop*100), voxDescrip, groupName);

switch scanSet
    case 'steady'
        fScan = dir(sprintf('ConnectivityAnalysis/left-right/fix_allscans_%s_%s_*.mat', lgnROI, analysisExt));
        mScan = dir(sprintf('ConnectivityAnalysis/left-right/M1_%s_%s_*.mat', lgnROI, analysisExt));
        pScan = dir(sprintf('ConnectivityAnalysis/left-right/P1_%s_%s_*.mat', lgnROI, analysisExt));
    case 'mpBlock'
        fScan = dir(sprintf('ConnectivityAnalysis/left-right/mp_blankCond_%s_%s_*.mat', lgnROI, analysisExt));
        mScan = dir(sprintf('ConnectivityAnalysis/left-right/mp_MCond_%s_%s_*.mat', lgnROI, analysisExt));
        pScan = dir(sprintf('ConnectivityAnalysis/left-right/mp_PCond_%s_%s_*.mat', lgnROI, analysisExt));
    otherwise
        error('scanSet not recognized')
end

F = load(sprintf('ConnectivityAnalysis/left-right/%s', fScan.name));
M = load(sprintf('ConnectivityAnalysis/left-right/%s', mScan.name));
P = load(sprintf('ConnectivityAnalysis/left-right/%s', pScan.name));

analStr = F.preproc.analStr;
rois = F.rois;
measures = {'roiCorr'}; %{'roiCorr','roiCoh'};
scanTypes = {'f','m','p'};
comps = {'mf','pf','mp'};
w = [1 -1]';

if seedHemi==1
    seedHemiStr = 'L';
elseif seedHemi==2
    seedHemiStr = 'R';
else
    error('seedHemi not recognized')
end

%% rois
roiNames = rois;
% roiNames{1} = sprintf('%s_M', lgnROI);
% roiNames{2} = sprintf('%s_P', lgnROI);

mROIPatt = sprintf('lgnROI%d\\S*M$', seedHemi); % regexp: any non-whitespace character (\S) (\\ because appears in sprintf statement) any number of times (*) with M at the end (M$)
pROIPatt = sprintf('lgnROI%d\\S*P$', seedHemi);

mpIdx(1) = find(~cellfun('isempty', regexp(roiNames, mROIPatt)));
mpIdx(2) = find(~cellfun('isempty', regexp(roiNames, pROIPatt)));

if isempty(selectedROIs)
    nonMPIdx = 1:numel(roiNames);
elseif strcmp(selectedROIs,'MP')
    nonMPIdx = find(~cellfun('isempty',strfind(roiNames, 'lgnROI')));
else
    nonMPIdx = zeros(1,numel(selectedROIs));
    for iROI = 1:numel(selectedROIs)
        nonMPIdx(iROI) = find(strcmp(roiNames,selectedROIs{iROI}));
    end
end
nonMPIdx = setdiff(nonMPIdx, mpIdx);

%% colors
fixCol = [.3 .3 .3]; % gray
MCol = [220 20 60]./255; % red
PCol = [0 0 205]./255; % medium blue
colors = {MCol, PCol};

%% just M and P connectivity
for measure = measures
    m = measure{1};
    mpC.f.(m) = F.results.(m)(:,mpIdx);
    mpC.m.(m) = M.results.(m)(:,mpIdx);
    mpC.p.(m) = P.results.(m)(:,mpIdx);
    
    % M ROI - P ROI connectivity difference
    mpD.(m) = [mpC.f.(m)*w mpC.m.roiCorr*w mpC.p.(m)*w];
end

%% difference maps
for measure = measures
    m = measure{1};
    d.mp.(m) = M.results.(m) - P.results.(m);
    d.mf.(m) = M.results.(m) - F.results.(m);
    d.pf.(m) = P.results.(m) - F.results.(m);
end

%% Plot difference maps
if plotAllFigs
    iF = 1;
    for comp = {'mp','mf','pf'}
        for measure = measures
            m = measure{1};
            f1(iF) = figure; iF = iF + 1;
            vals = d.(comp{1}).(m);
            clim = rd_zeroCenterCLim(vals);
            imagesc(vals,clim);
            axis equal
            axis tight
            title(sprintf('%s %s %s %s', comp{1}, m(4:end), analStr, voxelSelection),...
                'Color','k','FontSize',12,'FontWeight','demi');
            colormap(rdbumap)
            colorbar
            set(gca,'XTick',1:numel(roiNames))
            set(gca,'YTick',1:numel(roiNames))
            set(gca,'XTickLabel',roiNames)
            set(gca,'YTickLabel',roiNames)
            rotateticklabel(gca,90,'image');
        end
    end
end

%% plot just M and P connectivity
if plotAllFigs
    iF = 1;
    for measure = measures
        f2(iF) = figure; iF = iF + 1;
        m = measure{1};
        for iST = 1:numel(scanTypes)
            st = scanTypes{iST};
            subplot(numel(scanTypes),1,iST)
            bar(mpC.(st).(m)(nonMPIdx,:))
            colormap([colors{1}; colors{2}])
            ylabel(m)
            title(sprintf('%s scan', st))
            if iST==1
                legend('M ROI','P ROI')
            end
        end
        set(gca,'XTick',1:numel(roiNames(nonMPIdx)))
        set(gca,'XTickLabel',roiNames(nonMPIdx))
        rotateticklabel(gca);
        rd_supertitle(sprintf('%s %s %s', analStr, voxelSelection, seedHemiStr));
        rd_raiseAxis(gca);
    end
end

%% plot M-P ROI connectivity difference
iF = 1;
for measure = measures
    f3(iF) = figure; iF = iF + 1;
    m = measure{1};
    vals = mpD.(m)(nonMPIdx,:);
    bar(vals)
    colormap([fixCol; colors{1}; colors{2}])
    ylabel('connectivity difference (M ROI - P ROI)')
    legend({'fix scan','M scan','P scan'},'Location','best')
    set(gca,'XTick',1:numel(roiNames(nonMPIdx)))
    set(gca,'XTickLabel',roiNames(nonMPIdx))
    rotateticklabel(gca);
    title(sprintf('%s %s %s %s %s', lgnROI, m(4:end), analStr, voxelSelection, seedHemiStr));
end

%% Plot M and P difference map values
iF = 1;
for measure = measures
    f4(iF) = figure; iF = iF + 1;
    m = measure{1};
    for iComp = 1:numel(comps)
        comp = comps{iComp};
        subplot(numel(comps),1,iComp)
        vals = d.(comp).(m);
        vals = vals(nonMPIdx,mpIdx);
        bar(vals);
        colormap([colors{1}; colors{2}])
        ylabel(m)
        title(sprintf('%s difference', comp))
        if iComp==1
            legend('M ROI','P ROI')
        end
    end
    set(gca,'XTick',1:numel(roiNames(nonMPIdx)))
    set(gca,'XTickLabel',roiNames(nonMPIdx))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s %s', analStr, voxelSelection, seedHemiStr));
    rd_raiseAxis(gca);
end

