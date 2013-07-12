% rd_connectivityMatDiff.m

F = load('ConnectivityAnalysis/steady1_lgnROI1_M_etal_rfng_20130711.mat');
M = load('ConnectivityAnalysis/steady2_lgnROI1_M_etal_rfng_20130711.mat');
P = load('ConnectivityAnalysis/steady3_lgnROI1_M_etal_rfng_20130711.mat');

analStr = F.preproc.analStr;
rois = F.rois;
measures = {'roiCorr','roiCoh'};

%% difference maps
for measure = measures
    m = measure{1};
    d.mp.(m) = M.results.(m) - P.results.(m);
    d.mf.(m) = M.results.(m) - F.results.(m);
    d.pf.(m) = P.results.(m) - F.results.(m);
end

%% Plot correlation
for comp = {'mp','mf','pf'}
    for measure = measures
        m = measure{1};
        fig(1) = figure;
        vals = d.(comp{1}).(m);
        clim = rd_zeroCenterCLim(vals);
        imagesc(vals,clim);
        axis equal
        axis tight
        title(sprintf('%s %s %s', comp{1}, m(4:end), analStr),...
            'Color','k','FontSize',12,'FontWeight','demi');
        colormap(rdbumap)
        colorbar
        set(gca,'XTick',1:numel(rois))
        set(gca,'YTick',1:numel(rois))
        set(gca,'XTickLabel',rois)
        set(gca,'YTickLabel',rois)
        rotateticklabel(gca,90,'image')
    end
end

%% Plot M and P rows
for comp = {'mp','mf','pf'}
    for measure = measures
        m = measure{1};
        fig(1) = figure;
        vals = d.(comp{1}).(m);
        vals = vals(:,1:2);
        bar(vals);
        set(gca,'XTickLabel',rois)
        rotateticklabel(gca,90)
        title(sprintf('%s %s %s', comp{1}, m(4:end), analStr),...
            'Color','k','FontSize',12,'FontWeight','demi');
    end
end
        
        
        
        