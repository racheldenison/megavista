% rd_mrMakeMPROIs.m

load lgnROI1_comVoxGroupCoords_betaM-P_prop20_varThresh000_20121114

groupNames = {'lgnROI1_M','lgnROI1_P'};
color = 'b';
saveROI = 1;

% get coords from each group
groups = unique(voxGroups);
for iGroup = 1:numel(groups)
    group = groups(iGroup);
    groupCoords{iGroup} = voxCoords(voxGroups==group,:);
end

% make ROI template
ROI.name = [];
ROI.viewType = 'Inplane';
ROI.coords = [];
ROI.color = color;
ROI.created = datestr(now);
ROI.modified = datestr(now);
ROI.comments = [];
ROI.lineHandles = [];

% add name and coords to ROIs
for iGroup = 1:numel(groups)
    ROI.name = groupNames{iGroup};
    ROI.coords = groupCoords{iGroup}';
    
    % save ROI
    if saveROI
        roiSavePath = sprintf('../../Inplane/ROIs/%s',ROI.name);
        save(roiSavePath,'ROI');
    end
end
    