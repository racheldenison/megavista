% rd_connectivityGroupAnalysis.m

%% Setup
% these three determine roi1Name
% same for everyone if we're using left-right analysis
hemi = 1;
mapName = 'betaM-P';
groupName = 'M';

analStr = 'rfng';
measures = {'roiCorr'}; % 'roiCorr','roiCoh' (any combination)

scanName = 'fix1'; % 'fix1', 'M1', 'P1', 'mp_blankCond'
voxelSelection = 'all'; % 'all','extreme','varthresh'
seedHemi = 1; % plot connectivity between M and P ROIs in this hemisphere and all other ROIs

fileBase = sprintf('lgnROI%d', hemi);

roiListPath = '/Volumes/Plata1/LGN/XLS/Connectivity_ROIs.csv';

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

% roi1Name = sprintf('%s_%s', fileBase, groupName);
roi1Name = sprintf('%s_%s_prop%d_%s_group%s', ...
    fileBase, mapName, round(prop*100), voxDescrip, groupName);
       
[subjectDirs3T subjectDirs7T] = rd_lgnSubjects;

%% Loop through scanners and subjects
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
            subjects = [13 14];
    end
    
    nSubjects = numel(subjects);
    
    %% get superset of all ROIs
%     allROIs = [];
    for iSubject = 1:nSubjects
        subject = subjects(iSubject);
        
        [fpath fdir fname sessdir] = rd_getAnalysisFilePath(subjectDirs, scanner, subject);
        
        % go to session directory
        cd(sessdir)
        
        %% find and load data (results of mrMeanCorrelation analysis)
        dataDir = sprintf('ConnectivityAnalysis/left-right');
        dataFileTemplate = sprintf('%s_%s_etal_%s_*', scanName, roi1Name, analStr);
        dataFile = dir(sprintf('%s/%s', dataDir, dataFileTemplate));
        
        if numel(dataFile)==1
            C = load(sprintf('%s/%s', dataDir, dataFile.name));
        else
            error('Too many or too few data files.')
        end
        
%         allROIs = [allROIs, C.rois];
    end
end

% uniqueROIs = unique(allROIs);
% %% print ROIs to screen
% for iROI = 1:numel(uniqueROIs)
%     fprintf('\n%s',uniqueROIs{iROI})
% end