% rd_runMetacontrastMVPA.m

% assume we're in a directory named for the ROI being analyzed
[upDir, ROI] = fileparts(pwd);

soaCodes = 1:7;
thresh = 1;

for iSOA = 1:numel(soaCodes)
    soaCode = soaCodes(iSOA);
    [perf(:,iSOA), nvox(:,iSOA)] = rd_metacontrastMVPA(soaCode, thresh);
end

perfMean = mean(perf);
perfSte = std(perf)./sqrt(size(perf,1));

figure
hold on
plot([soaCodes(1) soaCodes(end)], [.5 .5], '--k')
errorbar(soaCodes, perfMean, perfSte)
ylim([.3 .8])
xlabel('SOA code')
ylabel('classification performance')
title(sprintf('%s, ANOVA p < %s', ROI, num2str(thresh)))