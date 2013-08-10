function [t xcol] = rd_makeTimepointSelector(dt, scan, conds, selectedCond)

% Example inputs: 
% dt = 1;
% scan = 1;
% conds = [0 1 2]; % these correspond to the columns of X
% selectedCond = 1; % this will pick out the second column of X, corresponding to cond=1, in this example

include0 = any(conds==0);
X = rd_makeDesignMatrix(dt,scan,1,include0);

xcol = X(:,conds==selectedCond);
thresh = max(xcol)/2;
t = xcol>thresh;

% figure
% plot(xcol)
% hold on
% plot(t,'g')