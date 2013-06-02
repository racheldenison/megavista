function status = rd_mrWriteParfile(fileName, eventTimes, eventCodes, eventNames, eventColors)

% function rd_mrWriteParfile(eventTimes, eventCodes, eventNames,
% eventColors)
%
% eventColors is optional

if nargin < 5 || isempty(eventColors)
    includeColors = 0;
end

nEvents = numel(eventTimes);

% write text file
fid = fopen(fileName,'w');
for iEvent = 1:nEvents
    fprintf(fid, '%3.2f\t%d\t%s', eventTimes(iEvent), eventCodes(iEvent), eventNames{iEvent});
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