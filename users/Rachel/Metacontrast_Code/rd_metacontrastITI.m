% rd_metacontrastITI.m


cueTimes =  expt.timing.t.cueOnsetTimes - expt.timing.t.timeStart;

nullTrials = isnan(expt.trials(:,strcmp(expt.trials_headers,'SOA')));
nnz(nullTrials)

realCueTimes = cueTimes(nullTrials==0);

trialISIs = diff(realCueTimes);

figure
plot(trialISIs,'.')

figure
hist(trialISIs)






% comparing the optseq cue times
% set opt = first 2 columns of optseq file
optCueTimes = opt(opt(:,2)>0,1);
figure
plot(diff(optCueTimes),'.')
figure
scatter(optCueTimes,realCueTimes)
