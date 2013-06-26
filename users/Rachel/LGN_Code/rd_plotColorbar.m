function cmap0 = rd_plotColorbar(colormapName)


cmap0 = colormap('jet');
nCMappings = size(cmap0,1);

switch colormapName
    case 'whitered'
        whitered = zeros(size(cmap0));
        whitered(:,1) = 1;
        whitered(:,2) = 1:-1/(nCMappings-1):0;
        whitered(:,3) = 1:-1/(nCMappings-1):0;
        cmap0 = whitered;
    case 'whiteblue'
        whiteblue = zeros(size(cmap0));
        whiteblue(:,3) = 1;
        whiteblue(:,1) = 1:-1/(nCMappings-1):0;
        whiteblue(:,2) = 1:-1/(nCMappings-1):0;
        cmap0 = whiteblue;
    case 'lbmap'
        cmap0 = colormap(flipud(lbmap(nCMappings,'redblue')));
end

figure('Color','w','Colormap',cmap0)
colorbar('YTick',[])
axis off