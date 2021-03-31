function area = Extr_Data_Calc_Area(xy_poly)
%Extr_Data_Calc_Area Compute area of a planar polygon
%   area = Extr_Data_Calc_Area(xy_data)
%   Returns the area for a planar polygon specified by an N x 2 matrix.
%   This method will produce the wrong answer for self-intersecting
%   polygons (one side crosses over another). It will work correctly for
%   triangles, regular and irregular polygons, convex or concave polygons.
%
% Area is equal to one-half the sum of the determinants:
%
%  |   x_i       y_i   |
%  |                   |
%  | x_{i+1}   y_{i+1} |
%
% as i ranges over [1, N] and i+1 is computed in modular fashion.

% Copyright 2017-2021 The MathWorks, Inc.

area = sum(sum(xy_poly .* ([1 -1] .* circshift(xy_poly, [-1 1])))) / 2;

