% rd_fslPrepareForFeat.m

ipat = 3;
fprintf('\nipat = %d\n\n', ipat) 
ok = input('Ok? (n to quit) ', 's');
if strcmp(ok,'n')
    error('quitting ... check ipat')
end

%% go to epi dicom directory
% get first dicom
alldicoms = dir('*.dcm');
dicompath = alldicoms(1).name;

% make slice timings file
rd_fslMakeSliceTimingsFile

% get effective echo spacing from epi
esEff = rd_echoSpacingFromDicom(dicompath, ipat);
fprintf('\nEpi effective echo spacing = %1.3f ms\n\n', esEff*1000)

% find epi TE
epi = dicominfo(dicompath);
TE = epi.EchoTime;
fprintf('\nEpi TE = %d ms\n\n', TE)

%% go to field mapping MR dicom directory
% get first dicom of each image
mrdicoms = dir('*.dcm');
mr1path = mrdicoms(1).name;

mr2dicoms = dir('*EC2*.dcm');
mr2path = mr2dicoms(1).name;

mr1 = dicominfo(mr1path);
mr2 = dicominfo(mr2path);

fieldmapDeltaTE = mr2.EchoTime - mr1.EchoTime;
fprintf('\nFieldmap deltaTE = %1.3f ms\n\n', fieldmapDeltaTE)