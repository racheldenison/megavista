% rd_fslCreateMotionRegressors.m

% get the motion parameters at each TR from the saved .par files in the
% nifti directory
% get the frames to keep and discard from mrInit2_params

scans = 1:13;
featDir = '../Field_Mapping/JN_20120808_field_map_nifti/feat_attempt/feat_preprocess_all/epis';
load mrInit2_params

for iScan = 1:numel(scans)
    scan = scans(iScan);
    
    epiDir = dir(sprintf('%s/epi%02d*.feat', featDir, scan));
    motionFile = sprintf('%s/%s/mc/prefiltered_func_data_mcf.par', ...
        featDir, epiDir.name);
    pars = load(motionFile);
    
    keepFrames = params.keepFrames(scan,:);
    if keepFrames(2)==-1
        pars = pars(keepFrames(1)+1:end,:);
    else
        pars = pars(keepFrames(1)+1:sum(keepFrames),:);
    end
    
    fprintf('Scan %d: Motion params size = [%d %d]\n', scan, size(pars))
    
    motionParams{scan} = pars;
end
