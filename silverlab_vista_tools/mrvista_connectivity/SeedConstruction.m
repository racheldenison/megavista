function [corMap, cohMap, phMap] = SeedConstruction(seedROI, voxelROI, dt, scans, ...
    getRawData, filterTSeries, regressNuisance, regressGlobal, ...
    timePointSelector, windowParameter, overlap, freqRange)

% [corMap, cohMap, phMap] = SeedConstruction(seedROI, voxelROI, dt, scans, ...
%     getRawData, filterTSeries, regressNuisance, regressGlobal, ...
%     timePointSelector, windowParameter, overlap, freqRange)
%
% This function pulls out the time series for all the active voxels in the
% selected ROI and performs connectivity analysis. Run this from the
% folder containing mrSession.mat.
% Much of this code is copied from the meanTSeries.m file with modifications
%
% INPUTS:
% seedROI and voxelROI: should be strings with name of ROI from mrVista
% seedROI is the name of the ROI whose mean time series will be correlated
% with all the voxel time series of voxelROI. 
% If you have an Inplane ROI file 'V1.mat', seedROI (or voxelROI) would be 'V1'.
% The calculation of the CPSD is in the order cpsd(seedROI,voxelROI).
%
% Optional arguments:
% dt: dataTYPE integer. default 1 (=Original)
% scans: vector of scans to include. if [], use all scans in the dataTYPE.
% getRawData: true=1, false=0
% filterTSeries: true=1, false=0
% regressNuisance: true=1, false=0
% regressGlobal: true=1, false=0. if regressNuisance=0, this won't matter.
% timePointSelector: a logical vector nTRsx1. 1 to include that TR in the 
% analysis, 0 to exclude. if [], use all TRs.
% windowParameter: the 'window' argument in pwelch. if [], divide tseries
% into the default number of segments given by pwelch and use Hamming
% window.
% overlap: the 'noverlap' argument in pwelch. []=50%, 0=0
% freqRange: 2-element vector with [lower upper] frequency bounds
%
% OUTPUTS:
% coMap and phMap are the coherence parameter map and phase delay paramter
% map, respectively. They are the size of an epi (3D), with coherence (or delay)
% values in all voxelROI voxels and zeros elsewhere.
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
% edited by RD 6/28/13
% generalized to work for any experiment (removed all hard-coding of
% experiment-specific values and procedures)
% replaced clipTSeries.m by a logical vector input argument for selecting
% time points
% made the data type an input argument
% scans is now a vector of selected scans
% saves phase maps (tested with phase calculation with simple simulation, 
% but this could use more testing)
% added 'co' field to threshold maps by coherence when visualizing
% removed a bunch of directory switching (I didn't know what that was
% doing.)
%
% edited by RD 7/8/2013
% added correlation analysis
% added time series filtering
% added option to regress out nuisance time series (wm, csf, whole brain)
% added an 'analysis string' to map filenames to indicate what
% preprocessing steps were performed

%% Parameter Values
if notDefined('dt'),                               dt = 1;            end
if notDefined('scans'),                         scans = [];           end
if notDefined('getRawData'),               getRawData = 1;            end
if notDefined('filterTSeries'),         filterTSeries = 1;            end
if notDefined('regressNuisance'),     regressNuisance = 1;            end
if notDefined('regressGlobal'),         regressGlobal = 1;            end
if notDefined('timePointSelector'), timePointSelector = [];           end
if notDefined('windowParameter'),     windowParameter = [];           end
if notDefined('overlap'),                     overlap = [];           end 
if notDefined('freqRange'),                 freqRange = [0.009 0.08];  end

%% Initialize Session
fprintf('Performing coherence analysis for\n%s\n', cd)

d = load('mrSESSION');

nScansInDataType = numel(d.dataTYPES(dt).scanParams);
if isempty(scans)
    scans = 1:nScansInDataType;
end

corMap{nScansInDataType} = [];
cohMap{nScansInDataType} = [];
phMap{nScansInDataType} = [];

