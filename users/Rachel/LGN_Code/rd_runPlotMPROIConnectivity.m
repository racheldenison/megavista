% rd_runPlotMPROIConnectivity.m
%
% Calls rd_plotMPROIConnectivity, with subject-specific info
% Loops through scans, voxel selection methods, and seed hemispheres
% Run from session directory

%% Setup
% these three determine roi1Name
% same for everyone if we're using left-right analysis
hemi = 1;
mapName = 'betaM-P';
groupName = 'M';

analStr = 'rfng';
measures = {'roiCorr'}; % 'roiCorr','roiCoh' (any combination)

% can loop through these
scanNames = {'fix_allscans','M 1','P 1','mp_blankCond','mp_MCond','mp_PCond'}; % 'fix 1', 'M 1', 'P 1', 'mp_blankCond'
voxelSelections = {'extreme'}; % 'all','extreme','varthresh'
seedHemis = [1 2]; % plot connectivity between M and P ROIs in this hemisphere and all other ROIs

% get subject initials from current directory
[upDir, sessDir] = fileparts(pwd);
subject = sessDir(1:2);

fileBase = sprintf('lgnROI%d', hemi);

saveFigs = 1;

%% Loop through scans and voxel selection options
for iSN = 1:numel(scanNames)
    scanName = scanNames{iSN};
    
    for iVS = 1:numel(voxelSelections)
        voxelSelection = voxelSelections{iVS};
        
        for iSH = 1:numel(seedHemis)
            seedHemi = seedHemis(iSH);
            
            %% Determine ROI1 name for selected options
            switch voxelSelection
                case 'all'
                    prop = .2;
                    varThresh = 0;
%                     roi1Name = sprintf('%s_%s', fileBase, groupName);
                    roi1Name = [];
                case 'extreme'
                    prop = .1;
                    varThresh = 0;
                    roi1Name = [];
                case 'varthresh'
                    prop = 0.2;
                    roi1Name = [];
                    switch subject
                        case 'JN'
                            varThresh = 0.040;
                        case 'SB'
                            varThresh = 0.038;
                        otherwise
                            error('subject not recognized')
                    end
                otherwise
                    error('voxelSelection not recognized')
            end
            
            threshDescrip = sprintf('%0.03f', varThresh);
            voxDescrip = ['varThresh' threshDescrip(3:end)];
            
            if isempty(roi1Name)
                roi1Name = sprintf('%s_%s_prop%d_%s_group%s', ...
                    fileBase, mapName, round(prop*100), voxDescrip, groupName);
            end
            
            %% Plot connectivity
            rd_plotMPROIConnectivity(roi1Name, analStr, scanName, voxelSelection, seedHemi, measures, saveFigs)
            
        end
    end
end
