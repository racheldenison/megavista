% Metacontrast Orientation Localizer -- make par files for mrVista

cd /Volumes/Plata1/Metacontrast/Expt_Files/CG_20130403/localizer/data

subjectID = 'CG';
runs = 1;
scanDate = '20130403';

includeColors = 0;

blankCol = [128 128 128]./255; % gray
leftCol = [220 20 60]./255; % red
rightCol = [0 0 205]./255; % medium blue
colors = {blankCol, leftCol, rightCol};


for iRun = 1:length(runs)
    run = runs(iRun);
    load(sprintf('%s_run%02d_BlockGratings_%s', ...
        subjectID, run, scanDate), 'p'); 
    
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
    fileName = sprintf('%s_%s_orientation_run%02d.par', subjectID, scanDate, run);
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



