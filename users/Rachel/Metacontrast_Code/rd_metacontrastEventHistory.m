% rd_metacontrastEventHistory.m

X = [];
for run = 1:10
    fid = fopen(sprintf('CG_20130403_conditionwise_run%02d.par', run));
    parData = textscan(fid, '%f%d%s');
    fclose(fid);
    
    eventTime = parData{1};
    eventCond = parData{2};
    
    conds = unique(eventCond);
    nConds = numel(conds);
    nSecs = eventTime(end)+1; % add 1 since first event time is 0
    
    Xnow = zeros(nSecs, nConds);
    for iCond = 1:nConds
        cond = conds(iCond);
        Xnow(eventTime(eventCond==cond)+1,iCond) = 1;
    end
    X = [X; Xnow];
end

nHist = 24;
Xpad = [zeros(nHist, nConds); X];

% get the trial history for nHist duration for each condition
Xhist = zeros(nHist, nConds, nConds);
for iCond = 1:nConds
    eventIdxs = find(Xpad(:,iCond)==1);
    nEvents = numel(eventIdxs);
    eventHist = zeros(nHist, nConds, nEvents);
    for iEvent = 1:nEvents
        eventIdx = eventIdxs(iEvent);
        timeRange = eventIdx-nHist+1:eventIdx;
        eventHist(:,:,iEvent) = Xpad(timeRange,:);
    end
    Xhist(:,:,iCond) = sum(eventHist,3);
end

XhistAllConds = squeeze(sum(Xhist(:,2:end,:),2)); % don't sum across the blank cond
XhistBlanks = squeeze(Xhist(:,1,:)); % blank only

% plot figs
for iCond = 1:nConds
    figure
    imagesc(Xhist(:,:,iCond))
    title(sprintf('cond = %d', conds(iCond)))
end

figure
plot(XhistAllConds(:,2:end)) % don't include blank
title('all conds collapsed')
legend(num2str(conds(2:end)),'Location','best')

figure
plot(XhistBlanks(:,2:end))
title('blank history only')
legend(num2str(conds(2:end)),'Location','best')
