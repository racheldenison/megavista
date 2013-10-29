% Metacontrast Orientation Localizer -- make par files for mrVista

% cd /Volumes/Plata1/Metacontrast/Expt_Files/CG_20130403/localizer/data
% cd /Volumes/Plata1/Metacontrast/Expt_Files/AL_20130911/localizer_20130829/data
cd /Volumes/Plata1/Metacontrast/Expt_Files/AK_20130910/localizer_20130829/data

subjectID = 'AK';
runs = 1;
scanDate = '20130910';

localizerType = 'targetmask'; % 'orientation','targetmask'

includeColors = 0;

blankCol = [128 128 128]./255; % gray
cond1Col = [220 20 60]./255; % red
cond2Col = [0 0 205]./255; % medium blue
colors = {blankCol, cond1Col, cond2Col};

switch localizerType
    case 'targetmask'
        localizerFName = 'TargetMaskLocalizer';
    case 'orientation'
        localizerFName = 'BlockGratings';
    otherwise
        error('localizerType not recognized')
end

for iRun = 1:length(runs)
    run = runs(iRun);
    load(sprintf('%s_run%02d_%s_%s', ...
        subjectID, run, localizerFName, scanDate), 'p'); 
    
    condNames = p.condNames;
    blankCond = find(strcmp(condNames,'blank'));
    stimCondOrder = p.condOrder;
    stimCondOrder(stimCondOrder==blankCond) = 0; % 0 labels mrVista baseline
    
    blockDuration = p.cycleDuration; % in seconds
    nBlocks = numel(p.condOrder);

    stimOnsetTimes = 0:blockDuration:blockDuration*nBlocks;
    stimOnsetTimes(end) = [];
    
    events = [stimOnsetTimes' stimCondOrder'];
    nEvents = size(events,1);
    
    names = {'blank', condNames{1:2}, 'response'};
    for iEvent = 1:nEvents
        eventNames{iEvent,1} = names{events(iEvent,2)+1};
        eventColors{iEvent,1} = colors{events(iEvent,2)+1};
    end
    
    % write text file
    fileName = sprintf('%s_%s_%s_run%02d.par', subjectID, scanDate, localizerType, run);
    fid = fopen(fileName,'w');
    for iEvent = 1:nEvents
        fprintf(fid, '%3.2f\t%d\t%s', events(iEvent,:), eventNames{iEvent});
        if includeColors
            fprintf(fid, '\t[%.02f %.02f %.02f]\n', ...
                eventColors{iEvent}(1), eventColors{iEvent}(2), eventColors{iEvent}(3));
        else
            fprintf(fid, '\n');
        end
    end
    status = fclose(fid);
    
    % report
    if status==0
        fprintf('Wrote par file %s.\n', fileName)
    else
        fprintf('Check par file %s.\n', fileName)
    end
end



