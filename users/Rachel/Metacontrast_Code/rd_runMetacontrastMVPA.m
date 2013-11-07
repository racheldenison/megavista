% rd_runMetacontrastMVPA.m

%% many SOAs
% assume we're in a directory named for the ROI being analyzed
[upDir, ROI] = fileparts(pwd);
[a b] = fileparts(fileparts(upDir));
subjectID = b(1:2);

soaCodes = 1:7;
thresh = 1;

perf = []; nvox = [];
for iSOA = 1:numel(soaCodes)
    soaCode = soaCodes(iSOA);
    [perf(:,iSOA), nvox(:,iSOA)] = rd_metacontrastMVPA(subjectID, soaCode, thresh);
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

%% many thresholds
% assume we're in a directory named for the ROI being analyzed
[upDir, ROI] = fileparts(pwd);
[a b] = fileparts(fileparts(upDir));
subjectID = b(1:2);

soaCode = 6;
% threshs = [0.01 0.05 0.1 0.2 0.5 1];
threshs = [0.2 0.5 1];

perf = []; nvox = [];
for iThresh = 1:numel(threshs)
    thresh = threshs(iThresh);
    [perf(:,iThresh), nvox(:,iThresh)] = rd_metacontrastMVPA(subjectID, soaCode, thresh);
end

perfMean = mean(perf);
perfSte = std(perf)./sqrt(size(perf,1));

figure
hold on
plot([threshs(1) threshs(end)], [.5 .5], '--k')
errorbar(threshs, perfMean, perfSte)
ylim([.3 .8])
xlabel('ANOVA threshold for voxel selection')
ylabel('classification performance')
title(sprintf('%s, SOA code %d', ROI, soaCode))
