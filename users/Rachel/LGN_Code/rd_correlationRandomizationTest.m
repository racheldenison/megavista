% rd_correlationRandomizationTest.m


%% setup
s1 = map1ROIVals;
s2 = map2ROIVals;
n = length(s1);


%% 6. Test hypothesis
%
% Now we want to test the hypothesis that the correlation r, was not
% obtained by chance. We want to find the probability for the null
% hypothesis to be true.
%
% If the null hypothesis were true, we would be able to shuffle the
% order of each variable and obtain datasets that are equivalent to the
% original dataset. So, to obtain a p-value, we shuffle each variable,
% calculate a correlation value for each shuffled sample. We repeat this
% process a large number of times and count the number of times that
% randomly obtained correlation values are more extreme than the actual
% observed correlation value.

% We build a bootstrap distribution of samples under the null hypothess
% that s1 and s2 were not correlated.
k = 10000; % number of randomizations
r_dist = zeros(k,1);
s1_rnd = zeros(size(s1)); s2_rnd = s1_rnd;
for ii = 1:k
 % Notice the difference here. We resample s1 and s2 indepedently. This is
 % because uner the null hypothesis the two ampels have no correlation.
 s1_rnd = randsample(s1,n,1);
 s2_rnd = randsample(s2,n,1);
 r_dist(ii)    = sum((s1_rnd - mean(s1_rnd))/std(s1_rnd,1) .* ...
                     (s2_rnd - mean(s2_rnd)/std(s2_rnd,1)))/n;
end

% We show the distribution of correlations obtaned by chance given the two
% samples.
figure;
[nn,xx] = hist(r_dist,100);
bar(xx,nn/sum(nn))
title('Distribution of correlations between s1 and s2')
ylabel('Probability of occurrence')
xlabel('Pearson correlation coefficient')
hold on
y = get(gca,'yLim');

% Next we can show the empirical correlation (r). The height of the
% distribution at the value of d_empirical is the probability that that
% difference comes from samples drawn from the same distribution.
plot([r,r],y*.99,'r-','lineWidth',2)

% We can obtain the probability of H0 being true by counting the number of
% randomly obtained correlation coefficient values that are larger than the
% actual observed value and divide this by the total number of simulations
% that were run. Because value can be larger or smaller than the mean we
% coupute the absolute value of the ditribution and r values.
p = sum(abs(r) < abs(r_dist))/k;
text(0,y(2)*.95,sprintf('H0 is true with %2.2f probability.',p))

fprintf('Randomization p-value = %f\n', p)