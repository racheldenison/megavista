function [perf, nvox] = rd_metacontrastMVPA(subjectID, soaCode, thresh)

%% setup
% soaCode = 6;

% data = load(sprintf('data_SOACode%d.dat', soaCode));
% class = load(sprintf('dataClass_SOACode%d.dat', soaCode));
data = load('data_OrientLoc.dat');
class = load('dataClass_OrientLoc.dat');

% nRuns = 10; % Meta
nRuns = 12; % OrientLoc - 6 per scan

%% set up runs vector
nTrialsPerRun = size(data,1)/nRuns;
runs = ones(nTrialsPerRun,1)*(1:nRuns);
runs = runs(:)';

%% make dummy mask, needs to be 3D
nVox = size(data,2);
sz = ceil(nVox^(1/3)); % for now, just make minimum cube that will hold all the voxels

mask = zeros(sz,sz,sz);
mask(1:nVox) = 1;

%% convert to mvpa toolbox format
epi = data';
conds = double([class==0 class==1])';
condnames = {'left','right'};

%% INITIALIZING THE SUBJ STRUCTURE
% start by creating an empty subj structure
subj = init_subj('meta',subjectID);

% mask
subj = init_object(subj,'mask','cube');
subj = set_mat(subj,'mask','cube',mask);

% trial data pattern
subj = init_object(subj,'pattern','epi');
subj = set_mat(subj,'pattern','epi',epi);
subj = set_objfield(subj,'pattern','epi','masked_by','cube');

% conds (classes) regressor
subj = init_object(subj,'regressors','conds');
subj = set_mat(subj,'regressors','conds',conds);
subj = set_objfield(subj,'regressors','conds','condnames',condnames);

% runs selector
subj = init_object(subj,'selector','runs');
subj = set_mat(subj,'selector','runs',runs);

%% PRE-PROCESSING - z-scoring in time and no-peeking anova
% we want to z-score the EPI data (called 'epi'),
% individually on each run (using the 'runs' selectors)
subj = zscore_runs(subj,'epi','runs');

% now, create selector indices for the n different iterations of
% the nminusone
subj = create_xvalid_indices(subj,'runs');

% run the anova multiple times, separately for each iteration,
% using the selector indices created above
[subj] = feature_select(subj,'epi_z','conds','runs_xval','thresh',thresh);

%% CLASSIFICATION - n-minus-one cross-validation
% set some basic arguments for a backprop classifier
% class_args.train_funct_name = 'train_bp_netlab';
% class_args.test_funct_name = 'test_bp_netlab';
% class_args.nHidden = 10;

class_args.train_funct_name = 'train_logreg';
class_args.test_funct_name = 'test_logreg';
class_args.penalty = 10;

% now, run the classification multiple times, training and testing
% on different subsets of the data on each iteration
epizstr = sprintf('epi_z_thresh%s', num2str(thresh));
[subj, results] = cross_validation(subj,'epi_z','conds','runs_xval', epizstr, class_args);
% [subj, results] = cross_validation(subj,'epi_z','conds','runs_xval','cube',class_args);

%% Extract classifier performance data and other info
for iRun = 1:nRuns
    perf(iRun,1) = results.iterations(iRun).perf;
    nvox(iRun,1) = subj.masks{iRun+1}.nvox;
end
