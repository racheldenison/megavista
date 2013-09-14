% rd_analyzeMotionParamsGroup.m

scanner = '7T';

[subjectDirs3T subjectDirs7T] = rd_lgnSubjects;
switch scanner
    case '3T'
        subjectDirs = subjectDirs3T;
        subjects = [1 2 4 5];
    case '7T'
        subjectDirs = subjectDirs7T;
        subjects = [1:5 7 8];
end

% subjects = 7:8;
% subjects = 1:size(subjectDirs,1);
nSubjects = numel(subjects);

scanNumIdx = 4:5; % characters in the file name containing the scan number

plotFigs = 1;

% run specified individual analysis script in subject directory
for iSubject = 1:nSubjects
    subject = subjects(iSubject);
    
    [dirPath dirName] = rd_getSubjectDir(subjectDirs, scanner, subject);
    
    % go to subject directory
    cd(dirPath)
    
    niftiDir = sprintf('%s_nifti', dirName);
    motionFilesHemi = dir(sprintf('%s/*hemi_mcf.par',niftiDir));
    motionFilesMP = dir(sprintf('%s/*mp_mcf.par',niftiDir));
    motionFiles = [motionFilesHemi; motionFilesMP];
    scans = zeros(1,numel(motionFiles));
    for iMF = 1:numel(motionFiles)
        scans(iMF) = str2num(motionFiles(iMF).name(scanNumIdx));
    end
    scans = sort(scans);
%     motionFiles = dir(sprintf('%s/*.par',niftiDir));
%     scans = 1:numel(motionFiles); % assume scans are numbered from 1
    
    motionRegressorsGroup{iSubject} = rd_mrCreateMotionRegressors(niftiDir, scans, plotFigs);
    
end