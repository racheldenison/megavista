function [A, nanRows, nanCols] = rd_removeNanRowsCols(A)
%
% function [A, nanRows, nanCols] = rd_removeNanRowsCols(A)
% assumes entire rows and cols are nans, not just parts of rows

nanCols = isnan(A(1,:));
nanRows = isnan(A(:,1));

A(:,nanCols) = [];
A(nanRows,:) = [];