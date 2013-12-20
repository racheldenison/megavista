% rd_checkGammaTable.m

% lumVals = ?? % actual luminance values from screen for a single channel,
% equally sampled from full 1-256 levels range
gammaVals = rgbgamma(:,2); % values from gamma table for a single channel
nLevels = 256;

% interpolate luminance values to have approximately nLevels elements
lumInterp = interp(lumVals,round(nLevels/length(lumvals)));

% use the gamma table to look up the index into the interpolated luminance
% values
for iLev = 1:nLevels
    lumLinearized(iLev) = lumInterp(round(gammaVals(iLev)*nLevels)+1); % add 1 to avoid index=0
end

% plot
figure
plot(lumLinearized)