%% Loop through scans
for scan = scans
    %% Set up scan
    % For running hidden
    vw = initHiddenInplane(dt, scan, {seedROI, voxelROI});
    Fs = 1/d.mrSESSION.functionals(scan).framePeriod; % 1/TR

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
    % (see clipTSeries.m for an example of an experiment-custom function)
    if isempty(timePointSelector)
        timePointSelector = true(size(voxelTSeries,1),1);
    end
    seedActiveTSeries = meanSeedTSeries(timePointSelector);
    voxelActiveTSeries = voxelTSeries(timePointSelector,:);
    
    %% Filter time series
    if filterTSeries
        seedActiveTSeries = rd_bandpass(double(seedActiveTSeries), ...
            freqRange, Fs);
        
        voxelActiveTSeries = rd_bandpass(double(voxelActiveTSeries), ...
            freqRange, Fs);
    end
    
    %% Regress out nuisance variables
    if regressNuisance
        % get nuisance design matrix
        if filterTSeries
            X = rd_getNuisanceRegressors(scan, regressGlobal, freqRange, Fs);
        else
            X = rd_getNuisanceRegressors(scan, regressGlobal);
        end
        
        % regress seed tseries
        [bSeed(:,1), bintSeed, residsSeed(:,1)] = ...
            regress(seedActiveTSeries,X);
        
        % regress voxel tseries
        residsVox = zeros(size(voxelActiveTSeries));
        for iVox = 1:size(voxelActiveTSeries,2)
            [bVox(:,iVox), bintVox, residsVox(:,iVox)] = ...
                regress(voxelActiveTSeries(:,iVox),X);
        end
        
        % use the residuals as the new tseries
        seedActiveTSeries = residsSeed;
        voxelActiveTSeries = residsVox;
    else
        X = [];
    end
    
    %% Perform correlation analysis
    correlation = corr(voxelActiveTSeries, seedActiveTSeries);
    
    %% Perform coherency analysis
    Fs = 1/d.mrSESSION.functionals(scan).framePeriod; % 1/TR
    % [pxx,f] = pwelch(x,window,noverlap,f,fs)
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
        voxelDelayRad = angle(Pxy); % In Radians
        voxelDelay = voxelDelayRad./(2*pi*F);
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

    correlationMap = zeros(functionalSize(1), functionalSize(2), nSlices);
    coherenceMap = zeros(functionalSize(1), functionalSize(2), nSlices);
    phaseMap     = zeros(functionalSize(1), functionalSize(2), nSlices);

    for iVox = 1:size(newCoords,1)
        voxCoord = newCoords(iVox,:);
        correlationMap(voxCoord(1), voxCoord(2), voxCoord(3)) = correlation(iVox);
        coherenceMap(voxCoord(1), voxCoord(2), voxCoord(3)) = meanCoherence(iVox);
        phaseMap(voxCoord(1), voxCoord(2), voxCoord(3)) = meanPhase(iVox);
    end
    
    corMap{scan} = correlationMap;
    cohMap{scan} = coherenceMap;
    phMap{scan} = phaseMap;
    
    % To plot coherence values by slice for the selected ROI
    %clims = [min(min(min(voxelMap))) max(max(max(voxelMap)))];
    %figure; imagesc(flipud(voxelMap(:,:,slice)),clims); colorbar;
    % Up = Right, Down = Left, Left = Posterior, Right = Anterior
    %waitforbuttonpress
end

%% Store analysis options
mapInfo.getRawData = getRawData;
mapInfo.filterTSeries = filterTSeries;
mapInfo.regressNuisance = regressNuisance;
mapInfo.regressGlobal = regressGlobal;
mapInfo.timePointSelector = timePointSelector;
mapInfo.windowParameter = windowParameter;
mapInfo.overlap = overlap;
mapInfo.freqRange = freqRange;
mapInfo.Fs = Fs;
mapInfo.X = X;

% make string containing a few of the analysis choices
analStr = '';
if getRawData
    analStr = [analStr 'r'];
end
if filterTSeries
    analStr = [analStr 'f'];
end
if regressNuisance
    analStr = [analStr 'n'];
    if regressGlobal
        analStr = [analStr 'g'];
    end
end

%% Save maps
% correlation map
map = corMap;
co = corMap; % threshold by correlation
mapName = sprintf('%s_to_%s_%s_cor', seedROI, voxelROI, analStr);
mapUnits = 'correlation';
mapPath = sprintf('Inplane/%s/%s', d.dataTYPES(dt).name, mapName);
save(mapPath, 'map', 'co', 'mapName', 'mapUnits','mapInfo');

% coherence map
map = cohMap;
co = cohMap; % threshold by coherence
mapName = sprintf('%s_to_%s_%s_coh', seedROI, voxelROI, analStr);
mapUnits = 'coherence';
mapPath = sprintf('Inplane/%s/%s', d.dataTYPES(dt).name, mapName);
save(mapPath, 'map', 'co', 'mapName', 'mapUnits','mapInfo');

% phase map
map = phMap; 
co = cohMap; % threshold by coherence
mapName = sprintf('%s_to_%s_%s_ph', seedROI, voxelROI, analStr);
mapUnits = 'delay (s)';
mapPath = sprintf('Inplane/%s/%s', d.dataTYPES(dt).name, mapName);
save(mapPath, 'map', 'co', 'mapName', 'mapUnits','mapInfo');

% % Transform and Save in Gray
% % load in Inplane
% vw = loadParameterMap(vw, strcat(mapName, '.mat')); 
% vol = initHiddenGray(dt, scan);
% vol = ip2volParMap(vw, vol, 0, 1, 'linear');

%TODO: add parameter map settings (clip mode) here.
%saveParameterMap(vw, strcat('Gray/Averages/', strcat(mapName, '.mat')), 1, 1);
end
