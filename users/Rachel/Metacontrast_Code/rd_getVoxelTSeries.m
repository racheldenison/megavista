function [voxelTSeries, voxelInds] = rd_getVoxelTSeries(vw,scan)
%
% %%%% WARNING! Does not seem to work right now. Compare with
% multiVoxelFigData. %%%%%

% See tc_roiStruct.m for parsing ROI arguments. For now, assume the input
% is an ROI name

% vw = initHiddenInplane(dt, scan, ROI);

%     roi = tc_roiStruct(vw, 2);
ROIcoords = getCurROIcoords(vw); % this will be for the voxelROI
sliceInds = unique(ROIcoords(3,:));

getRawData = 0;
if getRawData,
    detrend               = 0;
    inhomoCorrection      = false;
    temporalNormalization = false;
    smoothFrames          = [];
else
    detrend               = 1;
    inhomoCorrection      = true;
    temporalNormalization = false;
    smoothFrames          = detrendFrames(vw,scan);
end

voxelInds = []; % will be [voxels x 2], [index-within-slice slice-number]
voxelTSeries = []; % will be [TRs x voxels]

% Loop through slices
iSlice = 0;
for slice = sliceInds
    % Load tSeries & divide by mean, but don't detrend yet.
    % Otherwise, detrending the entire tSeries is much slower. DJH
    detrendNow = 0;
    if getRawData, noMeanRemoval = 1; else noMeanRemoval = 0; end
    
    vw = percentTSeries(vw,scan,slice,detrendNow,inhomoCorrection,temporalNormalization,noMeanRemoval);
    
    % Get the tseries for ROI voxels in the current slice
    % down-sampling (from anat to functional) happens here
    [subTSeries, subIndices] = getTSeriesROI(vw,ROIcoords);
    
    if ~isempty(subTSeries)
        % Detrend now (faster to do it now after extracting subTSeries for a small subset of the voxels)
        [subTSeries] = detrendTSeries(subTSeries, detrend, smoothFrames);
        
        % tSeries is already cropped at the beginning and end
        voxelTSeries = [voxelTSeries, subTSeries]; %TRs
        voxelInds = [voxelInds; [subIndices', repmat(slice, size(subIndices,2), 1)]];
    end
    
    fprintf('.'); iSlice = iSlice + 1;
    if mod(iSlice,10)==0
        fprintf('%d of %d\n', iSlice, numel(sliceInds))
    end
end