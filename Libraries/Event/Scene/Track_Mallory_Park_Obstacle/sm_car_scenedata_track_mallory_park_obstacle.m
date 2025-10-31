function scene_data = sm_car_scenedata_track_mallory_park_obstacle
%% Floor and Grid parameters
% Copyright 2018-2025 The MathWorks, Inc.

scene_data.Name = 'Mallory_Park_Obstacle';
scene_data.Track.w   = 10;          % m
scene_data.Track.h   = 0.1;         % m
scene_data.Track.clr = [1 1 1]*0.8; % [R G B]
scene_data.Track.opc = 1;           % (0-1)
scene_data.Track.x   = 0;           % m
scene_data.Track.y   = 0;           % m
scene_data.Track.z   = 0;           % m
scene_data.Track.yaw = 0;           % rad

scene_data.Traffic_Light_1.x        = 0;           % m
scene_data.Traffic_Light_1.y        = -259;         % m
scene_data.Traffic_Light_1.z        = 2;           % m
scene_data.Traffic_Light_1.yaw      = pi*0.885;      % rad
scene_data.Traffic_Light_1.pole_h   = 2;           % rad
scene_data.Traffic_Light_1.clr      = [0.5 0.5 0.5];           % rad
scene_data.Traffic_Light_1.lamp.t   = [0 1 2 3 4 5 6 7 8 9 10 11 12]*4;% sec
scene_data.Traffic_Light_1.lamp.RYG = [3 3 3 3 3 3 3 2 2 1 1  1  1];

scene_data.Traffic_Light_2.x        = -160;           % m
scene_data.Traffic_Light_2.y        = -214;         % m
scene_data.Traffic_Light_2.z        = 2;           % m
scene_data.Traffic_Light_2.yaw      = pi*0.885;      % rad
scene_data.Traffic_Light_2.pole_h   = 2;           % rad
scene_data.Traffic_Light_2.clr      = [0.5 0.5 0.5];           % rad
scene_data.Traffic_Light_2.lamp.t   = [0 1 2 3 4 5 6 7 8 9 10 11 12]*4;% sec
scene_data.Traffic_Light_2.lamp.RYG = [3 3 3 2 2 1 1 1 1 3 3 3 3];

scene_data.Override.vx.TL1.d_start  = 725;
scene_data.Override.vx.TL1.d_end    = 810;
scene_data.Override.vx.TL1.t_to_min = 2;
scene_data.Override.vx.TL1.t_to_max = 2;
scene_data.Override.vx.TL1.d_end    = 810;
scene_data.Override.vx.TL2.d_start  = 865;
scene_data.Override.vx.TL2.d_end    = 950;
scene_data.Override.vx.TL2.t_to_min = 2;
scene_data.Override.vx.TL2.t_to_max = 2;




% Load data
ctrdata=load('Mallory_Park_ctrline');
fieldname = fieldnames(ctrdata);
scene_data.Track.ctrline = ctrdata.(fieldname{1}); % [x y z] (m) 

