function [] = SeedConstruction(seedROI, voxelROI, dt, scans, getRawData, timePointSelector, windowParameter, overlap, freqRange)

% This function pulls out the time series for all the active voxels in the
% selected ROI and performs connectivity analysis.
% Much of this code is copied from the meanTSeries.m file with modifications
%
% [parameterMap] = seedConstruction(scan, seedROI, voxelROI, cueLength, ...
%                                    taskLength, windowing, overlap, getRawData)
%
% Created by Rachel Albert 1/15/13.
%
% edited by SS 1/17/13
% removed loops necessitated by cell array
% verified that code produces same timeSeries as meanTimeSeries
%
% edited by RA 1/24/13
% added Hidden Inplane
% removed scan loop and set scan as a parameter
% fixed windowing error and added windowing options
%
% edited by RA 1/27/13
% turned script into a function
% added scan loop
% pre-allocated coherence analysis for speed
% simplified saving at the end
% added Phase and Search-Feature Subtraction
%
% edited by RD 1/28/13
% generalizing ... [COME BACK]


%% Parameter Values
% scans: search=2, feature=3
% seedROI and voxelROI: should be strings with name of ROI from mrVista
% windowing: rectangular=0, hamming=1, window length is always taskLen
% overlap: []=50%, 0=0
% getRawData: true=1, false=0
% dt: dataTYPE, eg. 1=Original
% scans: scans to include. if [], use all scans in the dataTYPE.
% timePointSelector: a logical vector nTRsx1. 1 to include that TR in the 
% analysis, 0 to exclude. if [], use all TRs.

if notDefined('dt'),                 dt = 1;            end
if notDefined('scans'),           scans = [];           end
if notDefined('getRawData'), getRawData = 0;            end
if notDefined('timePointSelector'), timePointSelector = []; end
if notDefined('windowParameter'), windowParameter = []; end
if notDefined('overlap'),       overlap = [];           end %TODO: what should this be?
if notDefined('freqRange'),   freqRange = [0.01 0.15]; end

%% Initialize Session
fprintf('Performing coherence analysis for\n%s', cd)
% wd = cd;
% cd(subjectFolder);

d = load('mrSESSION');

nScansInDataType = numel(d.dataTYPES(dt).scanParams);
if isempty(scans)
    scans = 1:nScansInDataType;
end
% scanTypeIndex = [];
co{nScansInDataType} = [];
map{nScansInDataType} = [];

for scan = scans
%     cd(subjectFolder);
%     scanName = d.dataTYPES(dt).scanParams(scan).annotation;
%     if ~isempty(regexpi(scanName, 'localizer', 'match')) 
%         scanTypeIndex = [scanTypeIndex; 1];
%         continue
%     elseif ~isempty(regexpi(scanName, 'search', 'match'))
%         scanTypeIndex = [scanTypeIndex; 2];
%     elseif ~isempty(regexpi(scanName, 'feature', 'match'))
%         scanTypeIndex = [scanTypeIndex; 3];
%     else
%         disp(strcat('Unknown scan! Check scan ', num2str(scan), ' for ', subjectFolder))
%         scanTypeIndex = [scanTypeIndex; 0];
%         continue
%     end
    
    % For running hidden
    vw = initHiddenInplane(dt, scan, {seedROI, voxelROI});
%     cd(wd);

