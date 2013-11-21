function params = rd_metacontrastMakeMrInit2Params

% function params = rd_metacontrastMakeMrInit2Params
%
% Makes a params structure that can be passed to mrInit2, to run it from
% the command line with specified params.
%
% Run this from the session directory. It will look for certain files in
% certain locations within that directory.
%
% Rachel Denison
% 2013 Nov 21
% 
% Modified from rd_mrMakeMrInit2Params.m

% can run this before running mrInit2 if you want to get a crop
% params = mrInitGUI_crop(params);

% ------------------------------------------------------------------------
% Setup
% ------------------------------------------------------------------------
% Here we have the most common analysis settings that are specific to an
% individual experiment
subjectID = 'WC';
description = 'WC_20131120_n';
comments = '';

% Scan groups
% scanGroups = {[1 14], [2 13], 3:12}; % {orientation, targetmask, metacontrast}
scanGroups = {[2 13], [1 14], 3:12}; % WC {orientation, targetmask, metacontrast}

% Keep frames
scanGroupKeepFrames = {[3 -1], [3 -1], [3 -1]}; % [frames-to-discard frames-to-keep]

% Annotations
scanGroupNames = {'orientation','targetmask','meta'};

% Parfiles
scansWithParfile = {scanGroups{1}, scanGroups{2}, scanGroups{3}}; % {orientation, targetmask, metacontrast}
parfileTags = {'orientation','targetmask','conditionwise'};

% Coherence analysis
coherenceScanGroups = 0;

% GLM analysis
glmScanGroups = 1:3; % [orientation, targetmask, metacontrast]
eventsPerBlock = [8 8 1]; % length of block in TRs [orientation, targetmask, metacontrast]

% ------------------------------------------------------------------------
% Files
% ------------------------------------------------------------------------
[p f ext] = fileparts(pwd);
fprintf('\nMaking params for %s...', description)
fprintf('\nCurrent path is %s/%s\n\n', p, f)

% Expect to find data in a file named SESSIONNAME_nifti
niftiDir = [f '_nifti'];

inplaneFile = dir([niftiDir '/gems*.nii.gz']);
inplane = sprintf('%s/%s/%s/%s', p, f, niftiDir, inplaneFile.name);

% featDirs = dir([niftiDir '/epi*.feat']);
% for iFunc = 1:numel(featDirs)
%     functionals{iFunc,1} = sprintf('%s/%s/%s/%s/%s', ...
%         p, f, niftiDir, featDirs(iFunc).name, 'filtered_func_data.nii.gz');
% end
functionalFiles = dir([niftiDir '/*mcf.nii.gz']); % /*mcf.nii.gz, /*fsldc.nii.gz
for iFunc = 1:numel(functionalFiles)
    functionals{iFunc,1} = sprintf('%s/%s/%s/%s', ...
        p, f, niftiDir, functionalFiles(iFunc).name);
end

vAnatomy =  sprintf('/Volumes/Plata1/Anatomies/Anatomicals/%s/vAnatomy.dat', subjectID);

% Expect to find parfiles in the specified directory
parfileDir = 'Stimuli/parfiles';
for iParGroup = 1:numel(scansWithParfile)
    parfileFiles = dir(sprintf('%s/*%s*.par', parfileDir, parfileTags{iParGroup}));
    for iPar = 1:numel(parfileFiles)
        parfiles{iPar,iParGroup} = parfileFiles(iPar).name;
    end
end

% ------------------------------------------------------------------------
% Analysis params
% ------------------------------------------------------------------------
% Coherence analysis
co = coParamsDefault;

% GLM analysis
for iGroup = 1:numel(scanGroups)
    glm(iGroup) = er_defaultParams;
    glm(iGroup).eventsPerBlock = eventsPerBlock(iGroup);
    glm(iGroup).glmHRF = 3; % SPM HRF
end

% ------------------------------------------------------------------------
% Scan groups
% ------------------------------------------------------------------------
for iGroup = 1:numel(scanGroups)
    scans = scanGroups{iGroup};
    for iScan = 1:numel(scans)
        scan = scans(iScan);
        keepFrames(scan,:) = scanGroupKeepFrames{iGroup};
        annotations{scan,1} = sprintf('%s %d', scanGroupNames{iGroup}, iScan);
        
        if any(iGroup==coherenceScanGroups)
            coParams{1,scan} = co;
        else
            coParams{1,scan} = [];
        end
        if any(iGroup==glmScanGroups)
            glmParams{1,scan} = glm(iGroup);
        end
    end
end

% ------------------------------------------------------------------------
% Parfile assignments
% ------------------------------------------------------------------------
parfile = cell(1,numel(functionals));
for iParGroup = 1:numel(scansWithParfile)
    parScans = scansWithParfile{iParGroup};
    for iScan = 1:numel(parScans)
        scan = parScans(iScan);
        parfile{scan} = parfiles{iScan,iParGroup};
    end
end

% ------------------------------------------------------------------------
% Create params
% ------------------------------------------------------------------------
% Note several defaults are set here
params.inplane = inplane;
params.functionals = functionals;
params.vAnatomy = vAnatomy;
params.sessionDir = pwd;
params.sessionCode = f;
params.subject = subjectID;
params.description = description;
params.comments = comments;
params.crop = [];
params.keepFrames = keepFrames;
params.annotations = annotations;
params.parfile = parfile;
params.coParams = coParams;
params.glmParams = glmParams;
params.scanGroups = scanGroups;
params.applyGlm = 0;
params.applyCorAnal = [];
params.motionComp = 0;
params.sliceTimingCorrection = 0;
params.motionCompRefScan = 1;
params.motionCompRefFrame = 1;
params.doDescription = 1;
params.doCrop = 0;
params.doAnalParams = 1;
params.doPreprocessing = 0;
params.doSkipFrames = 1;
params.startTime = datestr(now);
