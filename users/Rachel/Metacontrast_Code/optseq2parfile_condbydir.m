function optseq2parfile_condbydir(subjectID,scanDate,run)
%Elizabeth Counterman, April 2013
%Input subject ID (ex. CG), scanDate (ex. 20130403), run (ex. 1)
%Asks you to navigate to the optseq file used to present stimuli for that
%run
%Writes to a par file for use with mrVista CONDITION-WISE ANALYSIS!
%
% Modified by RD, 2013-08-02
% From optseq2parfile_conditionwise
% Makes parfiles with 14 conditions - 7 SOA conditions by 2 directions (l/r)
% Run from within subject folder

optseqFile = uigetfile('Stimuli/optseq/*.*');
fid = fopen(['Stimuli/optseq/' optseqFile]);
stimOrder = textscan(fid, '%f%f%f%f%s');
fclose(fid);

nEvents = length(stimOrder{1});
condNames = {};
condCodes = zeros(nEvents,1);
condDirCodes = zeros(nEvents,1);

orients = zeros(nEvents,1);
orients(~cellfun(@isempty,strfind(stimOrder{5},'left'))) = 1;
orients(~cellfun(@isempty,strfind(stimOrder{5},'right'))) = 2;
directions = {'left','right'};

% get event info
for iEvent = 1:nEvents
    if strcmp(stimOrder{5}(iEvent),'NULL')
        condCodes(iEvent) = 0;
        condNames{iEvent} = 'NULL';
    else
        direction = directions{orients(iEvent)};
        condCodes(iEvent) = str2double(char(strtok(stimOrder{5}(iEvent),'_')));
        if condCodes(iEvent) < 6
            condNames{iEvent} = sprintf('SOA_%d_%s',condCodes(iEvent), direction);
        elseif condCodes(iEvent) == 6
            condNames{iEvent} = sprintf('target_only_%s', direction);
        elseif condCodes(iEvent) == 7
            condNames{iEvent} = sprintf('mask_only_%s', direction);
        else
            error('Had trouble identifying condition number. Try again')
        end
    end
end

% write text file
nConds = numel(unique(condCodes))-1; % don't inlcude null
fileName = sprintf('Stimuli/parfiles/%s_%s_condbydir_run%02d.par', subjectID, scanDate, run);
fid = fopen(fileName,'w');
for iEvent = 1:nEvents
    if orients(iEvent)==2 % right orientation
        condDirCodes(iEvent) = condCodes(iEvent)+nConds;
    else
        condDirCodes(iEvent) = condCodes(iEvent);
    end
    
    fprintf(fid, '%3.2f\t%d\t%s', stimOrder{1}(iEvent), condDirCodes(iEvent), condNames{iEvent});
    fprintf(fid, '\n');
end
status = fclose(fid);

% report
if status==0
    fprintf('Wrote par file %s.\n', fileName)
else
    fprintf('Check par file %s.\n', fileName)
end

end