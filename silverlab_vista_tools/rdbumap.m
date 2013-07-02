function map = rdbumap(n)
%RDBUMAP Returns an Nx3 colormap
%   If N is not specified, the size of the colormap is determined by the
%   current figure. If no figure exists, MATLAB creates one.
%
% Based on lbmap.m
%
% Reference:
% A. Light & P.J. Bartlein, "The End of the Rainbow? Color Schemes for
% Improved Data Graphics," Eos,Vol. 85, No. 40, 5 October 2004.
% http://geography.uoregon.edu/datagraphics/EOS/Light&Bartlein_EOS2004.pdf

%defensive programming
error(nargchk(0,1,nargin))
error(nargoutchk(0,1,nargout))

%defaults
if nargin<1
  n = size(get(gcf,'colormap'),1);
end

baseMap = RdBuMap;

idx1 = linspace(0,1,size(baseMap,1));
idx2 = linspace(0,1,n);
map = interp1(idx1,baseMap,idx2);
         
function baseMap = RdBuMap
baseMap = [0.0196    0.1882    0.3804;
            0.1294    0.4000    0.6745;
            0.2627    0.5765    0.7647;
            0.5725    0.7725    0.8706;
            0.8196    0.8980    0.9412;
            0.9686    0.9686    0.9686;
            0.9922    0.8588    0.7804;
            0.9569    0.6471    0.5098;
            0.8392    0.3765    0.3020;
            0.6980    0.0941    0.1686;
            0.4039         0    0.1216];
