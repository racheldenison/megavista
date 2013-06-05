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


function [] = SeedConstruction(subjectFolder, seedROI, voxelROI, cueLen, ...
                               taskLen, windowing, overlap, getRawData)
%% Parameter Values

% scans: search=2, feature=3
% seedROI and voxelROI: should be strings with name of ROI from mrVista
% windowing: rectangular=0, hamming=1, window length is always taskLen
% overlap: []=50%, 0=0
% getRawData: true=1, false=0

if notDefined('cueLen'),         cueLen = 3;            end %TRs
if notDefined('taskLen'),       taskLen = 18-cueLen;    end %TRs
if notDefined('windowing'),   windowing = 1;            end
if notDefined('overlap'),       overlap = [];           end %TODO: what should this be?
if notDefined('getRawData'), getRawData = 0;            end

%% Initialize Session

disp(strcat('Performing coherence analysis for', subjectFolder))
wd = cd;
cd(subjectFolder);

d = load('mrSESSION');
scanNum = 1:size(d.dataTYPES(1, 2).scanParams, 2);
scanTypeIndex = [];
co{max(scanNum)} = [];
map{max(scanNum)} = [];

for scan = scanNum
    cd(subjectFolder);
    scanName = d.dataTYPES(1, 2).scanParams(scan).annotation;
    if ~isempty(regexpi(scanName, 'localizer', 'match')) 
        scanTypeIndex = [scanTypeIndex; 1];
        continue
    elseif ~isempty(regexpi(scanName, 'search', 'match'))
        scanTypeIndex = [scanTypeIndex; 2];
    elseif ~isempty(regexpi(scanName, 'feature', 'match'))
        scanTypeIndex = [scanTypeIndex; 3];
    else
        disp(strcat('Unknown scan! Check scan ', num2str(scan), ' for ', subjectFolder))
        scanTypeIndex = [scanTypeIndex; 0];
        continue
    end
    
    % For running hidden
    vw = initHiddenInplane(2, scan, {seedROI, voxelROI});
    cd(wd);

    roi = tc_roiStruct(vw, 2);
    ROIcoords = getCurROIcoords(vw);
    sliceInds = unique(ROIcoords(3,:));

    detrend               = true;
    inhomoCorrection      = true;
    temporalNormalization = false;
    smoothFrames          = detrendFrames(vw,scan);

    if getRawData,
        detrend = false;
        inhomoCorrection      = false;
        temporalNormalization = false;
        %smoothFrames = 0;
    end

    %% Get Active Time Series Data

    voxelInds = [];
    voxelTSeries = [];

    % Loop through slices
    for slice = sliceInds
        % Load tSeries & divide by mean, but don't detrend yet.
        % Otherwise, detrending the entire tSeries is much slower. DJH
        detrendNow    = false;
        noMeanRemoval = false;
        if getRawData,	noMeanRemoval = true; end

        vw = percentTSeries(vw,scan,slice,detrendNow,inhomoCorrection,temporalNormalization,noMeanRemoval);

        % Down-sampling happens here
        [subTSeries, subIndices] = getTSeriesROI(vw,ROIcoords);

        if ~isempty(subTSeries)
            % Detrend now (faster to do it now after extracting subTSeries for a small subset of the voxels)
            [subTSeries] = detrendTSeries(subTSeries, detrend, smoothFrames);

            % tSeries is already cropped by 6 TRs at the beginning and end
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

    % clip out cue periods and passive blocks from both time series
    seedActiveTSeries = clipTSeries(meanSeedTSeries, cueLen, taskLen);
    voxelActiveTSeries = clipTSeries(voxelTSeries, cueLen, taskLen);
    

    %% Perform Connectivity Analysis

    % Set windowing parameter
    if windowing == 0 % THIS DOES NOT WORK
        % Many rectangular windows size taskLen
        % Vector of window weights 
        windowParameter = ones(taskLen, 1);
    elseif windowing == 1
        % Many Hamming windows size taskLen
        % Size of window
        windowParameter = taskLen;
    else
        error('No windowing parameter chosen.')
    end

    [Pxx, F] = pwelch(seedActiveTSeries, windowParameter, overlap, [], 0.5);
    
    emptyMatrix = nan * ones(size(F, 1), size(voxelActiveTSeries, 2));
    crossCorrXY = emptyMatrix;
    crossCorrYY = emptyMatrix;
    coherence   = emptyMatrix;
    phase       = emptyMatrix;
    
    for j = 1:size(voxelActiveTSeries, 2)
        vTSeries = voxelActiveTSeries(:, j);
        Pxy = cpsd(seedActiveTSeries, vTSeries, windowParameter, overlap, [], 0.5);
        Pyy = pwelch(vTSeries, windowParameter, overlap, [], 0.5);
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

    % Clip out frequencies between 0.035 to 0.25 and take the mean of each voxel
    meanCoherence = mean(coherence(find(F>=0.035 & F<=0.25),:))';
    meanPhase     = mean(phase(find(F>=0.035 & F<=0.25),:))';

    %% Save New Time Series as a Parameter Map

    % Revert indices to coords
    newCoords = [indices2Coords(voxelInds(:,1), [74 74])', voxelInds(:,2)];

    coherenceMap = zeros(74, 74, 34);
    phaseMap     = zeros(74, 74, 34);

    for slice = 1:34
        coordinates = find(newCoords(:,3) == slice);
        if ~isempty(coordinates)
            for i = 1:size(coordinates,1)
                coherenceMap(newCoords(coordinates(i),1), newCoords(coordinates(i),2), slice) = meanCoherence(coordinates(i));
                phaseMap(newCoords(coordinates(i),1), newCoords(coordinates(i),2), slice) = meanPhase(coordinates(i));
            end

            % To plot coherence values by slice for the selected ROI
            %clims = [min(min(min(voxelMap))) max(max(max(voxelMap)))];
            %figure; imagesc(flipud(voxelMap(:,:,slice)),clims); colorbar;
            % Up = Right, Down = Left, Left = Posterior, Right = Anterior
            %waitforbuttonpress
        end
    end
    
    %TODO: create second parameter map for phase
    map{scan} = coherenceMap;
    %co{scan}= phaseMap;
end

% Create subtraction and place in Localizer Slot
% Always subtracts Feature from Search
%co{find(scanTypeIndex == 1)} = co{find(scanTypeIndex == 2)} - co{find(scanTypeIndex == 3)};
map{find(scanTypeIndex == 1)} = map{find(scanTypeIndex == 2)} - map{find(scanTypeIndex == 3)};

% Save and Load in Inplane
cd(strcat(subjectFolder,'/Inplane/Averages/'));

mapName = strcat(seedROI, '_to_', voxelROI);
mapUnits = 'coherence';
save(mapName, 'map', 'mapName', 'mapUnits');

vw = loadParameterMap(vw, strcat(mapName, '.mat'));
cd(subjectFolder);
 
% Transform and Save in Gray
vol = initHiddenGray(2, 1);
vol = ip2volParMap(vw, vol, 0, 1, 'linear');

%TODO: add parameter map settings (clip mode) here.
%saveParameterMap(vw, strcat('Gray/Averages/', strcat(mapName, '.mat')), 1, 1);
cd(wd);
end