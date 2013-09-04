% rd_decodeOrientationLocPrep.m
%
% see also: rd_metacontrastGLMToSVM.m

dt = 3;
scan = 13;
conds = [1 2];
roiName = 'Target_V1';

% file I/O
multiVoxFile = sprintf('ROIAnalysis/%s/orientLoc_multiVoxFigData.mat', roiName);
dataFile = sprintf('ROIAnalysis/%s/data_OrientLoc.mat', roiName);
classFile = sprintf('ROIAnalysis/%s/dataClass_OrientLoc.mat', roiName);

% load multiVoxFigData from ROI analysis directory
load(multiVoxFile)

% make timepoint selector for left and right blocks
for iCond = 1:numel(conds)
    cond = conds(iCond);
    t(:,iCond) = rd_makeTimepointSelector(dt,scan,conds,cond);
end

% get data and class for each time point
data = figData.tSeries;
class = t(:,1)*1 + t(:,2)*2;

% get rid of blank time points
data(class==0,:) = [];
class(class==0,:) = [];
class = class - 1; % make classes 0 and 1 to be consistent

% save data and class files
save(dataFile, 'data', '-ascii')

fid = fopen(classFile,'wt');
fprintf(fid, '%d\n', class);
fclose(fid);