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
