function vw = rd_renameROIs(vw, expr, replacement)

% the expr is a regular expression
% examples:
% 1) To replace _ followed by anything:
%    rd_renameROIs(vw,'_\w*','');

nROIs = numel(vw.ROIs);

for iROI = 1:nROIs
    name = vw.ROIs(iROI).name;
    newName = regexprep(name, expr, replacement);
    vw.ROIs(iROI).name = newName;
end