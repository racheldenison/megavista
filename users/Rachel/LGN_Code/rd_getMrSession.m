function [mrSESSION dataTYPES vANATOMY] = rd_getMrSession(subjectDirs, scanner, subject)
%
% function [mrSESSION dataTYPES vANATOMY] = rd_getMrSession(subjectDirs, scanner, subject)
%
% gets the mrSESSION for any subject. can also optionally return dataTYPES
% and vANATOMY

subjectDir{1} = subjectDirs{subject,1};
subjectDir{2} = subjectDirs{subject,2};
subjectDir{3} = subjectDirs{subject,3};

fileDirectory = sprintf('/Volumes/Plata1/LGN/Scans/%s/%s/%s',...
    scanner, subjectDir{1}, subjectDir{2});

load(sprintf('%s/mrSESSION.mat', fileDirectory))

if ~exist('vANATOMY', 'var') && nargout==3
    vANATOMY = [];
    fprintf('Could not find vANATOMY in mrSESSION.mat\n')
end