function optseq2parfile_conditionwise(subjectID,scanDate,run)
%Elizabeth Counterman, April 2013
%Input subject ID (ex. CG), scanDate (ex. 20130403), run (ex. 1)
%Asks you to navigate to the optseq file used to present stimuli for that
%run
%Writes to a par file for use with mrVista CONDITION-WISE ANALYSIS!

optseqFile = uigetfile('Stimuli/optseq/*.*');
fid = fopen(['Stimuli/optseq/' optseqFile]);
stimOrder = textscan(fid, '%f%f%f%f%s');
fclose(fid);

nEvents = length(stimOrder{1});
condNames = {};
condCodes = zeros(nEvents,1);

% write text file
fileName = sprintf('Stimuli/parfiles/%s_%s_conditionwise_run%02d.par', subjectID, scanDate, run);
fid = fopen(fileName,'w');
for iEvent = 1:nEvents
    if strcmp(stimOrder{5}(iEvent),'NULL')
        condCodes(iEvent) = 0;
        condNames{iEvent} = 'NULL';
    else
        condCodes(iEvent) = str2double(char(strtok(stimOrder{5}(iEvent),'_')));
        if condCodes(iEvent) < 6
            condNames{iEvent} = sprintf('SOA_%d',condCodes(iEvent));
        elseif condCodes(iEvent) == 6
            condNames{iEvent} = 'target_only';
        elseif condCodes(iEvent) == 7
            condNames{iEvent} = 'mask_only';
        else
            error('Had trouble identifying condition number. Try again')
        end
    end
    
    fprintf(fid, '%3.2f\t%d\t%s', stimOrder{1}(iEvent), condCodes(iEvent), condNames{iEvent});
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