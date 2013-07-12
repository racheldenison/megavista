% rd_connectivityMatDiff.m

voxelSelection = 'all';

switch voxelSelection
    case 'all'
        analysisExt = 'lgnROI1_M_etal_rfng_20130711';
    case 'extreme'
        analysisExt = 'lgnROI1_betaM-P_prop10_varThresh000_groupM_etal_rfng_20130712';
    case 'varexp'
        analysisExt = 'lgnROI1_betaM-P_prop10_varThresh000_groupM_etal_rfng_20130712';
    otherwise
        error('voxelSelection not recognized')
end

F = load(sprintf('ConnectivityAnalysis/steady1_%s.mat', analysisExt));
M = load(sprintf('ConnectivityAnalysis/steady2_%s.mat', analysisExt));
P = load(sprintf('ConnectivityAnalysis/steady3_%s.mat', analysisExt));

analStr = F.preproc.analStr;
rois = F.rois;
measures = {'roiCorr','roiCoh'}; %{'roiCorr','roiCoh'};
scanTypes = {'f','m','p'};
comps = {'mf','pf','mp'};
w = [1 -1]';

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

%% Plot correlation
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
        set(gca,'XTick',1:numel(rois))
        set(gca,'YTick',1:numel(rois))
        set(gca,'XTickLabel',rois)
        set(gca,'YTickLabel',rois)
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
    set(gca,'XTickLabel',rois(3:end))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s', analStr, voxelSelection));
    rd_raiseAxis(gca);
end

%% plot M-P ROI connectivity difference
iF = 1;
for measure = measures
    f3(iF) = figure; iF = iF + 1;
    m = measure{1};
    bar(mpD.(m))
    ylabel('connectivity difference (M ROI - P ROI)')
    legend({'fix scan','m scan','p scan'})
    legend({'fix scan','M scan','P scan'})
    set(gca,'XTickLabel',rois)
    set(gca,'XTickLabel',rois)
    rotateticklabel(gca);
    title(sprintf('%s %s %s', m(4:end), analStr, voxelSelection));
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
    set(gca,'XTickLabel',rois(3:end))
    rotateticklabel(gca);
    rd_supertitle(sprintf('%s %s', analStr, voxelSelection));
    rd_raiseAxis(gca);
end
        
        