%     roi = tc_roiStruct(vw, 2);
    ROIcoords = getCurROIcoords(vw); % this will be for the voxelROI
    sliceInds = unique(ROIcoords(3,:));

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

    %% Get Active Time Series Data
    voxelInds = []; % will be [voxels x 2], [index-within-slice slice-number] 
    voxelTSeries = []; % will be [TRs x voxels]

    % Loop through slices
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

    end

    % For debugging
    % To plot the time series of a random voxel
    %randTSeries = vw.tSeries(:,randi(size(vw.tSeries)));
    %figure; plot(linspace(1,72,72), randTSeries);

    % To plot the mean time series of the whole ROI, i.e. for debugging
    %meanT = mean(voxeltSeries,2);
    %figure;plot(linspace(1,72,72),meanT)

    [meanSeedTSeries, tSerr] = meanTSeries(vw, scan, seedROI, getRawData);

    % Select time points
    % (see also clipTSeries.m for an example of an experiment-custom
    % function to do this)
    if isempty(timePointSelector)
        timePointSelector = true(size(voxelTSeries,1),1);
    end
    seedActiveTSeries = meanSeedTSeries(timePointSelector);
    voxelActiveTSeries = voxelTSeries(timePointSelector,:);

    %% Perform Connectivity Analysis
    Fs = 1/d.mrSESSION.functionals(scan).framePeriod; % 1/TR
    [Pxx, F] = pwelch(seedActiveTSeries, windowParameter, overlap, [], Fs);
    
    emptyMatrix = nan * ones(size(F, 1), size(voxelActiveTSeries, 2));
    crossCorrXY = emptyMatrix;
    crossCorrYY = emptyMatrix;
    coherence   = emptyMatrix;
    phase       = emptyMatrix;
    
    % one voxel at a time
    for j = 1:size(voxelActiveTSeries, 2)
        vTSeries = voxelActiveTSeries(:, j);
        Pxy = cpsd(seedActiveTSeries, vTSeries, windowParameter, overlap, [], Fs);
        Pyy = pwelch(vTSeries, windowParameter, overlap, [], Fs);
        crossCorrXY(:, j) = Pxy;
        crossCorrYY(:, j) = Pyy;
        voxelCoherence = (abs(Pxy) .^ 2) ./ (Pxx .* Pyy);
        coherence(:, j) = voxelCoherence;
        voxelDelay = angle(Pxy); % In Radians DOES NOT WORK
        phase(:, j) = voxelDelay;

        if size(coherence, 2) > 1000 && mod(size(coherence, 2), 1000) == 0
            disp(size(coherence,2))
        end
    end

    % Clip out frequencies in the frequency range and take the mean of each voxel
    meanCoherence = mean(coherence(F>=freqRange(1) & F<=freqRange(2),:))';
    meanPhase     = mean(phase(F>=freqRange(1) & F<=freqRange(2),:))';

    %% Save connectivity data as a Parameter Map
    % Revert indices to coords
    functionalSize = d.mrSESSION.functionals(scan).cropSize;
    nSlices = numel(d.mrSESSION.functionals(scan).slices);
    newCoords = [indices2Coords(voxelInds(:,1), functionalSize)', voxelInds(:,2)];

    coherenceMap = zeros(functionalSize(1), functionalSize(2), nSlices);
    phaseMap     = zeros(functionalSize(1), functionalSize(2), nSlices);

%     for slice = 1:nSlices
%         coordinates = find(newCoords(:,3) == slice);
%         if ~isempty(coordinates)
%             for i = 1:size(coordinates,1)
%                 coherenceMap(newCoords(coordinates(i),1), newCoords(coordinates(i),2), slice) = meanCoherence(coordinates(i));
%                 phaseMap(newCoords(coordinates(i),1), newCoords(coordinates(i),2), slice) = meanPhase(coordinates(i));
%             end
% 
% 
%         end
%     end
    for iVox = 1:size(newCoords,1)
        voxCoord = newCoords(iVox,:);
        coherenceMap(voxCoord(1), voxCoord(2), voxCoord(3)) = meanCoherence(iVox);
        phaseMap(voxCoord(1), voxCoord(2), voxCoord(3)) = meanPhase(iVox);
    end
    % To plot coherence values by slice for the selected ROI
    %clims = [min(min(min(voxelMap))) max(max(max(voxelMap)))];
    %figure; imagesc(flipud(voxelMap(:,:,slice)),clims); colorbar;
    % Up = Right, Down = Left, Left = Posterior, Right = Anterior
    %waitforbuttonpress
    
    %TODO: create second parameter map for phase
    map{scan} = coherenceMap;
    %co{scan}= phaseMap;
end

% % Create subtraction and place in Localizer Slot
% % Always subtracts Feature from Search
% %co{find(scanTypeIndex == 1)} = co{find(scanTypeIndex == 2)} - co{find(scanTypeIndex == 3)};
% map{find(scanTypeIndex == 1)} = map{find(scanTypeIndex == 2)} - map{find(scanTypeIndex == 3)};

% Save and Load in Inplane
% cd(strcat(subjectFolder,'/Inplane/Averages/'));
mapName = strcat(seedROI, '_to_', voxelROI);
mapUnits = 'coherence';
mapPath = sprintf('Inplane/%s/%s', d.dataTYPES(dt).name, mapName);
save(mapPath, 'map', 'mapName', 'mapUnits');

vw = loadParameterMap(vw, strcat(mapName, '.mat'));
% cd(subjectFolder);
 
% Transform and Save in Gray
vol = initHiddenGray(dt, scan);
vol = ip2volParMap(vw, vol, 0, 1, 'linear');

%TODO: add parameter map settings (clip mode) here.
%saveParameterMap(vw, strcat('Gray/Averages/', strcat(mapName, '.mat')), 1, 1);
% cd(wd);
end
