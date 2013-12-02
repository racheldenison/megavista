function X = rd_substituteCustomGLMMetacontrast(X0, trials)

% pass in X as X0
% pass in stim as trials
% need acc, which is a conds x runs matrix of accuracies
% need vis, which is a conds x runs matrix of visibilities

% % for testing:
% acc = repmat((1:7)',1,10)./7; % low values for low conditions, high values for high conditions
% vis = flipud(acc); % vice versa

% load behav data
load behav.mat

% the following is based on glm_convolve.m
nConds = length(unique(trials.cond(trials.cond>0)));
nRuns = length(unique(trials.run));

runNums = unique(trials.run);
for iRun = 1:nRuns
    run = runNums(iRun);
    whichTrials = find(trials.run==run); % trials in current run
    runStart = min(trials.onsetFrames(whichTrials));
    runEnd = max(trials.onsetFrames(whichTrials));
    rng = runStart:runEnd;
    
    XTrials(rng,1) = X0(rng,1:nConds)*ones(nConds,1);
    XAcc(rng,1) = X0(rng,1:nConds)*acc(:,iRun);
    XSeen(rng,1) = X0(rng,1:nConds)*seen(:,iRun);
    
%     % for testing:
%     figure
%     imagesc([X0(rng,1:nConds) XTrials(rng) XAcc(rng) XSeen(rng)])
end

% form the new X
X = [XTrials XAcc XSeen X0(:,nConds+1:end)];