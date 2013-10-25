% rd_voxTimeCourseFromFigData.m

% first load multivoxel figData

%% get data info
voxs = 1:size(figData.tSeries,2);
nConds = numel(figData.trials.condNums);
condNames = figData.trials.condNames;
condColors = figData.trials.condColors;
params = figData.params;

% reset any params
params.normBsl = 0;

% calculate frame window (in TRs) used by er_chopTSeries2 (lines 165-171)
timeWindow = params.timeWindow;
TR = figData.trials.TR;
t1 = min(timeWindow);  t2 = max(timeWindow);
f1 = fix(t1 / TR);  f2 = fix(t2 / TR);
frameWindow = f1:f2;

%% voxels
nVox = numel(voxs);

%% get vox mean tcs for all voxels
voxMeanTcs = [];
for iVox = 1:nVox 
    voxIdx = voxs(iVox);
    voxtc = er_chopTSeries2(figData.tSeries(:,voxIdx)', ...
        figData.trials, params);
    
    voxMeanTcs(:,:,iVox) = voxtc.meanTcs;
end
voxMeanTcs_dimHeaders = {'TR','cond','vox'};

%% get mean tc across voxels
for iCond = 1:nConds
    allVoxMeanTcs(:,iCond) = mean(squeeze(voxMeanTcs(:,iCond,:)),2);
    allVoxStdTcs(:,iCond) = std(squeeze(voxMeanTcs(:,iCond,:)),0,2);
end

%% plot mean tcs for all voxels
for iCond = 1:nConds
    fig1(iCond) = figure;
    plot(frameWindow*TR, squeeze(voxMeanTcs(:,iCond,:)));
    xlabel('time (s)')
    ylabel('BOLD amplitude')
    title(sprintf('%s', condNames{iCond}));
    
    hold on
    plot(frameWindow*TR, allVoxMeanTcs(:,iCond),...
        'k','LineWidth',2)
    plot(frameWindow*TR, zeros(size(frameWindow)),'--k','LineWidth',1)
end

%% plot mean tc across voxels for each condition
figure
timepoints = repmat(frameWindow*TR,nConds,1)';
fig2 = errorbar(timepoints, allVoxMeanTcs, allVoxStdTcs);
set(fig2,'Color', condColors, 'LineWidth', 1.5);


