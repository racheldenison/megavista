% rd_connectivityGroupAnalysis.m

%% Setup
% these three determine roi1Name
% same for everyone if we're using left-right analysis
hemi = 1;
mapName = 'betaM-P';
groupName = 'M';

analStr = 'rfng';
measures = {'roiCorr'}; % 'roiCorr','roiCoh' (any combination)

scanName = 'fix*'; % 'fix1', 'M1', 'P1', 'mp_blankCond'
voxelSelection = 'all'; % 'all','extreme','varthresh'
seedHemi = 1; % plot connectivity between M and P ROIs in this hemisphere and all other ROIs

fileBase = sprintf('lgnROI%d', hemi);

%% Determine ROI1 name for selected options
switch voxelSelection
    case 'all'
        prop = .2;
        varThresh = 0;
    case 'extreme'
        prop = .1;
        varThresh = 0;
    otherwise
        error('voxelSelection not recognized')
end

threshDescrip = sprintf('%0.03f', varThresh);
voxDescrip = ['varThresh' threshDescrip(3:end)];
    
[subjectDirs3T subjectDirs7T] = rd_lgnSubjects;

%% Get standard ROI list
roiListPath = '/Volumes/Plata1/LGN/XLS/Connectivity_ROIs.csv';
fid = fopen('/Volumes/Plata1/LGN/XLS/Connectivity_ROIs.csv');
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
            subjects = [11 12 13 14];
    end
    
    nSubjects = numel(subjects);
    
    %% load all data
    for iSubject = 1:nSubjects
        subject = subjects(iSubject);
        
        [fpath fdir fname sessdir] = rd_getAnalysisFilePath(subjectDirs, scanner, subject);
        
        % go to session directory
        cd(sessdir)
        
        if any(subject == [13 14])
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
groupData.roiCorr = nan(nROIs,nROIs,numel(C));
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
            val = C(iC).results.roiCorr(iSubROI, jSubROI);
            groupData.roiCorr(roi1StdIdx, roi2StdIdx, iC) = val;
        end
    end
end
    
%% Group connectivity data
% groupMean.roiCorr = mean(groupData.roiCorr,3);
groupMean.roiCorr = nanmean(groupData.roiCorr,3);
groupN.roiCorr = sum(~isnan(groupData.roiCorr),3);

%% Plot correlation
removeNanRows = 0;
vals = groupMean.roiCorr;
if removeNanRows
    [vals nanrows] = rd_removeNanRowsCols(vals);
    roiNames = rois(~nanrows);
else
    roiNames = rois;
end
f(1) = figure;
clim = rd_zeroCenterCLim(vals);
% imagesc(tril(roiCorr),clim);
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