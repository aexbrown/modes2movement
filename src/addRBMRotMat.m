function [X, Y] = addRBMRotMat(Xtil, Ytil, XCM, YCM, THETA, XCMi, YCMi, THETAi)

% ADDRBM adds predicted rigid body motion onto a series of skeletons and
% outputs the resulting velocities and positions.
% 
% Inputs
%   Xtil, Ytil - Rotated values of DX and DY.
%   XCM, YCM   - the x and y coordinates of the centre of mass position
%                used in reconstruction
%   THETA      - the angle used for reconstruction
%   XCMi, YCMi - the initial x and y coordinates of the centre of mass of
%                the skeleton to start integration.
%   THETAi     - the initial angle of the skeleton to start integration
%   istart     - the first frame used in reconstruction
%   iend       - the last frame used in reconstruction
% 
% 
% The MIT License
% 
% Copyright (c) Eric Keaveny and André Brown
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


% initialise
X = NaN(size(Xtil));
Y = NaN(size(Ytil));

for ii = 1:size(Xtil, 1)
    
    xt = XCM(ii) - XCM(1) + XCMi(1);
    yt = YCM(ii) - YCM(1) + YCMi(1);
    tht = THETA(ii) - THETA(1) + THETAi(1);
    
    XNR = Xtil(ii,:);
    YNR = Ytil(ii,:);
    
    Xtilt = cos(tht)*XNR - sin(tht)*YNR;
    Ytilt = cos(tht)*YNR + sin(tht)*XNR;
   
    X(ii, :) = Xtilt + xt;
    Y(ii, :) = Ytilt + yt;
    
end

