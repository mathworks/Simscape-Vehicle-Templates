function perimeter = Extr_Data_Calc_Perimeter(xy_poly)
%Extr_Data_Calc_Perimeter Compute perimeter of a planar polygon
%   perimeter = Extr_Data_Calc_Perimeter(xy_poly)
%   Returns the perimeter for a planar polygon specified by an N x 2 matrix.

% Copyright 2017-2022 The MathWorks, Inc.

seg_vectors = circshift(xy_poly, -1) - xy_poly; % Vectors along each polygon segment
perimeter = sum(sqrt(sum(seg_vectors .* seg_vectors, 2)));  % Sum of segment lengths


