% rd_mrMakeFaceSceneParfile.m

% load Face Scene Localizer workspace data file

subjectID = 'SB';
scanDate = '20130524';
run = 1;

includeColors = 0;

fileName = sprintf('%s_%s_run%02d.par', subjectID, scanDate, run);

condNames = {'face','scene','blank'};

blockDur = Loc.BlockTime;
blockOrder = Loc.BlockOrder;
nBlocks = numel(blockOrder);

blockTimes = (1:nBlocks).*blockDur - blockDur;

for iBlock = 1:nBlocks
    blockNames{iBlock} = condNames{blockOrder(iBlock)};
end

rd_mrWriteParfile(fileName, blockTimes, blockOrder, blockNames);
