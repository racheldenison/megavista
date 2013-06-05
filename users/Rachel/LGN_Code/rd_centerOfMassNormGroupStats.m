% rd_centerOfMassNormGroupStats.m

%% tal3T
tal3T = load('groupCenterOfMassTalNorm_3T_N4_betaM-P_prop20_centersThresh000_20130331');
nSubjects3T = numel(tal3T.subjects);

varThreshIdx3T = 5; % idx 5: 0.004

clear c10 c20 c1t c2t
for iHemi = 1:2
    c10(:,:,iHemi) = squeeze(tal3T.groupData.centers1(1,:,:,iHemi))'; % [subject x coord]
    c20(:,:,iHemi) = squeeze(tal3T.groupData.centers2(1,:,:,iHemi))';
    c1t(:,:,iHemi) = squeeze(tal3T.groupData.centers1(varThreshIdx3T,:,:,iHemi))'; % [subject x coord]
    c2t(:,:,iHemi) = squeeze(tal3T.groupData.centers2(varThreshIdx3T,:,:,iHemi))';
end

% for the right hemisphere, flip the x coord to create lateral-medial
% dimension instead of left-right
c10Hemi2XFlip = [1-c10(:,1,2) c10(:,2:3,2)];
c20Hemi2XFlip = [1-c20(:,1,2) c20(:,2:3,2)];
c1tHemi2XFlip = [1-c1t(:,1,2) c1t(:,2:3,2)];
c2tHemi2XFlip = [1-c2t(:,1,2) c2t(:,2:3,2)];

tal3Ts.vt0.centers1Thresh = [c10(:,:,1); c10Hemi2XFlip];
tal3Ts.vt0.centers2Thresh = [c20(:,:,1); c20Hemi2XFlip];
tal3Ts.vtT.centers1Thresh = [c1t(:,:,1); c1tHemi2XFlip];
tal3Ts.vtT.centers2Thresh = [c2t(:,:,1); c2tHemi2XFlip];

% centers difference, mean and ste
tal3Ts.vtT.centersDiffMean = mean(tal3Ts.vtT.centers1Thresh-tal3Ts.vtT.centers2Thresh);
tal3Ts.vtT.centersDiffSte = ...
    std(tal3Ts.vtT.centers1Thresh-tal3Ts.vtT.centers2Thresh)./sqrt(nSubjects3T);

tal3Ts.vt0.centersDiffMean = mean(tal3Ts.vt0.centers1Thresh-tal3Ts.vt0.centers2Thresh);
tal3Ts.vt0.centersDiffSte = ...
    std(tal3Ts.vt0.centers1Thresh-tal3Ts.vt0.centers2Thresh)./sqrt(nSubjects3T);

% t-test
[tal3Ts.vt0.h tal3Ts.vt0.p tal3Ts.vt0.ci tal3Ts.vt0.stat] = ...
    ttest(tal3Ts.vt0.centers1Thresh,tal3Ts.vt0.centers2Thresh);

[tal3Ts.vtT.h tal3Ts.vtT.p tal3Ts.vtT.ci tal3Ts.vtT.stat] = ...
    ttest(tal3Ts.vtT.centers1Thresh,tal3Ts.vtT.centers2Thresh);

%% tal7T
tal7T = load('groupCenterOfMassTalNorm_7T_N7_betaM-P_prop20_centersThresh000_20130331');
nSubjects7T = numel(tal7T.subjects);

varThreshIdx7T = 21; % idx 5: 0.02

clear c10 c20 c1t c2t
for iHemi = 1:2
    c10(:,:,iHemi) = squeeze(tal7T.groupData.centers1(1,:,:,iHemi))'; % [subject x coord]
    c20(:,:,iHemi) = squeeze(tal7T.groupData.centers2(1,:,:,iHemi))';
    c1t(:,:,iHemi) = squeeze(tal7T.groupData.centers1(varThreshIdx7T,:,:,iHemi))'; % [subject x coord]
    c2t(:,:,iHemi) = squeeze(tal7T.groupData.centers2(varThreshIdx7T,:,:,iHemi))';
end

% for the right hemisphere, flip the x coord to create lateral-medial
% dimension instead of left-right
c10Hemi2XFlip = [1-c10(:,1,2) c10(:,2:3,2)];
c20Hemi2XFlip = [1-c20(:,1,2) c20(:,2:3,2)];
c1tHemi2XFlip = [1-c1t(:,1,2) c1t(:,2:3,2)];
c2tHemi2XFlip = [1-c2t(:,1,2) c2t(:,2:3,2)];

tal7Ts.vt0.centers1Thresh = [c10(:,:,1); c10Hemi2XFlip];
tal7Ts.vt0.centers2Thresh = [c20(:,:,1); c20Hemi2XFlip];
tal7Ts.vtT.centers1Thresh = [c1t(:,:,1); c1tHemi2XFlip];
tal7Ts.vtT.centers2Thresh = [c2t(:,:,1); c2tHemi2XFlip];

% centers difference, mean and ste
tal7Ts.vt0.centersDiffMean = mean(tal7Ts.vt0.centers1Thresh-tal7Ts.vt0.centers2Thresh);
tal7Ts.vt0.centersDiffSte = ...
    std(tal7Ts.vt0.centers1Thresh-tal7Ts.vt0.centers2Thresh)./sqrt(nSubjects7T);

tal7Ts.vtT.centersDiffMean = mean(tal7Ts.vtT.centers1Thresh-tal7Ts.vtT.centers2Thresh);
tal7Ts.vtT.centersDiffSte = ...
    std(tal7Ts.vtT.centers1Thresh-tal7Ts.vtT.centers2Thresh)./sqrt(nSubjects7T);

% t-test
[tal7Ts.vt0.h tal7Ts.vt0.p tal7Ts.vt0.ci tal7Ts.vt0.stat] = ...
    ttest(tal7Ts.vt0.centers1Thresh,tal7Ts.vt0.centers2Thresh);

[tal7Ts.vtT.h tal7Ts.vtT.p tal7Ts.vtT.ci tal7Ts.vtT.stat] = ...
    ttest(tal7Ts.vtT.centers1Thresh,tal7Ts.vtT.centers2Thresh);

