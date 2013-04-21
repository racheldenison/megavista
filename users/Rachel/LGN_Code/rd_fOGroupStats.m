% rd_fOGroupStats.m

load fOverallMeans_3T_7T_N4_N7_20130406

% using delay = 1 TR for paper

f3 = [fOMeans31; fOMeans32];
f7 = [fOMeans71; fOMeans72];

f3Mean = mean(f3);
f7Mean = mean(f7);

f3Ste = std(f3)./sqrt(size(f3,1));
f7Ste = std(f7)./sqrt(size(f7,1));

f7Mean./f3Mean