function [XCM, YCM, THETA] = integrateRBM(RBM, dt, THETAr)

% INTEGRATERBM Integrate the velocity and angular velocity to get the
% translation and rotation of the centre of mass.
% 
% Inputs
%   RBM   - a matrix of rigid body motion. RBM(:,1:2) are x and y
%           components of translational velocity. RBM(:, 3) is the
%           angular velocity.  (number of frames - 1) x 3 matrix.
%  dt     - the time between frames
% 
% Outputs
%   XCM, YCM - the x and y coordinates of the centre of mass of the
%              skeleton.  Vectors with length of frame number.
%   THETA    - Rotation angle used to obtain X and Y from Xtil and Ytil
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


Nt = size(RBM,1)+1;
XCM = zeros(Nt,1);
YCM = zeros(Nt,1);
THETA = zeros(Nt,1);

for ii = 2:Nt
    THETA(ii) = THETA(ii-1) + RBM(ii-1,3)*dt;
end

THETA = THETA - THETA(1) + THETAr(1);

% ROTATE VELOCITIES INTO LAB FRAME
 [RBM(:,1), RBM(:,2)] = body2lab(RBM(:,1), RBM(:,2), THETA);
    
 
for ii = 2:Nt    
    XCM(ii) = XCM(ii-1) + RBM(ii-1,1)*dt;
    YCM(ii) = YCM(ii-1) + RBM(ii-1,2)*dt;  
end

