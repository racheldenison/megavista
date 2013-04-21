% rd_compareParameterMapsGroupAnalysis.m

% Should be in '/Volumes/Plata1/LGN/Group_Analyses/'

saveFigs = 1;

%% load and aggregate individual subject data
files = dir('crossSessionComparison_*');

for iComp = 1:numel(files)
    data = load(files(iComp).name);
    subjects{iComp} = data.subjectID;
    roiNames{iComp} = data.roiName;
    
    mapValCorrs(iComp) = data.mapValCorr;
    corrConfs(:,iComp) = data.corrConf;
end

nROIs = length(roiNames);

%% view subjects and ROIs
for i=1:nROIs
    fprintf('%d. %s %s\n', i, subjects{i}, roiNames{i})
end

%% figure 
% plotOrder = [1 4 7 8 2 5 3 6 9 10];
plotOrder = [1 4 2 5 3 6 7 9 8 10 11 12];

for iComp = 1:numel(mapValCorrs)
    labels{iComp} = sprintf('%s-%s', subjects{plotOrder(iComp)}, ...
        roiNames{plotOrder(iComp)});
end

f1 = figure;
hold on
bar(1:numel(mapValCorrs), mapValCorrs(plotOrder))
errorbar(1:numel(mapValCorrs), mapValCorrs(plotOrder), ...
    mapValCorrs(plotOrder)-corrConfs(1,plotOrder), ...
    corrConfs(2,plotOrder)-mapValCorrs(plotOrder), ...
    'r','LineWidth',2,'LineStyle','None')
xlim([0 numel(mapValCorrs)+1])
set(gca,'XTick', 1:numel(mapValCorrs))
set(gca,'XTickLabel',labels)
ylabel('correlation with 95% confidence interval')

%% save fig
if saveFigs
    print(f1,'-djpeg',...
        sprintf('figures/groupCrossSessionComparison_NROIs%d_betaM-P_correlation_%s',...
        nROIs, datestr(now,'yyyymmdd')));
end

%% stats
% get indices from bar graph (plot order)
withinFieldComparisons = [1 2 7 8];
betweenFieldComparisons = [3:6 9:12];
comparisonsToExclude = 4:6;

wfIdx = setdiff(withinFieldComparisons, comparisonsToExclude);
bfIdx = setdiff(betweenFieldComparisons, comparisonsToExclude);

vals = mapValCorrs(plotOrder);

wfvals = vals(wfIdx);
bfvals = vals(bfIdx);

wfMean = mean(wfvals);
bfMean = mean(bfvals);
allMean = mean([wfvals bfvals]);

% are within-field correlations different from between-field correlations?
[h p ci stat] = ttest2(wfvals, bfvals);
