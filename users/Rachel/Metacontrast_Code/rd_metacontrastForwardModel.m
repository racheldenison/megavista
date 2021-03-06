% rd_metacontrastForwardModel.m

% assume we're in a directory named for the ROI being analyzed
[upDir, ROI] = fileparts(pwd);

% load orientation localizer fig data
orient = load('orientLoc_multiVoxFigData.mat');

% load metacontrast condbydir fig data
meta = load('metaCondByDir_multiVoxFigData.mat');

% get weights from localizer and parameter estimates from main expt
W = squeeze(orient.figData.glm.betas(:,1:2,:))';
Bexp = squeeze(meta.figData.glm.betas(:,1:14,:))';

% %%%%%% test using timepoints from localizer %%%%%%
% data = load('data_OrientLoc.dat');
% class = load('dataClass_OrientLoc.dat');
% a = [class data];
% b = sortrows(a,1);
% Bexp = b(:,2:end)';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate channel responses from main experiment
Cexp = pinv(W)*Bexp;

lvr = Cexp(1,:)-Cexp(2,:);
% correct direction-ness: top row is 'left presented', bottom row is 'right
% presented'
correctness = reshape(lvr',size(lvr,2)/2,2)';
correctness(2,:) = -1*correctness(2,:); % flip 'right presented' conditions

% plot orientation localizer weights (betas)
figure
hold on
plot(W)
plot([1 size(W,1)],[0 0],'--k')
legend('left','right')
ylabel('orientation localizer weight (beta)')
title(ROI)

% plot channel responses
figure
plot(Cexp')
legend('left channel','right channel','location','best')
ylabel('channel response')
title(ROI)

% plot correct direction-ness
figure
hold on
plot(correctness')
plot(mean(correctness),'k','LineWidth',2)
legend('left presented','right presented','mean','location','best')
plot([1 size(correctness,2)],[0 0],'--k')
ylabel('reconstructed correct direction-ness')
xlabel('SOA condition')
title(ROI)