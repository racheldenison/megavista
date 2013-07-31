% rd_plotSingleTrialDataByClass.m

%% load data
data = load('data_SOACode5.dat');
class = load('dataClass_SOACode5.dat');

classes = unique(class);
nClasses = numel(classes);

%% divide trials into classes
for iClass = 1:nClasses
    c = classes(iClass);
    dataByClass(:,:,iClass) = data(class==c,:);
end
nTrialsPerClass = size(dataByClass,1);
cLims = rd_zeroCenterCLim(data);

%% plot all trials by class
for iClass = 1:nClasses
    figure
    imagesc(dataByClass(:,:,iClass),cLims)
    xlabel('voxel')
    ylabel('trial')
    title(sprintf('class = %d', classes(iClass)))
    colorbar
end

%% find mean and ste of each class
for iClass = 1:nClasses
    dataMean(iClass,:) = mean(dataByClass(:,:,iClass));
    dataSte(iClass,:) = std(dataByClass(:,:,iClass))./sqrt(nTrialsPerClass);
end

%% ttest comparing classes
% this assumes only 2 classes
[h p ci stat] = ttest(dataByClass(:,:,1),dataByClass(:,:,2));

%% plot mean, ste, t-stat
colors = {'b','r'};
figure
hold on
for iClass = 1:nClasses
    plot(dataMean(iClass,:),colors{iClass});
end
plot(stat.tstat,'g') % see also plotyy
legend('class 0', 'class 1','t-stat')
for iClass = 1:nClasses
    shadedErrorBar([],dataMean(iClass,:),dataSte(iClass,:),colors{iClass});
end
xlabel('voxel')
ylabel('mean beta across trials / t-stat of class comparison')
