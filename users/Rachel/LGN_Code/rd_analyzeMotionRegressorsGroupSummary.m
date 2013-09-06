% rd_analyzeMotionRegressorsGroupSummary.m

% load motionRegressors_3T_N4_20130905
load motionRegressors_7T_N7_20130905

mr = motionRegressorsGroup;

for iSubject = 1:numel(mr)
    maxDisp(iSubject,:) = max(mr{iSubject}) - min(mr{iSubject});
    rmsDisp(iSubject,1) = sqrt(mean(mr{iSubject}(:).^2));
end

maxDispMean = mean(maxDisp);
rmsDispMean = mean(rmsDisp);