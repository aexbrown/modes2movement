% This script loads a worm features file that includes the xy coordinates
% of a tracked worm's midline or skeleton.  These skeletons are projected
% onto eigenworms (a reduced dimensionality representation of worm shape).
% The reduced dimensionality data is then used to reconstruct skeletons in
% xy-coordinates (but now without the original translation and rotation).
% The translation and rotation is then *predicted* using linear resistive
% force theory.
% 
% 
% The MIT License
% 
% Copyright (c) Andr� Brown
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

% -------------------------------------------------------------------------
% Reproject onto eigenworms correcting for worm side
% -------------------------------------------------------------------------

% load a features file
load('short_worm_features.mat')

% load the eigenworms
load('/Users/abrown/Andre/code/Motif_Analysis/eigenWorms.mat')

% get the tangent angles from the skeleton xy-coordinates
[angleArray, meanAngles] = makeAngleArrayV(worm.posture.skeleton.x', ...
    worm.posture.skeleton.y');

% if worm is on left side, flip it.  This ensures that ventral turns will
% have curvatures with the same sign whether the worm is on its left or
% right side.
if strcmp(info.experiment.worm.agarSide, 'left')
    angleArray = angleArray * -1;
end

% get the projected amplitudes
numEigWorms = 6;
eigenAmps = eigenWormProject(eigenWorms, angleArray, numEigWorms)';

% drop leading and trailing NaN values (don't want to extrapolate to
% extreme values)
if isnan(eigenAmps(1, 1))
    % get the end of the starting NaN segment
    nanEnd = find(~isnan(eigenAmps(1, :)), 1, 'first') - 1;
    
    % drop these values
    eigenAmps(:, 1:nanEnd) = [];
end

% is the last point NaN?
if isnan(eigenAmps(1, end))
    % get the start of the final NaN segment
    nanStart = find(~isnan(eigenAmps(1, :)), 1, 'last') + 1;
    
    % drop these values
    eigenAmps(:, nanStart:end) = [];
end

% linearly interpolate over missing values
eigenAmpsNoNaN = eigenAmps;
for ii = 1:size(eigenAmps, 1)
    pAmp = eigenAmps(ii, :);
    pAmp(isnan(pAmp)) = interp1(find(~isnan(pAmp)),...
        pAmp(~isnan(pAmp)), find(isnan(pAmp)), 'linear');
    eigenAmpsNoNaN(ii, :) = pAmp;
end


% -------------------------------------------------------------------------
% Convert projected amplitudes back to xy-coordinates and plot
% -------------------------------------------------------------------------

% convert to tangent angle array
angleArray = reconstructAngles(eigenAmpsNoNaN, eigenWorms, size(eigenAmps, 1));

% convert angle array to skeleton xy coordinates
[X, Y] = angle2skel(angleArray, zeros(size(eigenAmpsNoNaN, 2), 1), 1);

% display a movie of the worm over time
for ii = 1:size(eigenAmpsNoNaN, 2)
    plot(X(:, ii), Y(:, ii), 'LineWidth', 3)
    axis equal
    pause(0) % forces refresh so you can see the plot
end



% -------------------------------------------------------------------------
% Use friction model to predict worm path from reconstructed skeletons
% -------------------------------------------------------------------------

X = X';
Y = Y';

% calculate arclength increment
ds = 1/(size(X, 2)-1);

% calculate the observed rigid body motion
[XCM, YCM, UX, UY, UXCM, UYCM, TX, TY, NX, NY, I, OMEG] = ...
    getRBM(X, Y, 1, ds, 1);

% subtract the observed rigid body motion
[DX, DY, ODX, ODY, VX, VY, Xtil, Ytil, THETA] = ...
    subtractRBM(X, Y, XCM, YCM, UX, UY, UXCM, UYCM, OMEG, 1);

% rotate velocites and tangent angles to the worm frame of reference
[TX, TY] = lab2body(TX, TY, THETA);
[VX, VY] = lab2body(VX, VY, THETA);

% use model to predict rigid body motion
alpha = 100; % large alpha corresponds to no-slip during crawling
RBM = posture2RBM(TX, TY, Xtil, Ytil, VX, VY, 1, I, ds, alpha);

% calculate the predicted rigid body motion
[XCMrecon, YCMrecon, THETArecon] = integrateRBM(RBM, 1, THETA);

% add the rigid body motion to the skeleton coordinates
[Xrecon, Yrecon] = addRBMRotMat(Xtil, Ytil, XCMrecon, YCMrecon, ...
    THETArecon, XCM, YCM, THETA);

% plot a movie of worm with motion back in
for ii = 1:10:size(Xrecon,1) % only plotting every 10 frames to speed up movie
    plot(Xrecon(ii, :), Yrecon(ii, :), 'Color', 'r')
    hold on
    plot(Xrecon(ii,1), Yrecon(ii, 1), '.', 'Color', 'b', 'MarkerSize', 15)
    axis equal
    xlim([ min(min(Xrecon - Xrecon(1, 1))), max(max(Xrecon - Xrecon(1, 1)))])
    ylim([ min(min(Yrecon - Yrecon(1, 1))), max(max(Yrecon - Yrecon(1, 1)))])

    hold off
    pause(0) % forces refresh so you can see the plot
end
