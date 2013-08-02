% rd_metacontrastGLMToSVM
%
%Elizabeth Counterman, April 2013
%Reads in saved figData.mat files from mrVista GLM, sorts by condition
%and writes beta matrices to be ready for SVM analysis
%Saves data and dataClass files into SVM_Analysis; needs to be adapted to 
%make individual folders for each condition (ie SOA_Code1)
%
% Modified by RD, 2013-07-30
% For use with figData saved from GLM of all runs together
% Run from within the ROI folder containing the multiVoxFigData.mat file

%MAKE SURE THESE PARAMETERS ARE CORRECT!!
%% setup
nTrials = 560;
% nTrials = 280;

%% load data
load('meta_multiVoxFigData.mat')

%% get trial beta and condition (soa code x left/right)
betas = squeeze(figData.glm.betas(:,1:nTrials,:)); % [trials x voxels]
labels = figData.trials.label;
labels(strcmp(labels,'end of run')) = [];
for iLabel = 1:numel(labels)
    conds(iLabel) = str2double(char(strtok(labels{iLabel},'_')));
end
orients = cellfun(@isempty,strfind(labels,'left'))'; % left=0, right=1

%% write data and class file for each soa code
c = unique(conds);
for iCond = 1:numel(c)
    cond = c(iCond);
    
    data = betas(conds==cond,:);
    class = orients(conds==cond);
    
    dataFile = sprintf('data_SOACode%d.dat', cond);
    save(dataFile, 'data', '-ascii')
    
    classFile = sprintf('dataClass_SOACode%d.dat', cond);
    fid = fopen(classFile,'wt');
    fprintf(fid, '%d\n', class);
    fclose(fid);
    
    % make empty folder to contain analysis
    soaDir = sprintf('SOACode%d', cond);
    if ~exist(soaDir, 'dir')
        mkdir(soaDir)
    else
        fprintf('\n%s directory already exists! Not overwriting.\n\n', soaDir)
    end
end

