% rd_mrAdjustInplane_AV20111213_gemsobl.m

% replaced anat.mat with gems_obl.nii.gz

load mrSESSION.mat

correctInplaneDim = [256 256];
correctRes = [1 1 1.5]; % AV_gemsobl [1 1 1.5] % MN [1.2 1.2 1.2] % JN, SB, RD [1.3 1.3 1.3]

mrSESSION.inplanes.voxelSize = correctRes;
mrSESSION.inplanes.fullSize = correctInplaneDim;
mrSESSION.inplanes.crop(2,:) = correctInplaneDim;
mrSESSION.inplanes.cropSize = correctInplaneDim;

% % this part is used to correct voxel size in reconstructed MN scans
% for iFunc = 1:length(mrSESSION.functionals)
%     mrSESSION.functionals(iFunc).voxelSize = correctRes;
%     mrSESSION.functionals(iFunc).effectiveResolution = correctRes;
% end

save mrSESSION.mat mrSESSION dataTYPES