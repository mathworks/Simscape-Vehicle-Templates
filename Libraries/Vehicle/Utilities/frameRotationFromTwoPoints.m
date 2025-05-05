function R = frameRotationFromTwoPoints(origin, targetP1, targetP2)

%frameRotationFromTwoPoints Calculates rotation matrix to orient a frame.
%
%   R = frameRotationFromTwoPoints(origin, targetP1, targetP2)
%   calculates the 3x3 rotation matrix R that orients a coordinate frame,
%   originally aligned with the global axes and located at 'origin', such
%   that its new Z-axis points from 'origin' towards 'targetP1', and its
%   new X-axis points as closely as possible towards 'targetP2' while
%   remaining orthogonal to the new Z-axis.
%
%   Inputs:
%       origin   - 3x1 vector, the origin of the frame [Ox; Oy; Oz].
%       targetP1 - 3x1 vector, the point the new Z-axis should point towards [P1x; P1y; P1z].
%       targetP2 - 3x1 vector, the point the new X-axis should point towards [P2x; P2y; P2z].
%
%   Output:
%       R        - 3x3 rotation matrix. The columns of R are the new X, Y,
%                  and Z axes expressed in the original (global) coordinate system.
%                  Applying R to a vector transforms it FROM the new local
%                  frame TO the global frame: v_global = R * v_local.
%                  Applying R' (transpose) transforms FROM global TO local:
%                  v_local = R' * v_global.
%
%   Example Usage:
%       origin = [0; 0; 0];
%       p1 = [5; 0; 0]; % Target for Z axis (along global X)
%       p2 = [0; 3; 0]; % Target for X axis direction (along global Y)
%       R = frameRotationFromTwoPoints(origin, p1, p2);
%       % Expected R (approx): [0 0 1; 1 0 0; 0 1 0] (Z->X, X->Y, Y->Z)
%
%       origin = [1; 1; 1];
%       p1 = [1; 1; 10]; % Target for Z (along global Z)
%       p2 = [5; 1; 1];  % Target for X (along global X)
%       R = frameRotationFromTwoPoints(origin, p1, p2);
%       % Expected R (approx): [1 0 0; 0 1 0; 0 0 1] (No rotation needed)

% --- Input Validation (basic) ---

%if ~isequal(size(origin), [3,1]) || ~isequal(size(targetP1), [3,1]) || ~isequal(size(targetP2), [3,1])
%    error('Inputs origin, targetP1, and targetP2 must be 3x1 column vectors.');
%end
    origin = origin(:);
    targetP1 = targetP1(:);
    targetP2 = targetP2(:);

if isequal(origin, targetP1)
    error('Origin and targetP1 cannot be the same point.');
end

if isequal(origin, targetP2)
    error('Origin and targetP2 cannot be the same point.');
end
 
% --- Calculate new Z-axis ---
z_axis = targetP1 - origin;
z_axis = z_axis / norm(z_axis); % Normalize

% --- Calculate new X-axis ---
vec_p2 = targetP2 - origin; % Vector towards the second target

% Project vec_p2 onto the plane normal to z_axis
% x_projection = vec_p2 - dot(vec_p2, z_axis) * z_axis;
% Simplified: The component *along* z_axis is dot(vec_p2, z_axis).
% The vector component is dot(vec_p2, z_axis) * z_axis.
% The component *perpendicular* to z_axis (in the desired plane) is:
x_projection = vec_p2 - (vec_p2' * z_axis) * z_axis; % Using matrix multiplication for dot product
 
% Check for collinearity (origin, P1, P2 are on the same line)
collinearity_threshold = 1e-6;
if norm(x_projection) < collinearity_threshold
    disp('Warning: Origin, targetP1, and targetP2 are nearly collinear.');
    disp('X-axis direction is ambiguous. Choosing an arbitrary X perpendicular to Z.');
    % Find *any* vector not parallel to z_axis.
    % Try global Z [0;0;1]. If z_axis is parallel to global Z, try global Y [0;1;0].

    arbitrary_vec = [0; 0; 1];

    if abs(z_axis(3)) > (1.0 - collinearity_threshold) % Check if z_axis is approx +/- [0;0;1]
        arbitrary_vec = [0; 1; 0]; % Use global Y instead
    end
 
    % Create a temporary Y-axis using cross product
    y_temp = cross(z_axis, arbitrary_vec);
    y_temp = y_temp / norm(y_temp); % Normalize
 
    % Create the final X-axis using cross product to ensure orthogonality and right-handedness
    x_axis = cross(y_temp, z_axis);

    % x_axis should already be normalized if y_temp and z_axis are normalized and orthogonal
 
else
    % Normalize the projection to get the final X-axis
    x_axis = x_projection / norm(x_projection);
end
 
% --- Calculate new Y-axis ---
% Y = Z x X for a right-handed coordinate system
y_axis = cross(z_axis, x_axis);

% Ensure normalization (should be close if inputs are normalized, but good practice)
y_axis = y_axis / norm(y_axis);
 
% --- Construct the Rotation Matrix ---
% The columns of the rotation matrix are the new basis vectors (X, Y, Z)
% expressed in the original coordinate system.

R = [x_axis, y_axis, z_axis];
 
% --- Optional: Verify Orthogonality ---
% Check if R is indeed a rotation matrix (orthogonal and det(R) = +1)

I = eye(3);
tolerance = 1e-5; % Tolerance for floating point errors
if norm(R'*R - I, 'fro') > tolerance || abs(det(R) - 1.0) > tolerance
    warning('Resulting matrix is not perfectly orthogonal or has determinant != 1. Check inputs/calculations.');
    % You might force orthogonality here if needed using SVD, e.g.,
    % [U, ~, V] = svd(R);
    % R = U * V';
    % if det(R) < 0 % Handle reflection case if necessary (unlikely here)
    %     V(:,end) = -V(:,end);
    %     R = U*V';
    % end
end
 
end
 