function [ verticesOut ] = Extr_Data_Round_Corners( vertices, vIdxs , R, nP)
%EXTR_DATA_ROUND_CORNERS Rounds the corner between the straight line sections
% vertices(iIdx-1) -> vertices(iIdx) and vertices(iIdx) -> vertices(iIdx+1).
% iIdx is an element in the indices vector vIdxs. For each corner that is 
% rounded, nP additional vertices are created. The original vertex 
% corresponding to the corner to be rounded is replaced with these nP 
% additional vertices. This increases the number of vertices by nP-1. If 
% the first vertex is specified as one of the corners to be rounded, then 
% it is assumed that the first and last vertices are connected to form a 
% polygon. The corner formed by the first and last straight line segments 
% is rounded. The same is true if the last vertex is specified as a corner 
% to be rounded. If the indices vector has repeated indices, then the
% repetitions are removed without any warning being issued.
%
% vIdxs - 1D array of vertex indices where the corner is to be rounded.
% R     - Radius of the rounded corner. This can be a scalar or a vector
%         If it is a scalar, all corners are rounded with the same radius.
%         If it is a vector it has to be the same size as vIdxs.
% nP    - Number of points on the rounded corner

% Copyright 2012-2020 The MathWorks, Inc.

vsz = size(vertices);
assert((vsz(2)==2) && (vsz(1)>=3), ...
       'The first input has to be a Nx2 matrix of 2D vertices with N >=3');
assert(isvector(vIdxs) && isnumeric(vIdxs), ...
       'The second input has to be a 1D array of indices');
assert(all(isnumeric(R)) && all(R>0), ...
            'The third input (radius) has to be a positive number');
if ~isscalar(R)
    assert(length(R)==length(vIdxs), ...
          ['The third input has to be a scalar radius value or a vector' ...
           'of radii of the same size as the number of corners to be ' ...
           'rounded']);
end
assert(isnumeric(nP) && (nP>1), ...
       ['The fourth input (number of points on arc) has to be an ' ...
        'integer greater than 1']);    
   

% Sort indices and remove repeated indices silently.
[vIdxs, iV] = unique(vIdxs);
if isscalar(R)
    R = R*ones(length(vIdxs),1);
else
   R = R(iV);
end
verticesOut = vertices;

nAdded = 0;
for idx=1:length(vIdxs)
    iIdx = vIdxs(idx);
    
    % Check inputs
    assert((iIdx>0) && (iIdx<=vsz(1)), ...
            'The index %d is not in the valid range [1,%d]',iIdx,vsz(1));
    
    vtx1 = []; vtx3 = [];
    vtx2 = vertices(iIdx,:);
    if iIdx==1
        % Need to round the edge between segments
        % V1->V2 and Vn->V1 where Vn is the last vertex
        vtx1 = vertices(end,:);
    else
        vtx1 = vertices(iIdx-1,:);
    end
    if iIdx==vsz(1)
        % Need to round the edge between segments
        % V1->V2 and Vn->V1 where Vn is the last vertex
        vtx3 = vertices(1,:);
    else
        vtx3 = vertices(iIdx+1,:);
    end

    % The corner is between the straight line segments 
    % (vtx1->vtx2) and (vtx2->vtx3)
    
    vec21 = vtx2-vtx1; n21 = norm(vec21);
    assert(n21>sqrt(eps), ...
      'Vertices are %d and %d same. Cannot round the corner.',iIdx-1,iIdx);
    vec21 = vec21/n21;
    
    vec32 = vtx3-vtx2; n32 = norm(vec32);
    assert(n32>sqrt(eps), ...
      'Vertices %d and %d are same. Cannot round the corner.',iIdx,iIdx+1);
    vec32 = vec32/n32;
    
    phi = acos(dot(vec21,vec32));
    assert(abs(phi)>sqrt(eps), ...
           ['The straight line segments are parallel. ' ...
            'Cannot round corner at vertex %d'],iIdx);
    assert(abs(phi-pi)>sqrt(eps), ...
           ['The straight line segments are anti-parallel. ' ...
            'Cannot round corner at vertex %d'],iIdx);       
    vecd = (vec32-vec21); vecd = vecd/norm(vecd);
    scale = R(idx)/cos(phi/2);

    % Center of the rounded corner
    center = vertices(iIdx,:) + vecd*scale;

    a11 = 0; a12 = 0; a21 = 0; a22 = 0; c11 = 0; c21 = 0;
    % Equation of first segment
    a11 = -vec21(2); a12 = vec21(1); 
    c11 = vtx1(2)*vec21(1) - vtx1(1)*vec21(2);
    
    % Equation of perpendicular through the center of the arc.
    m2 = -vec21(1)/vec21(2);
    if isinf(m2)
        c21 = center(1);
        a21 = 1; a22 = 0;
    else
        c21 = center(2) - m2*center(1);
        a21 = -m2; a22 = 1;
    end

    % Intersection of first segment and its perpendicular through the
    % center of the arc.
    A = [a11 a12; a21 a22]; C = [c11; c21];
    i1 = (A\C)';

    % Equation of second segment
    a11 = -vec32(2); a12 = vec32(1); 
    c11 = vtx3(2)*vec32(1) - vtx3(1)*vec32(2);
    
    % Equation of perpendicular through the center of the arc
    m2 = -vec32(1)/vec32(2);
    if isinf(m2)
        c21 = center(1);
        a21 = 1; a22 = 0;
    else
        c21 = center(2) - m2*center(1);
        a21 = -m2; a22 = 1;
    end

    % Intersection of second segment and its perpendicular through the
    % center of the arc.
    A = [a11 a12; a21 a22]; C = [c11; c21];
    i2 = (A\C)';

    n1 = i1-center; n1 = n1/norm(n1);
    n2 = i2-center; n2 = n2/norm(n2);

    ang1 = atan2(n1(2),n1(1));
    ang2 = atan2(n2(2),n2(1));
    if abs(ang1-ang2) > pi
        if ang2 < 0
            ang2 = 2*pi+ang2;
        else
            ang2 = -2*pi+ang2;
        end
    end

    theta = linspace(ang1,ang2,nP)';

    fverts = [R(idx)*cos(theta)+center(1) R(idx)*sin(theta)+center(2)];
    
    if iIdx == 1
        verticesOut = [fverts;
                       verticesOut(2:end,:)];
    elseif iIdx == vsz(1)
        verticesOut = [verticesOut(1:iIdx-1+nAdded,:);
                       fverts];
    else
        verticesOut = [verticesOut(1:iIdx-1+nAdded,:);
                       fverts;
                       verticesOut(iIdx+1+nAdded:end,:)];
    end
    nAdded = nAdded + nP -1;
end
