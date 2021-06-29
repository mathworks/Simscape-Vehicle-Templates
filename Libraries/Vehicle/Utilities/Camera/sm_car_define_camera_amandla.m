function Camera =  sm_car_define_camera_amandla
% Function to specify parameters for animation cameras
%
% Adjust frame locations below
%
% Copyright 2021 The MathWorks, Inc.

% Offset from vehicle reference to camera reference
%   Vehicle Reference: Frame where camera frame subsystem is attached
%   Camera Reference:  Frame camera will point at
camera_name = 'Amandla';
camera_param.veh_to_cam = [-6.482/2      0   0.0];

% Camera positions relative to camera reference
% Circle of cameras
camera_param.xyz_f      = [  12      0        3.5];   % Front
camera_param.xyz_l      = [   0      10       2.25];  % Left  (right)
camera_param.xyz_r      = [ -25      0        5.5];   % Rear
camera_param.xyz_d      = [   8.00   6.25     5.5];   % Front Left (diagonal)
camera_param.xyz_t      = [-eps      0       10];     % Top

% Viewing Suspension and Seats
camera_param.whl_fl     = [   6.482/2 4       0.6731];  % Wheel Front Left (right)
camera_param.whl_rl     = [  -6.482/2 4       0.6731];  % Wheel Rear Left  (right)
camera_param.susp_f     = [   7.00    0       0.6731];  % Suspension Front
camera_param.susp_r     = [  -7.00    0       0.6731];  % Suspension Rear
camera_param.susp_fl    = [   2.50    0.5     0.6731];  % Suspension Front Left (right) 
camera_param.susp_rl    = [  -2.50    0.5     0.6731];  % Suspension Rear Left  (right) 
camera_param.seat_fl    = [   2.00    0.558   3.00];  % Seat Front Left       (right) 

% Dolly Camera
camera_param.dolly.s    = [   7.00   -5.00    2.00];  % Camera offset
camera_param.dolly.a    = [   0      15.00  155];     % View angle orientation
camera_param.dolly.tvec = [0   1   2    3    4    5    7   10    20]; % Time
camera_param.dolly.xvec = [5   6.1 8.6 12.5 17.7 24.5 44.1 79.9 199]; % Trajectory x
camera_param.dolly.yvec = [0   0   0    0    0    0    0    0     0]; % Trajectory y
camera_param.dolly.zvec = [0   0   0    0    0    0    0    0     0]; % Trajectory z

% Obtain Camera structure
Camera = sm_car_define_camera(camera_param);
Camera.Instance = camera_name;
