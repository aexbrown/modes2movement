function [Xp, Yp] = body2lab(X, Y, THETA)

% BODY2LAB rotates vectors from the worm-oriented frame of reference to the
% lab frame of reference.
% 
% Inputs
%   X,Y   - the x and y components of the vectors to be rotated. Size is
%           number of frames by number of worm skeleton coordinates.
%   THETA - Vector of rotation angles with length equal to number of
%           frames.
% 
% Outputs
%   Xp, Yp - Rotated versions of X and Y.
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
Xp = zeros(size(X));
Yp = zeros(size(X));

for ii=1:size(X, 1)
    Xp(ii,:) = cos(THETA(ii))*X(ii,:) - sin(THETA(ii))*Y(ii,:);
    Yp(ii,:) = cos(THETA(ii))*Y(ii,:) + sin(THETA(ii))*X(ii,:);
end