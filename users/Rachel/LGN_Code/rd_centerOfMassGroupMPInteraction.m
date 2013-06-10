% rd_centerOfMassGroupMPInteraction

%% setup
scanner = '7T';
coordsType = 'Talairach'; %'Epi','Volume','Talairach'
propStr = 'prop20-80'; % check that you are actually loading these props
useVarThresh = 0;

saveFigs = 0;

if useVarThresh
    switch scanner
        case '3T'
            varThreshIdx = 5;
            cVarThresh = 0.004;
        case '7T'
            varThreshIdx = 21;
            cVarThresh = 0.02;
        otherwise
            error('scanner not recognized')
    end
else
    varThreshIdx = 1;
    cVarThresh = 0;
end
threshStr = sprintf('centersThresh%03d', round(cVarThresh*1000));

MCol = [220 20 60]./255; % red
PCol = [0 0 205]./255; % medium blue
colors = {MCol, PCol};

switch coordsType
    case 'Epi'
        coordsExtension = '';
    case 'Volume'
        coordsExtension = 'Vol';
    case 'Talairach'
        coordsExtension = 'Tal';
    otherwise
        error('coordsType not recognized')
end

%% load data
% m = load('groupCenterOfMass_7T_N4_betaM_prop20_20120321');
% p = load('groupCenterOfMass_7T_N4_betaP_prop80_20120321');
switch scanner
    case '3T'
        m = load(sprintf('groupCenterOfMass%s_3T_N4_betaM_prop20_20130404.mat', coordsExtension));
        p = load(sprintf('groupCenterOfMass%s_3T_N4_betaP_prop80_20130404.mat', coordsExtension));
    case '7T'
        m = load(sprintf('groupCenterOfMass%s_7T_N7_betaM_prop20_20130404.mat', coordsExtension));
        p = load(sprintf('groupCenterOfMass%s_7T_N7_betaP_prop80_20130404.mat', coordsExtension));
    otherwise
        error('scanner not recognized')
end     

nSubjects = numel(m.subjects);
varThreshs = m.groupMean.varThreshs(:,1);
nVox = m.groupData.nSuperthreshVox;

%% File I/O
fileBaseDir = '/Volumes/Plata1/LGN/Group_Analyses';
fileBaseSubjects = sprintf('%s_N%d', scanner, nSubjects);
fileBaseTail = sprintf('%s_%s_%s', propStr, threshStr, datestr(now,'yyyymmdd'));

%% M centers z
m.centers1z = squeeze(m.groupData.centers1(:,3,:,:)); % [thresh x sub x hemi]
m.centers2z = squeeze(m.groupData.centers2(:,3,:,:));

% if 'more M' is more ventral, these differences should be negative
m.centersDiff = m.centers1z - m.centers2z;

%% P centers z
p.centers1z = squeeze(p.groupData.centers1(:,3,:,:)); % [thresh x sub x hemi]
p.centers2z = squeeze(p.groupData.centers2(:,3,:,:));

% if 'more P' is more dorsal, these differences should be positive
p.centersDiff = p.centers1z - p.centers2z;

%% Plot
%% scatter plot
cmap = colormap(lines);
close(gcf)
xbound = max(abs(m.centersDiff(:)));
ybound = max(abs(p.centersDiff(:)));

f(1) = figure;
for hemi = 1:2
    subplot(1,2,hemi)
    hold on
    plot([-xbound xbound],[0 0],'k')
    plot([0 0],[-ybound ybound],'k')
    
    for iSubject = 1:nSubjects
        %     scatter(m.centersDiff(:,iSubject,hemi), p.centersDiff(:,iSubject,hemi),...
        %         (varThreshs*8000)+1, cmap(iSubject,:),'filled')
        scatter(m.centersDiff(:,iSubject,hemi), p.centersDiff(:,iSubject,hemi),...
            nVox(:,iSubject,hemi), cmap(iSubject,:),'filled')
    end
    xlabel('more M relative center (V<-->D)')
    ylabel('more P relative center (V<-->D)')
    title(sprintf('hemi %d', hemi))
    axis tight
    axis square
end
rd_supertitle(sprintf('%s N=%d, %s, prop %.01f, %s coords', ...
    m.scanner, nSubjects, m.mapName, m.prop, coordsType))

%% interaction bar plot
f(2) = figure;
mzdiff0 = squeeze(m.centersDiff(varThreshIdx,:,:)); % to change var thresh, just change this index
pzdiff0 = squeeze(p.centersDiff(varThreshIdx,:,:));
bar([mzdiff0(:) pzdiff0(:)])
colormap([colors{1}; colors{2}])
xlabel('hemisphere')
ylabel('center of mass (V<-->D)')
title(sprintf('%s N=%d, beta prop %.01f, %s, %s coords', ...
    m.scanner, nSubjects, m.prop, threshStr, coordsType))
legend('M relative center', 'P relative center','Location','Best')

%% mp comparison bar plot
f(3) = figure;
mzcenters1z0 = squeeze(m.centers1z(varThreshIdx,:,:));
pzcenters1z0 = squeeze(p.centers1z(varThreshIdx,:,:));
bar([mzcenters1z0(:) pzcenters1z0(:)])
colormap([colors{1}; colors{2}])
xlabel('hemisphere')
ylabel('center of mass (V<-->D)')
title(sprintf('%s N=%d, beta prop %.01f, %s, %s coords', ...
    m.scanner, nSubjects, m.prop, threshStr, coordsType))
legend('high betaM group', 'high betaP group','Location','Best')

%% save figs
figExtensions = {'Scatter_MPInteraction','Bar_MPInteraction','Bar_MPComparison'};
if saveFigs
    for iF = 1:numel(f)
        plotSavePath = sprintf('%s/figures/groupCom%s%s_%s_%s',...
            fileBaseDir, coordsExtension, figExtensions{iF}, ...
            fileBaseSubjects, fileBaseTail);
        print(f(iF),'-djpeg',sprintf(plotSavePath));
    end
end



