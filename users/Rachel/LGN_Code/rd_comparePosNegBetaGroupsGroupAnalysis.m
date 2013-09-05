% rd_comparePosNegBetaGroupsGroupAnalysis.m

%% setup
scanner = '3T';

[subjectDirs3T subjectDirs7T] = rd_lgnSubjects;
switch scanner
    case '3T'
        subjectDirs = subjectDirs3T;
        subjects = [1 2 4 5];
    case '7T'
        subjectDirs = subjectDirs7T;
        subjects = [1:5 7 8];
end
nSubjects = numel(subjects);

%% run analysis on each subject
for hemi = 1:2
    for iSubject = 1:nSubjects
        subject = subjects(iSubject);
        
        [fpath fdir] = rd_getAnalysisFilePath(subjectDirs, scanner, subject);
        
        % go to subject directory
        cd(fdir)
        
        [nVox(iSubject,:,hemi), varExp(iSubject,:,hemi), groupLabels] = rd_comparePosNegBetaGroups(hemi);
    end
end

%% calculate some things
nVoxMean = mean(nVox);
nVoxSte = std(nVox)./sqrt(nSubjects);

varExpMean = nanmean(varExp);
varExpSte = nanstd(varExp)./sqrt(nSubjects);
mean(varExpMean,3)

totalVox = sum(nVox,2);
propBothNeg = nVox(:,end,:)./totalVox;
mean(propBothNeg(:))

nVoxHemi = [nVox(:,:,1); nVox(:,:,2)];
varExpHemi = [varExp(:,:,1); varExp(:,:,2)];

%% plot figs
%% individual subjects
figure
for hemi = 1:2
    subplot(1,2,hemi)
    bar(nVox(:,:,hemi)')
    set(gca,'XTickLabel',groupLabels)
    ylabel('number of voxels')
    legend(num2str(subjects'))
    title(sprintf('hemi %d', hemi))
end

figure
for hemi = 1:2
    subplot(1,2,hemi)
    bar(varExp(:,:,hemi)')
    set(gca,'XTickLabel',groupLabels)
    ylabel('mean variance explained')
    legend(num2str(subjects'))
    title(sprintf('hemi %d', hemi))
end

%% mean across subjects
figure
barweb(squeeze(nVoxMean), squeeze(nVoxSte))
set(gca,'XTickLabel',groupLabels)
ylabel('number of voxels')
legend('left LGN','right LGN')
title(sprintf('%s subjects %s', scanner, num2str(subjects)))

figure
barweb(squeeze(varExpMean), squeeze(varExpSte))
set(gca,'XTickLabel',groupLabels)
ylabel('variance explained')
legend('left LGN','right LGN')
title(sprintf('%s subjects %s', scanner, num2str(subjects)))

%% mean across hemispheres
figure
hold on
bar(mean(nVoxHemi))
errorbar(mean(nVoxHemi), std(nVoxHemi)/sqrt(nSubjects*2),'k','LineStyle','none')
set(gca,'XTick',1:numel(groupLabels))
set(gca,'XTickLabel',groupLabels)
ylabel('number of voxels')
title(sprintf('%s subjects %s', scanner, num2str(subjects)))

figure
hold on
bar(nanmean(varExpHemi))
errorbar(nanmean(varExpHemi), nanstd(varExpHemi)/sqrt(nSubjects*2),'k','LineStyle','none')
set(gca,'XTick',1:numel(groupLabels))
set(gca,'XTickLabel',groupLabels)
set(gca, 'YTickLabel', num2str(get(gca, 'YTick')'))
ylabel('variance explained')
title(sprintf('%s subjects %s', scanner, num2str(subjects)))
