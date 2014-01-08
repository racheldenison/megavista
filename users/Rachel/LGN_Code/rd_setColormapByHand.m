% rd_setColormapByHand.m

%% all kinds of weird ways that colormaps can be set
colorMapName = 'somename';
VOLUME{1}.ui.mapMode=setColormap(VOLUME{1}.ui.mapMode, colorMapName); 
VOLUME{1} = refreshScreen(VOLUME{1}, 1);

VOLUME{1} = cmapRedgreenblue(VOLUME{1}, 'ph', 1); 
VOLUME{1} = refreshScreen(VOLUME{1});

VOLUME{1}=cmapImportModeInformation(VOLUME{1}, 'phMode', 'WedgeMapLeft_pRF.mat');
VOLUME{1}=refreshScreen(VOLUME{1}, 1);

%% set prf colormap in parameter map mode
fname = 'WedgeMapLeft_pRF';
modeName = 'mapMode';
clipMode = [0 360];

load(fname,'modeInformation','displayType');
modeInformation.clipMode = clipMode;
VOLUME{1} = viewSet(VOLUME{1},modeName,modeInformation);
VOLUME{1} = refreshScreen(VOLUME{1});
