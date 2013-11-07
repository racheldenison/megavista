% rd_connectivityGroupAnalysis.m

%% Setup
% these three determine roi1Name
% same for everyone if we're using left-right analysis
hemi = 1;
mapName = 'betaM-P';
groupName = 'M';

analStr = 'rfng';
measures = {'roiCorr'}; % 'roiCorr','roiCoh' (any combination)
m = measures{1}; % for now, we don't loop over measures anywhere

scanName = 'fix*'; % 'fix*', 'fix1', 'M1', 'P1', 'mp_blankCond'
voxelSelection = 'extreme'; % 'all','extreme','varthresh'
seedHemi = 1; % plot connectivity between M and P ROIs in this hemisphere and all other ROIs

fileBase = sprintf('lgnROI%d', hemi);

% right now, these apply to groupMPD only
collapseLRLGN = 1;
collapseLRCortex = 1;

%% Determine ROI1 name for selected options
switch voxelSelection
    case 'all'
        prop = .2;
        varThresh = 0;
        mpROIs = 1:4;
    case 'extreme'
        prop = .1;
        varThresh = 0;
        mpROIs = 5:8;
    otherwise
        error('voxelSelection not recognized')
end

threshDescrip = sprintf('%0.03f', varThresh);
voxDescrip = ['varThresh' threshDescrip(3:end)];
    
[subjectDirs3T subjectDirs7T] = rd_lgnSubjects;

%% Get standard ROI list
roiListPath = '/Volumes/Plata1/LGN/XLS/Connectivity_ROIs.csv';
fid = fopen(roiListPath);
rois = textscan(fid, '%s');
rois = rois{1};
fclose(fid);
nROIs = numel(rois);

%% Loop through scanners and subjects
cIdx = 1;
for scannerType = {'3T','7T'}
    
    scanner = scannerType{1};
    
    switch scanner
        case '3T'
            subjectDirs = subjectDirs3T;
%             subjects = [1 2 5];
            subjects = [];
        case '7T'
            subjectDirs = subjectDirs7T;
%             subjects = [2 4 11 12 13 14];
            subjects = [11 12 14];
%             subjects = [2 4 11 12];
%             subjects = [];
    end
    
    nSubjects = numel(subjects);
    
    %% load all data
    for iSubject = 1:nSubjects
        subject = subjects(iSubject);
        
        [fpath fdir fname sessdir] = rd_getAnalysisFilePath(subjectDirs, scanner, subject);
        
        % go to session directory
        cd(sessdir)
        
        if any(subject == [13 14]) && strcmp(voxelSelection,'all')
            roi1Name = sprintf('%s_%s', fileBase, groupName);
        else
            roi1Name = sprintf('%s_%s_prop%d_%s_group%s', ...
                fileBase, mapName, round(prop*100), voxDescrip, groupName);
        end
        
        %% find and load data (results of mrMeanCorrelation analysis)
        dataDir = sprintf('ConnectivityAnalysis/left-right');
        dataFileTemplate = sprintf('%s_%s_etal_%s_*', scanName, roi1Name, analStr);
        dataFile = dir(sprintf('%s/%s', dataDir, dataFileTemplate));
        
        if numel(dataFile)==1
            ctemp = load(sprintf('%s/%s', dataDir, dataFile.name));
            if isfield(ctemp,'exptInfo')
                ctemp = rmfield(ctemp,'exptInfo');
            end
            C(cIdx) = ctemp;
        else
            error('Too many or too few data files.')
        end 
        cIdx = cIdx + 1;
    end
end

%% Put connectivity data into a standard ROI matrix for all subjects
% if name is lgnROI1_M, then change to
% lgnROI1_betaM-P_prop20_varThresh000_groupM
groupData.(m) = nan(nROIs,nROIs,numel(C));
for iC = 1:numel(C)
    subROIs = C(iC).rois;
    for iSubROI = 1:numel(subROIs)
        roi1 = subROIs{iSubROI};
        roi1 = rd_expandMPROIName(roi1);
        roi1StdIdx = find(strcmp(roi1, rois));
        for jSubROI = 1:numel(subROIs)
            roi2 = subROIs{jSubROI};
            roi2 = rd_expandMPROIName(roi2);
            roi2StdIdx = find(strcmp(roi2, rois));
            
            % plug the connectivity value into the right place in the standard matrix
            val = C(iC).results.(m)(iSubROI, jSubROI);
            groupData.(m)(roi1StdIdx, roi2StdIdx, iC) = val;
        end
    end
end

%% Unify V4s and V3ABs
% copy data from first listed ROI to rows and cols for second listed ROI
for iC = 1:numel(C)
    groupData.(m)(:,:,iC) = rd_connectivityUnifyROIs(...
        groupData.(m)(:,:,iC), rois, C(iC).rois, 'LV4_cons', 'LV4');
    groupData.(m)(:,:,iC) = rd_connectivityUnifyROIs(...
        groupData.(m)(:,:,iC), rois, C(iC).rois, 'RV4_cons', 'RV4');
    groupData.(m)(:,:,iC) = rd_connectivityUnifyROIs(...
        groupData.(m)(:,:,iC), rois, C(iC).rois, 'LV3A', 'LV3AB');
    groupData.(m)(:,:,iC) = rd_connectivityUnifyROIs(...
        groupData.(m)(:,:,iC), rois, C(iC).rois, 'RV3A', 'RV3AB');
end

