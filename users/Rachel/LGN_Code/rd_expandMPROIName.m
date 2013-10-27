function newName = rd_expandMPROIName(name)

switch name
    case 'lgnROI1_M'
        newName = 'lgnROI1_betaM-P_prop20_varThresh000_groupM';
    case 'lgnROI2_M'
        newName = 'lgnROI2_betaM-P_prop20_varThresh000_groupM';
    case 'lgnROI1_P'
        newName = 'lgnROI1_betaM-P_prop20_varThresh000_groupP';
    case 'lgnROI2_P'
        newName = 'lgnROI2_betaM-P_prop20_varThresh000_groupP';
    otherwise
        newName = name;
end