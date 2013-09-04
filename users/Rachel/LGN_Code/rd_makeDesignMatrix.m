function X = rd_makeDesignMatrix(dt,scan,convolveHRF,includeCond0)
%
% X = rd_makeDesignMatrix(dt,scan,[convolveHRF],[includeCond0])
%
% Make a design matrix X for a given data type (dt) and scan. This looks up
% the parfile for this scan and uses this to create the design matrix.
% 
% Options for convolving with an HRF (currently only the SPM hrf is
% available, which NB may not be the one you're using for your mrVista
% GLM), and including a regressor for condition 0. This is often the blank
% or null condition and should not be included in a GLM, but it may be
% useful to have this regressor for other purposes -- for example,
% selecting time points during the null condition.
%
% Example inputs:
% dt = 1;
% scan = 1;
% convovleHRF = 1; 
% includeCond0 = 0;

if nargin<3 || isempty(convolveHRF)
    convolveHRF = 1;
end
if nargin<4 || isempty(includeCond0)
    includeCond0 = 0;
end

load mrSESSION

scanParams = dataTYPES(dt).scanParams(scan);

parfile = scanParams.parfile;
TR = scanParams.framePeriod;
nFrames = scanParams.nFrames;
blockLength = dataTYPES(dt).eventAnalysisParams(scan).eventsPerBlock;

fprintf('\nparfile: %s', parfile)
fprintf('\nTR: %1.2f s', TR)
fprintf('\nNumber of frames in scan: %d', nFrames)
fprintf('\nBlock length: %d TRs\n', blockLength)

% [seconds, conditions, labels, colors] = ...
%     textread(sprintf('Stimuli/parfiles/%s', parfile), '%f %d %s %16c');

fid = fopen(sprintf('Stimuli/parfiles/%s', parfile));
C = textscan(fid, '%f %d %s %*[^\n]'); % skip the rest of the line
fclose(fid);

seconds = C{1};
conditions = C{2};

frames = seconds/TR + 1; % parfiles start at time zero

conds = unique(conditions);
if ~includeCond0
    conds(conds==0) = [];
end

X = zeros(nFrames,numel(conds));
for iCond = 1:numel(conds)
    cond = conds(iCond);
    for startIdx = frames(conditions==cond)' % iterable needs to be 1xn - crazy.
        endIdx = startIdx + blockLength-1;
        X(startIdx:endIdx,iCond) = 1;
    end
end

if convolveHRF
    fprintf('\nConvolving with SPM hrf\n')
    hrf = spm_hrf(TR);
    
    X = conv2(X,hrf);
    X = X(1:nFrames,:);
end

