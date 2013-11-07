% rd_mrMakeMPDiffConnectivityMap.m

hemi = 1;
analStr = 'rfng';
measure = 'cor';

mMap = load(sprintf('Inplane/Original/lgnROI%d_M_to_gray_%s_%s.mat', hemi, analStr, measure));
pMap = load(sprintf('Inplane/Original/lgnROI%d_P_to_gray_%s_%s.mat', hemi, analStr, measure));
nScans = numel(mpDiffMap.map);

for iScan = 1:nScans
    % difference of M map and P map
    mpDiffMap.map{iScan} = mMap.map{iScan} - pMap.map{iScan};
    % average of co fields for the two maps
    mpDiffMap.co{iScan} = (mMap.co{iScan} + pMap.co{iScan})/2;
end

mpDiffMap.mapName = sprintf('lgnROI%d_M-P_to_gray_%s_%s', hemi, analStr, measure);
mpDiffMap.mapUnits = sprintf('%s difference', measure);

mpDiffMap.mapInfo.mMap = mMap.mapInfo;
mpDiffMap.mapInfo.pMap = pMap.mapInfo;

% store fields in separate variables for saving
mapInfo = mpDiffMap.mapInfo;
map = mpDiffMap.map;
co = mpDiffMap.co;
mapName = mpDiffMap.mapName;
mapUnits = mpDiffMap.mapUnits;

% save map
save(sprintf('Inplane/Original/%s.mat', mapName), ...
    'mapInfo', 'map', 'co', 'mapName', 'mapUnits')