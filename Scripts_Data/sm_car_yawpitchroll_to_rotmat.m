function rotmat_ypr = sm_car_yawpitchroll_to_rotmat(yaw,pitch,roll)
%sm_car_yawpitchroll_to_rotmat  Calculate rotation matrix to transform
%velocity in vehicle frame to velocity in world frame
%
%   The initial velocity of the vehicle in the model is specified via a
%   6-DOF joint connected to the world frame. Most often, the initial
%   velocity of the vehicle will convenient to define in the vehicle frame.
%   This function calculates the rotation matrix from the vehicle frame to
%   the world frame.
%   
%   It takes as arguments
%       yaw   - about vehicle z-axis
%       pitch - about vehicle y-axis
%       roll  - about vehicle x-axis
%
%   This calculation assumes that the rotation order is yaw, pitch, then
%   roll, and assumes intrinsic rotations, where the elemental rotations
%   are performed on the coordinate system as rotated by the previous
%   operation.
%
% Copyright 2018-2025 The MathWorks, Inc.

Rx = [1    0           0;
      0 cos(roll) -sin(roll);
      0 sin(roll)  cos(roll)];

Ry = [cos(pitch)    0   sin(pitch);
           0        1       0;
      -sin(pitch)    0   cos(pitch)];

Rz = [cos(yaw)  -sin(yaw)   0;
      sin(yaw)   cos(yaw)   0;
         0          0       1];
     
rotmat_ypr = Rz*Ry*Rx;