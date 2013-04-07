function fO = rd_plotMeanIndivRunFStats(hemi, plotFigs, subject)

fFiles = dir(sprintf('lgnROI%d_%s', hemi, 'fTests_run*'));
nRuns = numel(fFiles);
for iRun = 1:nRuns
    load(fFiles(iRun).name)
    fOverallMeans(:,:,iRun) = F.overallMean;
end
fO = squeeze(fOverallMeans)';

if plotFigs
    figure; errorbar(mean(fO),std(fO)./sqrt(size(fO,1))); title(subject)
end
