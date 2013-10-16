function motionRegressors = rd_mrCreateMotionRegressors(niftiDir, scans, plotFigs)
%
% function motionRegressors = rd_mrCreateMotionRegressors(niftiDir, scans, plotFigs)
%
% get the motion parameters at each TR from the saved .par files in the
% nifti directory
% get the frames to keep and discard from mrInit2_params

% scans = 2:9;
% niftiDir = 'AV_20111117_n_nifti';

% [upDir, sessDir] = fileparts(pwd);
% niftiDir = sprintf('%s_nifti', sessDir);
% scans = 1:numel(dir(sprintf('%s/*.par', niftiDir)));

% plotFigs = 0;

load mrInit2_params

motionRegressors = [];
for iScan = 1:numel(scans)
    scan = scans(iScan);
    
    motionFile = dir(sprintf('%s/epi%02d*mcf.par', niftiDir, scan));
    moPars = load(sprintf('%s/%s', niftiDir, motionFile.name));
    
    keepFrames = params.keepFrames(scan,:);
    if keepFrames(2)==-1
        moPars = moPars(keepFrames(1)+1:end,:);
    else
        moPars = moPars(keepFrames(1)+1:sum(keepFrames),:);
    end
    
    motionRegressors = [motionRegressors; moPars];
    
    fprintf('Scan %d: Motion params size = [%d %d]\n', scan, size(moPars))
    motionParams{scan} = moPars;
end

fprintf('\nMotion regressors size = [%d %d]\n', size(motionRegressors))

if plotFigs
    figure
    plot(motionRegressors)
end

% save motionParams.mat motionParams
% save motionRegressors.mat motionRegressors