% rd_plotGroupMeanIndivRunFStats.m

%% setup
subjectBase = '3T_7T_N4_N7';
dataDir = '/Volumes/Plata1/LGN/Group_Analyses';

saveFigs = 1;

dataFile = dir(sprintf('%s/fOverallMeans_%s*', dataDir, subjectBase));
if numel(dataFile)~=1
    error('Too many or too few data files')
else
    load(dataFile.name);
end

delays = [0 1 2 3];

%% hemispheres separated
f(1) = figure;
hold on
p1(1) = errorbar(delays, mean(fOMeans31), std(fOMeans31)./2,'s-');
p1(2) = errorbar(delays, mean(fOMeans32), std(fOMeans32)./2,'^-');
p1(3) = errorbar(delays, mean(fOMeans71), std(fOMeans71)./2,'s-');
p1(4) = errorbar(delays, mean(fOMeans72), std(fOMeans72)./2,'^-');

colors = {'k','k','b','b'};
for i = 1:numel(p1)
    set(p1(i),'Color',colors{i},'MarkerFaceColor',colors{i});
end
set(gca,'XTick',delays)
xlabel('delay (TR)')
ylabel('F statistic')
title(sprintf('Group means and stes of individual run Fs\nfor each hemisphere and field strength'))

%% hemispheres collapsed
f(2) = figure;
hold on
p2(1) = errorbar(delays, mean([fOMeans31; fOMeans32]), ...
    std([fOMeans31; fOMeans32])./sqrt(8),'.-');
p2(2) = errorbar(delays, mean([fOMeans71; fOMeans72]), ...
    std([fOMeans71; fOMeans72])./sqrt(8),'.-');

colors = {'k','b'};
for i = 1:numel(p2)
    set(p2(i),'Color',colors{i},'MarkerFaceColor',colors{i});
end
set(gca,'XTick',delays)
ylim([0 8])
xlabel('delay (TR)')
ylabel('F statistic')
title(sprintf('Group means and stes of individual run Fs\nfor each hemisphere and field strength'))

%% save figs
if saveFigs
    figNames = {'groupFOverallMeansByHemi', 'groupFOverallMeans'};
    for iF = 1:numel(f)
        figFileName = sprintf('%s/figures/%s_%s_%s.jpg', ...
            dataDir, figNames{iF}, subjectBase, datestr(now,'yyyymmdd'));
        print(f(iF), '-djpeg', figFileName)
    end
end

