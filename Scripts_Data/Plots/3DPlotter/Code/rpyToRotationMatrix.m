function R = rpyToRotationMatrix(roll, pitch, yaw)
% rpyToRotationMatrix Converts Roll, Pitch, Yaw Euler angles to a 3x3 rotation matrix.
% This function uses the ZYX extrinsic rotation sequence (Yaw, then Pitch, then Roll),
% which is a common automotive and aerospace convention.
% The resulting matrix R transforms a vector from the body frame to the world frame:
% v_world = R * v_body
%
% Args:
%   roll (double): Roll angle (phi, φ) in radians, rotation about the final body X-axis.
%   pitch (double): Pitch angle (theta, θ) in radians, rotation about the intermediate body Y-axis.
%   yaw (double): Yaw angle (psi, ψ) in radians, rotation about the initial body/world Z-axis.
%
% Returns:
%   R (3x3 double): The combined rotation matrix.

% --- Input Validation (Optional but good practice) ---
if nargin ~= 3
    error('Requires three input arguments: roll, pitch, and yaw (in radians).');
end
if ~isnumeric(roll) || ~isscalar(roll) || ...
   ~isnumeric(pitch) || ~isscalar(pitch) || ...
   ~isnumeric(yaw) || ~isscalar(yaw)
    error('Roll, pitch, and yaw must be scalar numeric values (in radians).');
end

% --- Pre-calculate Cosine and Sine values ---
cphi = cos(roll);   % Roll
sphi = sin(roll);
cth = cos(pitch);   % Pitch
sth = sin(pitch);
cpsi = cos(yaw);    % Yaw
spsi = sin(yaw);

% --- Combined Rotation Matrix (ZYX extrinsic sequence: Yaw, Pitch, Roll) ---
% This matrix transforms coordinates from the body frame to the world frame.
% It is equivalent to Rz(yaw) * Ry(pitch) * Rx(roll)
% Rz = [cpsi, -spsi, 0; spsi,  cpsi, 0; 0,     0,    1];
% Ry = [cth,   0,   sth;  0,    1,  0; -sth,  0,   cth];
% Rx = [1,     0,    0;   0,  cphi, -sphi; 0,  sphi,  cphi];

R = [cth*cpsi,  sphi*sth*cpsi - cphi*spsi,  cphi*sth*cpsi + sphi*spsi;
     cth*spsi,  sphi*sth*spsi + cphi*cpsi,  cphi*sth*spsi - sphi*cpsi;
    -sth,      sphi*cth,                 cphi*cth           ];

% fprintf('Rotation matrix calculated for Roll=%.4f, Pitch=%.4f, Yaw=%.4f (rad) using ZYX convention.\n', roll, pitch, yaw);

end
