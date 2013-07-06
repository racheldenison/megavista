
% testing a bandpass filter for [.009 .08] Hz

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


%% build the filter
freqrange = [.009 .08];
fs = 0.5;

[z,p,k] = butter(10,freqrange/(fs/2),'bandpass');
[sos,g] = zp2sos(z,p,k);
Hd = dfilt.df2sos(sos,g);

b = fir1(50,freqrange/(fs/2));

% % Display the filter response
% h = fvtool(Hd)
% set(h,'Analysis','freq')

%% test the filter
y1 = filter(Hd,x);
y2 = filtfilt(sos,g,x);
y3 = filtfilt(b,1,x);
% y4 = rd_bandpass(x,freqrange,fs); % same as FIR filtfilt

figure
hold on
plot(t,y1)
plot(t,y2,'g')
plot(t,y3,'r')
plot(t,x1,'k')
xlabel('time (s)')
legend('butter/filter','butter/filtfilt','fir/filtfilt','orig')

figure
plot(x1,y3,'.')