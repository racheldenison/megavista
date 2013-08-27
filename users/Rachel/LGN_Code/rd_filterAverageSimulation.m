% rd_filterAverageSimulation.m

%% construct the time series
% we want to get out x1, which is in the desired frequency range
t = 0:2:360;
x1 = sin(2*pi*.05*t);
x2 = sin(2*pi*.2*t);
x3 = sin(2*pi*.001*t);
x = x1+x2+x3;

figure
hold on
plot(t,x1)
plot(t,x2,'g')
plot(t,x3,'r')
plot(t,x,'k')
xlabel('time (s)')

%% specify filter properties
freqRange = [.009 .08];
Fs = 0.5;

%% make noisy voxel time series
nVox = 10;
voxNoisy = repmat(x',1,nVox) + randn(length(x),nVox); % [time x vox]

figure
plot(voxNoisy)

%% make a noisy time nuisance time series that's correlated with the voxels
nuisance = x' + randn(length(x),1);
nuisanceFilt = rd_bandpass(nuisance, freqRange, Fs);
nuisanceX = [nuisanceFilt ones(length(nuisance),1)];

figure
hold on
plot(nuisanceX)
plot(nuisance,'g')
plot(nuisanceFilt,'k')

%% option A: filter/regress then average
tSeriesAFilt = rd_bandpass(voxNoisy, freqRange, Fs);
for iVox = 1:nVox
    [b bint tSeriesARegress(:,iVox)] = regress(tSeriesAFilt(:,iVox), nuisanceX);
end
% tSeriesAMean = mean(tSeriesAFilt,2);
tSeriesAMean = mean(tSeriesARegress,2);

figure
hold on
% plot(tSeriesAFilt)
plot(tSeriesARegress)
plot(tSeriesAMean,'k','LineWidth',2)
title('filter/regress then average')

%% option B: average then filter/regress
tSeriesBMean = mean(voxNoisy,2);
tSeriesBFilt = rd_bandpass(tSeriesBMean, freqRange, Fs);
[b bint tSeriesBRegress] = regress(tSeriesBFilt, nuisanceX);

figure
hold on
plot(tSeriesBMean)
% plot(tSeriesBFilt,'k','LineWidth',2)
plot(tSeriesBRegress,'k','LineWidth',2)
title('average then filter/regress')

%% compare methods
figure
hold on
plot(tSeriesAMean,'b')
% plot(tSeriesBFilt,'r')
plot(tSeriesBRegress,'r')
legend('filter/regress then average','average then filter/regress')
