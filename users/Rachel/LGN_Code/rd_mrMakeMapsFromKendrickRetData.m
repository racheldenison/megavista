% rd_mrMakeMapsFromKendrickRetData.m

retDataPath = '../from_Kendrick/20120499_ret.mat';
mapSaveDir = 'Inplane/Original';

ret = load(retDataPath);

fieldNames = fieldnames(ret);

for iField = 1:numel(fieldNames)
    f = fieldNames{iField};
    mapName = f;
    map{1} = ret.(f);
    save(sprintf('%s/%s.mat', mapSaveDir, mapName), 'mapName', 'map')
end