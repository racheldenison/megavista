function [X, hrf] = glm_convolve_1s(trials, params, hrf, nFrames)

% Make the TR 1 s for purposes of defining the HRF
paramsTR1s = params;
paramsTR1s.framePeriod = 1;

if notDefined('hrf')
    hrf = glm_hrf(paramsTR1s);
end

if notDefined('nFrames')
    nFrames = trials.onsetFrames(end);
end

if ischar(hrf)      % name of a 'canned' HRF: get from glm_hrf
    params.glmHRF = hrf;
    hrf = glm_hrf(params);
end

% params
nConds = length(unique(trials.cond(trials.cond>0)));
nRuns = length(unique(trials.run));

TR = trials.TR;
nSecs = nFrames*TR;
% init design matrix
% RD: let the time resolution be 1 s
X = zeros(nSecs, nConds+nRuns);

% RD: change frames to secs
% set up delta functions of onset frames for each condition
% (first nConds columns)
for i = 1:nConds
    ind = trials.onsetSecs(trials.cond==i) + params.onsetDelta + 1; % add 1, since onsetSecs starts at 0 = scan start
%     ind = ind(ind>0 & ind<nSecs); % RD: this could lead to invisible errors
    X(ind,i) = 1;
end

% if multiple trials are specified for each event (block-design),
% replicate the non-null trials the appropriate # of times
if isfield(params, 'eventsPerBlock') && max(params.eventsPerBlock) > 1
    % first, figure out how many times to replicate each onset:
    % For now, let's assume 'eventsPerBlock' directly specifies 
    % this number:
    duration = params.eventsPerBlock*TR; % RD: convert to secs
    while length(duration) < nConds
        duration(end+1) = duration(end);
    end
    
    for i = 1:nConds
        % get a duration for this condition
        nRep = duration(i);
        for j = find(X(:,i))' % for each onset in this column
            rng = j:j+nRep-1;
            rng = rng(rng>1 & rng<size(X,1));
            X(rng,i) = 1;
        end                        
    end
end

% Old code:
% convolve first nConds columns with hrf to make predictors
% for i = 1:nConds
%     tmp = conv2(X(:,i), hrf(:), 'full');
%     tmp = tmp(1:nFrames); % trim back to right length
%     X(:,i) = tmp;
% end

% New code:
% The convolution of the HRF should not extend beyond a run.  In the
% previous code, the runs were all stacked together and the convolution
% applied, which meant that predictions from one run were carried into the
% next run.  Here, we fixed this bug by separately applying the HRF to each
% run and then stacking them all together into the design matrix.
rowInds = 0;
for s = 1:nRuns
    rowInds = (1:trials.framesPerRun(s)*TR)+rowInds(end); % RD: convert frames to secs
    tmp = conv2(X(rowInds,1:nConds), hrf(:), 'full');
    tmp = tmp(1:trials.framesPerRun(s)*TR,:); % trim back to right length
    X(rowInds,1:nConds) = tmp;
end
% figure; plot(X)

% the remaining nRuns columns are constant terms for each runs
% (1s during each run, 0 otherwise)
% RD: again use secs instead of frames
runNums = unique(trials.run);
for i = 1:nRuns
    run = runNums(i);
    whichTrials = find(trials.run==run); % trials in current run
    runStart = min(trials.onsetFrames(whichTrials)*TR) - TR + 1; % RD: convert to secs
    runEnd = max(trials.onsetFrames(whichTrials)*TR); % RD: use frames*TR to get the whole run
    rng = runStart:runEnd;
    rng = rng(ismember(rng,1:nSecs));
    X(rng,nConds+i) = 1; %/length(rng);
end

% RD: downsample from seconds to frames
if TR-round(TR) ~= 0
    error('TR must be an integer to use the 1s version of glm_convolve.m')
else
    X = X(1:TR:end,:); % take the first frame for each TR
end


% % pad out: assign any remaining frames to last scan 
% X(rng(2)+1:end,end) = 1;

return