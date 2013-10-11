% rd_adjustInplaneForMNITest.m
%
% testing MNI space data

% first initialize new mrSESSION using gems, refvol (for epi), and
% anatomical from that subject. makes a minimal mrSESSION.

load mrSESSION
load anat

inplaneSize = [size(anat,1) size(anat,2)];

mrSESSION.inplanes.fullSize = inplaneSize;
mrSESSION.inplanes.voxelSize = [1.5 1.5 1.5];
mrSESSION.inplanes.nSlices = size(anat,3);
mrSESSION.inplanes.crop = [1 1; inplaneSize];
mrSESSION.inplanes.cropSize = inplaneSize;

save mrSESSION.mat mrSESSION dataTYPES

% finally, switch in the MNI anat (can rename the original anat
% anat_orig.mat)