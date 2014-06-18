% rd_testPlotAspectRatio.m

aspectRatio = [1 2 1];
plotFormat = 'singleRow';
mapName = 'test';
brainMapToPlot = rand([4 5 3 6]); % [cols slices rgb rows]

%%% new %%%
nAxCols = size(brainMapToPlot,1);
nAxRows = size(brainMapToPlot,4);
%%%%%%%%%%%

%% Plot
dimLabels = {'Sag','Cor','--','Ax'};
dimToSlice = 2;

% number of subplots to contain all slices
switch plotFormat
    case 'default'
        nPlotCols = ceil(sqrt(size(brainMapToPlot,dimToSlice)));
        nPlotRows = ceil(size(brainMapToPlot,dimToSlice)/nPlotCols);
    case 'singleRow'
        nPlotCols = size(brainMapToPlot,dimToSlice);
        nPlotRows = 1;
    otherwise
        error('plotFormat not recognized')
end

f1 = figure('name',mapName);

%%% new %%%
s = 0.5; % scaling factor for width and height
set(f1, 'Units', 'centimeters');
figPos = get(f1, 'Position');
% position_rectangle = [left, bottom, width, height]
% h = axes('Position',position_rectangle);
nSlices = size(brainMapToPlot,dimToSlice);
cushions = 0.5*ones(1,nSlices);
widths = nAxCols*ones(1,nSlices)*aspectRatio(2)*s;
height = nAxRows*aspectRatio(1)*s;
lefts = ones(1,nSlices) + cumsum(widths+cushions); % - widths(1)
lefts = lefts(end:-1:1);
bottom = 1;
figPos(1) = 0;
figPos(3) = lefts(1) + widths(end) + 1;
set(f1,'Position',figPos);
%%%%%%%%%%%

%% Slices
for iSlice = 1:size(brainMapToPlot,dimToSlice)
    
    %%% new %%%
    axRect = [lefts(iSlice) bottom widths(iSlice) height];
    %%%%%%%%%%%
    
    brainSliceMap1 = [];
    switch dimToSlice
        case 1 % (sagittal)
            if iSlice==1, fprintf('\n\nSlicing sagittal ...\n\n'), end
            brainSliceMap = shiftdim(squeeze(brainMapToPlot(iSlice,:,:,:)),2);
        case 2 % (coronal) viewing from the front, slices numbered from posterior to anterior
            if iSlice==1, fprintf('\n\nSlicing coronal ...\n\n'), end
            brainSliceMap0 = shiftdim(squeeze(brainMapToPlot(:,iSlice,:,:)),2);
            brainSliceMap1(:,:,1) = fliplr(flipud(brainSliceMap0(:,:,1)));
            brainSliceMap1(:,:,2) = fliplr(flipud(brainSliceMap0(:,:,2)));
            brainSliceMap1(:,:,3) = fliplr(flipud(brainSliceMap0(:,:,3)));
            brainSliceMap = brainSliceMap1;
        case 4 % standard (axial)
            if iSlice==1, fprintf('\n\nSlicing axial ...\n\n'), end
            brainSliceMap0 = brainMapToPlot(:,:,:,iSlice);
            brainSliceMap1(:,:,1) = flipud(brainSliceMap0(:,:,1));
            brainSliceMap1(:,:,2) = flipud(brainSliceMap0(:,:,2));
            brainSliceMap1(:,:,3) = flipud(brainSliceMap0(:,:,3));
            brainSliceMap = brainSliceMap1;
    end
    
    % store brain slice maps
    brainSliceMaps{iSlice} = brainSliceMap;
    
    % show slice with colored map
    switch plotFormat
        case 'default'
            subplot(nPlotRows, nPlotCols, iSlice)
        case 'singleRow' % plots slices in reverse order
            subplot(nPlotRows, nPlotCols, nPlotCols+1-iSlice)
        otherwise
            error('plotFormat not recognized')
    end
        
    image(brainSliceMap)
    if dimToSlice==4
        title(['Slice ' num2str(slices(iSlice))])
    else
        title(['Slice ' num2str(iSlice)])
    end
    axis off
    
    if strcmp(plotFormat, 'singleRow')
%         axis equal
        axis tight
    end
    
    % set aspect ratio
%     daspect(aspectRatio)

    %%% new %%%
    set(gca, 'Units', 'centimeters')
    set(gca, 'Position', axRect);
    %%%%%%%%%%%
end

%%% new %%%
set(f1,'Position',figPos);
%%%%%%%%%%%