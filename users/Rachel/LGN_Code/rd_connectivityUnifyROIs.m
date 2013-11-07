function A = rd_connectivityUnifyROIs(A, allROIs, subjectROIs, fromROI, toROI)

% A is the subject's connectivity matrix (rows and columns should be the 
% same, and there should be one for each ROI in allROIs)
% allROIs is the list of all ROIs in the (group) connectivity matrix
% subjectROIs is the list of the ROIs we have for the current subject
% fromROI is the name of the ROI you are getting the data from
% toROI is the ROI slot you want to copy the data to. we check to make sure
% the subject does not already have this ROI before copying data into that
% slot.

toROIIdx = find(strcmp(allROIs, toROI)); 
fromROIIdx = find(strcmp(allROIs, fromROI)); 

% copy "fromROI" rows and colums to "toROI" rows and columns
if ~any(strcmp(subjectROIs, toROI))
    A(:,toROIIdx) = A(:,fromROIIdx);
    A(toROIIdx,:) = A(fromROIIdx,:);
end
