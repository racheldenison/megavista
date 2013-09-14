% rd_analyzeMotionRegressorsGroupSummary.m

% load motionRegressors_3T_N4_20130905
load motionRegressors_7T_N7_hemiMPOnly_20130913

fdThresh = 0.5;

mr = motionRegressorsGroup;

for iSubject = 1:numel(mr)
    frameDiff = diff(mr{iSubject});
    frameDiffXYZ = frameDiff(:,4:6);
    frameDiffPRY = frameDiff(:,1:3)*50; % (arc length in rad / 2pi) * 2pi*r, for a radius of 50 mm (Power 2012 Neuroimage)
    frameDiffMm = [frameDiffPRY frameDiffXYZ];
    
    mrXYZ = mr{iSubject}(:,4:6);
    mrPRY = mr{iSubject}(:,1:3);
    refDispXYZ = sqrt(sum(mrXYZ.^2,2)); % absolute displacement from the reference scan
    refRotDeg = sum(abs(mrPRY),2)*180/pi; % absolute rotation from the reference scan in degrees

    rmsDispXYZ(iSubject,1) = mean(sqrt(sum(frameDiffXYZ.^2,2))); % "mean relative displacement" (Van Dijk 2012 Neuroimage)
    framewiseDisp = sum(abs(frameDiffMm),2); % "framewise displacement" (Power 2012 Neuroimage)
    fd(iSubject,1) = mean(framewiseDisp); 
    maxRefDispXYZ(iSubject,:) = max(refDispXYZ) - min(refDispXYZ);
    maxRefRotDeg(iSubject,:) = max(refRotDeg) - min(refRotDeg);
    
    propFDSuperthresh(iSubject,1) = nnz(framewiseDisp>fdThresh)/numel(framewiseDisp);
    
    figure
    subplot(5,1,1)
    plot(mr{iSubject})
    subplot(5,1,2)
    plot(frameDiff)
    ylim([-1 1])
    subplot(5,1,3)
    plot(framewiseDisp)
    ylim([0 2])
    subplot(5,1,4)
    plot(refDispXYZ)
    subplot(5,1,5)
    plot(refRotDeg)
    title(['Subject ' num2str(iSubject)])
end

rmsDispXYZMean = mean(rmsDispXYZ);
fdMean = mean(fd);
maxRefDispXYZMean = mean(maxRefDispXYZ);
maxRefRotDegMean = mean(maxRefRotDeg);