%% just M and P connectivity
for iC = 1:numel(C)
    mpC(iC).(m) = groupData.(m)(:,mpROIs,iC);
    
    % M ROI - P ROI connectivity difference
    mpD(iC).(m)(:,1) = mpC(iC).(m)(:,1) - mpC(iC).(m)(:,3); % left LGN
    mpD(iC).(m)(:,2) = mpC(iC).(m)(:,2) - mpC(iC).(m)(:,4); % right LGN
    
    groupMPC.(m)(:,:,iC) = mpC(iC).(m);
    groupMPD.(m)(:,:,iC) = mpD(iC).(m);
end

%% Hack to collapse across left and right LGN
if collapseLRLGN
    groupMPD.(m) = mean(groupMPD.(m),2);
end
if collapseLRCortex
    groupMPD.(m) = (groupMPD.(m)(1:2:end,:,:) + groupMPD.(m)(2:2:end,:,:))/2;
end

%% Special conglomeration of select areas (for figure)
% after collapsing LR LGN and cortex
earlyVis = groupMPD.(m)(5:9,:,:);
V4 = groupMPD.(m)(10,:,:);
MT = groupMPD.(m)(16,:,:);
LO = groupMPD.(m)(18:19,:,:);
specialData = [squeeze(mean(earlyVis,1)) squeeze(mean(MT,1)) squeeze(mean(LO,1))];
specialMean = mean(specialData);
specialSte = std(specialData)./sqrt(size(specialData,1));

figure
hold on
bar(specialMean)
errorbar(specialMean, specialSte,'k','LineStyle','None')
set(gca,'XTick',1:numel(specialMean))
set(gca,'XTickLabel',{'V1-V3','MT','LO'})
ylabel('connectivity difference (M ROI - P ROI)')

%% Group connectivity data
% groupMean.(m) = nanmean(groupData.(m),3);
groupMean.(m) = mean(groupData.(m),3);
groupSte.(m) = std(groupData.(m),0,3)./sqrt(numel(C));
groupN.(m) = sum(~isnan(groupData.(m)),3);

groupMPDMean.(m) = mean(groupMPD.(m),3);
groupMPDSte.(m) = std(groupMPD.(m),0,3)./sqrt(numel(C));

%% Plot correlation
vals = groupMean.(m);
removeNanRows = 0;
if removeNanRows
    [vals nanrows] = rd_removeNanRowsCols(vals);
    roiNames = rois(~nanrows);
else
    roiNames = rois;
end
f(1) = figure;
clim = rd_zeroCenterCLim(vals);
% imagesc(tril((m)),clim);
imagesc(vals,clim);
axis equal
axis tight
title(sprintf('Correlation %s %s\n%s', scanName, analStr, voxelSelection),...
    'Color','k','FontSize',12,'FontWeight','demi');
colormap(rdbumap)
colorbar
set(gca,'XTick',1:numel(roiNames))
set(gca,'YTick',1:numel(roiNames))
set(gca,'XTickLabel',roiNames)
set(gca,'YTickLabel',roiNames)
rotateticklabel(gca,90,'image');

%% Plot MP ROI bars
figure
hold on
plot([0 nROIs], [0 0], '--k')
% bar(groupMean.(m)(mpROIs,:)')
errorbar(groupMean.(m)(mpROIs,:)', groupSte.(m)(mpROIs,:)')
ylabel('connectivity')
legend([{''} roiNames{mpROIs}])
set(gca,'XTick',1:numel(roiNames))
set(gca,'XTickLabel',roiNames)
rotateticklabel(gca,90);
title(sprintf('%s %s %s %s %s', roi1Name, m(4:end), analStr, voxelSelection, scanName));

%% Plot mpD
figure
hold on
if collapseLRCortex
    plot([0 nROIs/2], [0 0], '--k')
else
    plot([0 nROIs], [0 0], '--k')
end
errorbar(groupMPDMean.(m), groupMPDSte.(m))
ylabel('connectivity difference (M ROI - P ROI)')
if ~collapseLRLGN
    legend({'','left LGN','right LGN'})
end
if collapseLRCortex
    set(gca,'XTick',1:numel(roiNames)/2)
    set(gca,'XTickLabel',roiNames(1:2:end))
else
    set(gca,'XTick',1:numel(roiNames))
    set(gca,'XTickLabel',roiNames)
end
rotateticklabel(gca,90);
title(sprintf('%s %s %s %s %s', roi1Name, m(4:end), analStr, voxelSelection, scanName));

%% Plot mpD - V4 and MT
V4Idx = find(~cellfun('isempty', regexp(roiNames, 'V4'))); 
MTIdx = find(~cellfun('isempty', regexp(roiNames, 'MT'))); 

V4Vals = groupMPD.(m)(V4Idx,:,:); % first dim: L & R V4
MTVals = groupMPD.(m)(MTIdx,:,:);

figure
for iC = 1:numel(C)
    subplot(numel(C),1,iC)
    imagesc(V4Vals(:,:,iC)',[-0.3 0.3])
end
figure
for iC = 1:numel(C)
    subplot(numel(C),1,iC)
    imagesc(MTVals(:,:,iC)',[-0.3 0.3])
end


%% get superset of all ROIs
% allROIs = [];
% for iC = 1:numel(C)
%     allROIs = [allROIs, C(cIdx).rois];
% end
% uniqueROIs = unique(allROIs);
% % print ROIs to screen
% for iROI = 1:numel(uniqueROIs)
%     fprintf('\n%s',uniqueROIs{iROI})
% end