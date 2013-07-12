function ROI = rd_mrNewROI(viewType, name, coords, color)

% function ROI = rd_mrNewROI(viewType, name, coords, color)

if notDefined('viewType'), viewType = [];  end
if notDefined('name'),         name = [];  end
if notDefined('coords'),     coords = [];  end
if notDefined('color'),       color = 'b'; end

ROI.name = name;
ROI.viewType = viewType;
ROI.coords = coords;
ROI.color = color;
ROI.created = datestr(now);
ROI.modified = datestr(now);
ROI.comments = [];
ROI.lineHandles = [];
