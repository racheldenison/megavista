% rd_mpBetaReliabilityGroupStats.m

%% 3T
data3T = load('groupIndivScanBetaCorrelations_3T_N4_20130113');

% all hemispheres, condNames = [M P M-P]
stat3T.vals = [data3T.groupData.runPairCorrMeans(:,:,1); ...
    data3T.groupData.runPairCorrMeans(:,:,2)];

stat3T.n = size(stat3T.vals,1);

stat3T.groupMean = mean(stat3T.vals);
stat3T.groupSte = std(stat3T.vals)./sqrt(stat3T.n);


%% 7T
data7T = load('groupIndivScanBetaCorrelations_7T_N7_20130406');

% all hemispheres, condNames = [M P M-P]
stat7T.vals = [data7T.groupData.runPairCorrMeans(:,:,1); ...
    data7T.groupData.runPairCorrMeans(:,:,2)];

stat7T.n = size(stat7T.vals,1);

stat7T.groupMean = mean(stat7T.vals);
stat7T.groupSte = std(stat7T.vals)./sqrt(stat7T.n);