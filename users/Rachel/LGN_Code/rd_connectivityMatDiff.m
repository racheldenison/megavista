% rd_connectivityMatDiff.m

f = load('ConnectivityAnalysis/steady1_lgnROI1_M_etal_rfng_20130711.mat');
m = load('ConnectivityAnalysis/steady2_lgnROI1_M_etal_rfng_20130711.mat');
p = load('ConnectivityAnalysis/steady3_lgnROI1_M_etal_rfng_20130711.mat');

analStr = f.preproc.analStr;
rois = f.rois;

% difference maps
d.mp.corr = m.results.roiCorr - p.results.roiCorr;
d.mf.corr = m.results.roiCorr - f.results.roiCorr;
d.pf.corr = p.results.roiCorr - f.results.roiCorr;

%% Plot correlation
for comp = {'mp','mf','pf'}
    measure = 'corr';
    fig(1) = figure;
    vals = d.(comp{1}).(measure);
    clim = rd_zeroCenterCLim(vals);
    imagesc(vals,clim);
    axis equal
    axis tight
    title(sprintf('%s %s %s', comp{1}, measure, analStr),...
        'Color','k','FontSize',12,'FontWeight','demi');
    colormap(rdbumap)
    colorbar
    set(gca,'XTick',1:numel(rois))
    set(gca,'YTick',1:numel(rois))
    set(gca,'XTickLabel',rois)
    set(gca,'YTickLabel',rois)
    rotateticklabel(gca,90,'image')
end