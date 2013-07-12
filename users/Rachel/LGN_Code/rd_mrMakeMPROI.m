% rd_mrMakeMPROI.m

% makes M group and P group ROIs with desired setting of map type, M/P
% split, and varthresh

%% Setup
hemi = 2;
mapName = 'betaM-P';
prop = .2;
varThresh = 0.05;

groupNames = {'M','P'};

switch mapName
    case 'betaM-P'
%         prop = 0.2;
        betaCoefs = [.5 -.5];
    case 'betaM'
%         prop = 0.2;
        betaCoefs = [1 0];
    case 'betaP'
%         prop = 0.8;
        betaCoefs = [0 1];
    otherwise
        error ('mapName not recognized when setting prop and betaCoefs')
end

threshDescrip = sprintf('%0.03f', varThresh);
voxDescrip = ['varThresh' threshDescrip(3:end)];

saveROI = 1;

%% File I/O
fileBase = sprintf('lgnROI%d', hemi);
analysisExtension = '_multiVoxFigData';
loadPath = sprintf('%s%s.mat', fileBase, analysisExtension);
roiDirectory = '../../Inplane/ROIs';
roiFileBase = sprintf('%s_centerOfMass_%s_prop%d_%s', ...
    fileBase, mapName, round(prop*100), voxDescrip);

%% Load data
load(loadPath)

%% Set coordinates and associated values
coords = figData.coordsInplane';

betas = squeeze(figData.glm.betas(1,1:2,:))';
topoData = betas*betaCoefs';

%% Select voxels
voxelSelector = figData.glm.varianceExplained > varThresh;

vals = topoData(voxelSelector);

%% Divide voxels into groups
[centers voxsInGroup threshVal] = ...
    rd_findCentersOfMass(coords(voxelSelector,:), vals, prop, 'prop');

%% Get coords from each group
for iGroup = 1:size(voxsInGroup,2)
    coordsInGroup{iGroup} = coords(voxsInGroup(:,iGroup),:);
end

%% Report number of voxels in each group
nVoxInGroups = sum(voxsInGroup);
fprintf('Group 1: %d voxels\n', nVoxInGroups(1))
fprintf('Group 2: %d voxels\n', nVoxInGroups(2))
fprintf('Total:   %d voxels\n', sum(nVoxInGroups))

%% Make ROI
for iGroup = 1:numel(groupNames)
    name = groupNames{iGroup};
    fullName = sprintf('%s_group%s', roiFileBase, name);
    coords = coordsInGroup{iGroup}';    
    ROI = rd_mrNewROI('Inplane', fullName, coords);
    
    % save ROI
    if saveROI
        roiSavePath = sprintf('%s/%s.mat', roiDirectory, fullName);
        if exist(roiSavePath,'file')
            saveIt = input('ROI file already exists. Overwrite? (y,n) ','s');
        else
            saveIt = 'y';
        end
        if strcmp(saveIt,'y')
            save(roiSavePath,'ROI');
            fprintf('Saving ROI %s\n', roiSavePath) 
        else
            fprintf('Not saving ROI\n')
        end
    end
end
