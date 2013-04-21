% rd_centerOfMassGroupStats.m

%% tal3T
tal3T = load('groupCenterOfMassTal_3T_N4_betaM-P_prop20_20130404');
nSubjects3T = numel(tal3T.subjects);

clear c10 c20
for iHemi = 1:2
    c10(:,:,iHemi) = squeeze(tal3T.groupData.centers1(1,:,:,iHemi))'; % [subject x coord]
    c20(:,:,iHemi) = squeeze(tal3T.groupData.centers2(1,:,:,iHemi))';
end

% for the right hemisphere, flip the x coord to create lateral-medial
% dimension instead of left-right
tal3Ts.centers1Thresh0 = [c10(:,:,1); c10(:,:,2).*repmat([-1 1 1],nSubjects3T,1)];
tal3Ts.centers2Thresh0 = [c20(:,:,1); c20(:,:,2).*repmat([-1 1 1],nSubjects3T,1)];

[tal3Ts.h tal3Ts.p tal3Ts.ci tal3Ts.stat] = ...
    ttest(tal3Ts.centers1Thresh0,tal3Ts.centers2Thresh0);

%% tal7T
tal7T = load('groupCenterOfMassTal_7T_N7_betaM-P_prop20_20130404');
nSubjects7T = numel(tal7T.subjects);

clear c10 c20
for iHemi = 1:2
    c10(:,:,iHemi) = squeeze(tal7T.groupData.centers1(1,:,:,iHemi))'; % [subject x coord]
    c20(:,:,iHemi) = squeeze(tal7T.groupData.centers2(1,:,:,iHemi))';
end

% for the right hemisphere, flip the x coord to create lateral-medial
% dimension instead of left-right
tal7Ts.centers1Thresh0 = [c10(:,:,1); c10(:,:,2).*repmat([-1 1 1],nSubjects7T,1)];
tal7Ts.centers2Thresh0 = [c20(:,:,1); c20(:,:,2).*repmat([-1 1 1],nSubjects7T,1)];

[tal7Ts.h tal7Ts.p tal7Ts.ci tal7Ts.stat] = ...
    ttest(tal7Ts.centers1Thresh0,tal7Ts.centers2Thresh0);

