% rd_testMetacontrastMVPA.m

data = load('data_SOACode1.dat');
class = load('dataClass_SOACode1.dat');

nRuns = 10;
subjectID = 'fakedata'; soaCode = 1; thresh = 1;

%% negative control: random data
% run rd_metacontrastMVPA each time
data = randn(size(data));
allperf(:,1) = perf;
data = randn(size(data));
allperf(:,2) = perf;
data = randn(size(data));
allperf(:,3) = perf;
data = randn(size(data));
allperf(:,4) = perf;
data = randn(size(data));
allperf(:,5) = perf;
data = randn(size(data));
allperf(:,6) = perf;
data = randn(size(data));
allperf(:,7) = perf;

figure
hold on
plot([0 8],[.5 .5],'--k')
errorbar(mean(allperf),std(allperf),'g')
errorbar(mean(allperf),std(allperf)./sqrt(10))
title('decoding on fake (random) data')

%% positive control: separable data
data1 = randn(nnz(class==0), size(data,2));
data2 = randn(nnz(class==1), size(data,2)) + 2;
data(class==0,:) = data1;
data(class==1,:) = data2;
% now run rd_metacontrastMVPA