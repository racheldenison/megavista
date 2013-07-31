function clim = rd_zeroCenterCLim(x)
%
% clim = rd_zeroCenterCLim(x)

M=abs(max(x(:)));
m=abs(min(x(:)));
if M-m>=0      
   clim=[-M M];
   else
   clim=[-m m];
end