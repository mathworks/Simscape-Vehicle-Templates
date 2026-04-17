function [Camera] = sm_car_define_camera(camera_param)
% Function to create data structure with camera_param for animation cameras
% 
% Frame parameters are used to calculate transform information for all
% frames defined in the Camera Frames subsystem.
%
% Copyright 2021-2026 The MathWorks, Inc.

% Offset from vehicle reference to camera reference
Camera.Offset.s.Value = camera_param.veh_to_cam;
Camera.Offset.s.Units = 'm';
Camera.Offset.s.Comments = 'Vehicle Frame to Camera Reference Frame';
Camera.Offset.a.Value = [0 0 0];
Camera.Offset.a.Units = 'deg';
Camera.Offset.a.Comments = 'Z-Y-X (Yaw, Pitch, Roll)';

% Parameters for "circle of drones"
% Diagonal cameras
Camera.FL    = frameData(camera_param.xyz_d);            % Front Left
Camera.FR    = frameData(camera_param.xyz_d.*[ 1 -1 1]); % Front Right
Camera.RL    = frameData(camera_param.xyz_d.*[-1  1 1]); % Rear Left
Camera.RR    = frameData(camera_param.xyz_d.*[-1 -1 1]); % Rear Right

% Side cameras
Camera.Front = frameData(camera_param.xyz_f);            % Front
Camera.Right = frameData(camera_param.xyz_l.*[1 -1 1]);  % Right
Camera.Rear  = frameData(camera_param.xyz_r);            % Rear
Camera.Left  = frameData(camera_param.xyz_l);            % Left

% Birds-eye camera
Camera.Top   = frameData(camera_param.xyz_t);            % Top
Camera.Top.a.Value(3) = 90; % Orient frame so forward is screen right edge

% Wheel Cameras
Camera.Wheel_FL  = frameData(camera_param.whl_fl);           % FL
Camera.Wheel_FL.a.Value = [0 0 -90];  % Point camera right at wheel
Camera.Wheel_FR  = frameData(camera_param.whl_fl.*[1 -1 1]); % FR
Camera.Wheel_FR.a.Value = [0 0 90];   % Point camera right at wheel

Camera.Wheel_RL  = frameData(camera_param.whl_rl);           % RL
Camera.Wheel_RL.a.Value = [0 0 -90];  % Point camera right at wheel
Camera.Wheel_RR  = frameData(camera_param.whl_rl.*[1 -1 1]); % RR
Camera.Wheel_RR.a.Value = [0 0 90];   % Point camera right at wheel

% Suspension Cameras (Axles)
Camera.SuspF  = frameData(camera_param.susp_f); % Front Suspension
Camera.SuspF.a.Value = [0 0 180];     % Point camera at suspension
Camera.SuspR  = frameData(camera_param.susp_r); % Rear Suspension
Camera.SuspR.a.Value = [0 0 0];       % Point camera at suspension

% Suspension Cameras (Corners)
Camera.View_SuspFL  = frameData(camera_param.susp_fl);           % Front Left
Camera.View_SuspFL.a.Value = [0 0 0];    % Point camera forward
Camera.View_SuspFR  = frameData(camera_param.susp_fl.*[1 -1 1]); % Front Right
Camera.View_SuspFR.a.Value = [0 0 0];    % Point camera forward
Camera.View_SuspRL  = frameData(camera_param.susp_rl);           % Rear Left
Camera.View_SuspRL.a.Value = [0 0 -180]; % Point camera rearward
Camera.View_SuspRR  = frameData(camera_param.susp_rl.*[1 -1 1]); % Rear Right
Camera.View_SuspRR.a.Value = [0 0 -180]; % Point camera rearward

% View from Seats
Camera.View_SeatFL  = frameData(camera_param.seat_fl);           % Front Left
Camera.View_SeatFL.a.Value = [0 0 0];    % Point camera forward
Camera.View_SeatFR  = frameData(camera_param.seat_fl.*[1 -1 1]); % Front Right
Camera.View_SeatFR.a.Value = [0 0 0];    % Point camera forward

% Dolly Camera - camera position specified in time
Camera.Dolly_Cam  = frameData(camera_param.dolly.s);   % Camera location offset
Camera.Dolly_Cam.a.Value = camera_param.dolly.a;       % Camera orientation

% Camera location trajectory specified in time
Camera.Dolly_Cam.tvec.Value = camera_param.dolly.tvec; 
Camera.Dolly_Cam.tvec.Units = 'sec';
Camera.Dolly_Cam.xvec.Value = camera_param.dolly.xvec;
Camera.Dolly_Cam.xvec.Units = 'm';
Camera.Dolly_Cam.yvec.Value = camera_param.dolly.yvec;
Camera.Dolly_Cam.yvec.Units = 'm';
Camera.Dolly_Cam.zvec.Value = camera_param.dolly.zvec;
Camera.Dolly_Cam.zvec.Units = 'm';


function camTransform = frameData(pos)
%% Code to define frames and orientations

% Formulas assume input argument pos
% 1. is camera location relative to position where camera will aim
% 2. Aim is along x-axis of camera frame
% 3. Up Vector is z-axis of camera frame 
% 4. Orientation of camera frame is intrinsic rotation of yaw-pitch-roll
%    where yaw is about z axis, pitch is about y axis, and z is about x axis

% Translation of frame
camTransform.s.Value    = pos;
camTransform.s.Units    = 'm';
camTransform.s.Comments = 'Relative to camera reference';

% Orientation of frame
camTransform.a.Value = [...
    0, 
    atan2d(pos(3),sqrt((pos(1)^2)+(pos(2))^2)), 
    atan2d(-pos(2),-pos(1))]';

camTransform.a.Units    = 'deg';
camTransform.a.Comments = 'Z-Y-X (Yaw, Pitch, Roll)';


