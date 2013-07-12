% rd_mrMakeMPROIFromGroupCoords.m

load lgnROI1_comVoxGroupCoords_betaM-P_prop20_varThresh000_20121114

groupNames = {'lgnROI1_M','lgnROI1_P'};
saveROI = 1;

% get coords from each group
groups = unique(voxGroups);
for iGroup = 1:numel(groups)
    group = groups(iGroup);
    groupCoords{iGroup} = voxCoords(voxGroups==group,:);
end

% add name and coords to ROIs
for iGroup = 1:numel(groups)
    name = groupNames{iGroup};
    coords = groupCoords{iGroup}';    
    ROI = rd_mrNewROI('Inplane', name, coords);
    
    % save ROI
    if saveROI
        roiSavePath = sprintf('../../Inplane/ROIs/%s',ROI.name);
        save(roiSavePath,'ROI');
    end
end
    