% rd_connectivityMatDiff.m

hemi = 1;
voxelSelection = 'all'; % 'all','varexp','extreme'

lgnROI = sprintf('lgnROI%d', hemi);
switch hemi
    case 1
        varthresh = '040';
    case 2
        varthresh = '050';
end
switch voxelSelection
    case 'all'
        analysisExt = 'M_etal_rfng_20130806';
    case 'extreme'
        analysisExt = 'betaM-P_prop10_varThresh000_groupM_etal_rfng_201300806';
    case 'varexp'
        analysisExt = sprintf('betaM-P_prop20_varThresh%s_groupM_etal_rfng_20130807', varthresh);
    otherwise
        error('voxelSelection not recognized')
end

F = load(sprintf('ConnectivityAnalysis/left-right/fix1_%s_%s.mat', lgnROI, analysisExt));
M = load(sprintf('ConnectivityAnalysis/left-right/M1_%s_%s.mat', lgnROI, analysisExt));
P = load(sprintf('ConnectivityAnalysis/left-right/P1_%s_%s.mat', lgnROI, analysisExt));

analStr = F.preproc.analStr;
rois = F.rois;
measures = {'roiCorr'}; %{'roiCorr','roiCoh'};
scanTypes = {'f','m','p'};
comps = {'mf','pf','mp'};
w = [1 -1]';

roiNames = rois;
roiNames{1} = sprintf('%s_M', lgnROI);
roiNames{2} = sprintf('%s_P', lgnROI);

fixCol = [.3 .3 .3]; % gray
MCol = [220 20 60]./255; % red
PCol = [0 0 205]./255; % medium blue
colors = {MCol, PCol};

%% just M and P connectivity
for measure = measures
    m = measure{1};
    mpC.f.(m) = F.results.(m)(:,1:2);
    mpC.m.(m) = M.results.(m)(:,1:2); 
    mpC.p.(m) = P.results.(m)(:,1:2);
    
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

%% plot just M and P connectivity
iF = 1;
for measure = measures
    f2(iF) = figure; iF = iF + 1;
    m = measure{1};
    for iST = 1:numel(scanTypes)
        st = scanTypes{iST};
        subplot(numel(scanTypes),1,iST)
        bar(mpC.(st).(m)(3:end,:))
        colormap([colors{1}; colors{2}])
        ylabel(m)
        title(sprintf('%s scan', st))
        if iST==1
            legend('M ROI','P ROI')
        end
    end
    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(3:end))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s', analStr, voxelSelection));
    rd_raiseAxis(gca);
end

%% plot M-P ROI connectivity difference
iF = 1;
for measure = measures
    f3(iF) = figure; iF = iF + 1;
    m = measure{1};
    vals = mpD.(m)(3:end,:);
    bar(vals)
    colormap([fixCol; colors{1}; colors{2}])
    ylabel('connectivity difference (M ROI - P ROI)')
    legend({'fix scan','M scan','P scan'},'Location','best')
    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(3:end))
    rotateticklabel(gca);
    title(sprintf('%s %s %s %s', lgnROI, m(4:end), analStr, voxelSelection));
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
        vals = vals(3:end,1:2);
        bar(vals);
        colormap([colors{1}; colors{2}])
        ylabel(m)
        title(sprintf('%s difference', comp))
        if iComp==1
            legend('M ROI','P ROI')
        end
    end
    set(gca,'XTick',1:numel(roiNames)-2)
    set(gca,'XTickLabel',roiNames(3:end))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s', analStr, voxelSelection));
    rd_raiseAxis(gca);
end
        
        