function [directoryPath, directoryName] = rd_getSubjectDir(subjectDirs, scanner, subject, level)
%
% function [directoryPath, directoryName] = rd_getSubjectDir(subjectDirs, scanner, subject, level)
%
% gets the full path to the scan directory, session directory, or analysis
% directory
%
% Examples:
% level = 'scan', returns 
%   /Volumes/.../Scans/3T/RD_20120205_session
% level = 'session', returns
%   /Volumes/.../Scans/3T/RD_20120205_session/RD_20120205_n
% level = 'analysis', returns
%   /Volumes/.../Scans/3T/RD_20120205_session/RD_20120205_n/ROIAnalysis/ROIX01

if nargin < 4,
    level = 'session';
end

subjectDir{1} = subjectDirs{subject,1};
subjectDir{2} = subjectDirs{subject,2};
subjectDir{3} = subjectDirs{subject,3};

switch level
    case 'scan'
        directoryPath = sprintf('/Volumes/Plata1/LGN/Scans/%s/%s',...
            scanner, subjectDir{1});
        directoryName = subjectDir{1};
    case 'session'
        directoryPath = sprintf('/Volumes/Plata1/LGN/Scans/%s/%s/%s',...
            scanner, subjectDir{1}, subjectDir{2});
        directoryName = subjectDir{2};
    case 'analysis'
        directoryPath = sprintf('/Volumes/Plata1/LGN/Scans/%s/%s/%s/ROIAnalysis/%s',...
            scanner, subjectDir{1}, subjectDir{2}, subjectDir{3});
        directoryName = subjectDir{3};
    otherwise
        error('In rd_getSubjectDir, level not recognized.')
end
