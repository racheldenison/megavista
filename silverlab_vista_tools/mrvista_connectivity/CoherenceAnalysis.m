% This script sets up restricted ROIs and calls the SeedConstruction.m
% function to perform bulk connectivity analysis on a large amount of data.
%
% Created by Rachel Albert 1/29/13.
clc; clx;

subjects = {['AL_11022012'],['RD_09281012/RD_09282012_nifti']};%, ['SS_11012012'], ['CG_09272012']
seedROIs = {['RAng']};
voxelROIs = {['RIPS_Combined'], ['LIPS_Combined']};

for subject = subjects
    for seedROI = seedROIs
        for voxelROI = voxelROIs
            subjectFolder = strcat('/Volumes/Plata1/neglect/subjects/', subject{1});
            if ~isempty(regexpi(voxelROI{1}, 'gray', 'match'))
                if exist(strcat('/Volumes/Plata1/neglect/subjects/', subject{1}, '/Inplane/ROIs/', 'gray_no_', seedROI{1}, '.mat'), 'file')
                    continue
                else
                    disp('Creating new Gray ROI...')
                    
                    % Load ROIs into hidden Inplane
                    cd(subjectFolder);
                    vw = initHiddenInplane(2, 1, {[seedROI{1}], [voxelROI{1}]});
                    newROIName = strcat('gray_no_', seedROI{1});
                    [vw, newROI] = combineROIs(vw, {[voxelROI{1}], [seedROI{1}]}, 'A not B', newROIName);
                    vw = saveROI(vw, newROI, 'local', 1);
                    disp(strcat(newROIName, 'created!'))
                    clear vw;
                end
                % Perform Coherence Analysis with restricted Gray ROI
                SeedConstruction(subjectFolder, seedROI{1}, strcat('gray_no_', seedROI{1}));
            else
                % Perform Coherence Analysis with original ROI
                SeedConstruction(subjectFolder, seedROI{1}, voxelROI{1});
            end
        end
    end
end
