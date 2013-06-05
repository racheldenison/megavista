% This function crops out passive blocks from a time series.
% It was designed to be used with SeedConstruction.m and may require
% modification for use with other data sets.
% Created by Rachel Albert 1/21/13

function [activeTSeries] = clipTSeries(tSeries, cueLen, taskLen)

if ~exist('cueLen','var') || isempty(cueLen)
    cueLen = 3; %TRs
end
if ~exist('taskLen','var') || isempty(taskLen)
    taskLen = 15; %TRs
end

totalPassive = cueLen*2 + taskLen; %TRs, total time to skip between active blocks
startBlock = cueLen + 1; % skip the first cue period
activeTSeries = [];

for i = 1:size(tSeries,1)/(2*(cueLen + taskLen))
    endBlock = startBlock + taskLen - 1;
    activeBlock = tSeries(startBlock:endBlock, :);
    activeTSeries = [activeTSeries; activeBlock];
    startBlock = endBlock + totalPassive + 1;

end
    