function [nVoxInGroup, varExpInGroup, groupLabels] =  rd_comparePosNegBetaGroups(hemi)
%
% divide voxels into 4 groups based on M and P beta values:
% 1) both positive
% 2) M positive, P negative
% 3) M negative, P positive
% 4) both negative
% Look at variance explained for these 4 groups

% hemi = 1;

%% File I/O
fileBase = sprintf('lgnROI%d', hemi);
analysisExtension = '_multiVoxFigData';
loadPath = sprintf('%s%s.mat', fileBase, analysisExtension);

%% Load data
load(loadPath);

%% Get betas and varexp
betas = squeeze(figData.glm.betas(1,1:2,:))';
varExp = figData.glm.varianceExplained';

%% Divide into voxel groups based on +/- beta values
bothPos = betas(:,1)>0 & betas(:,2)>0;
MPosPNeg = betas(:,1)>0 & betas(:,2)<=0;
PPosMNeg = betas(:,1)<=0 & betas(:,2)>0;
bothNeg = betas(:,1)<=0 & betas(:,2)<=0;
onePosOneNeg = MPosPNeg | PPosMNeg;

% groupLabels = {'bothPos','MPosPNeg','PPosMNeg','bothNeg'};
% groupSelectors = [bothPos, MPosPNeg, PPosMNeg, bothNeg];
groupLabels = {'bothPos','onePosOneNeg','bothNeg'};
groupSelectors = [bothPos, onePosOneNeg, bothNeg];

%% How many voxels in each group
nVoxInGroup = sum(groupSelectors);

%% Variance explained in each group
for iGroup = 1:numel(groupLabels)
    varExpInGroup(iGroup) = mean(varExp(groupSelectors(:,iGroup)));
end