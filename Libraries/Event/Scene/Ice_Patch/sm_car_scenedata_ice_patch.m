function scene_data = sm_car_scenedata_ice_patch
%% Floor and Grid parameters
% Copyright 2018-2022 The MathWorks, Inc.

scene_data.Name = 'Ice_Patch';
scene_data.Plane.l = 400;           % m
scene_data.Plane.w = 400;           % m
scene_data.Plane.h = 0.01;          % m
scene_data.Plane.clr = [1 1 1]*0.8; % [R G B]
scene_data.Plane.opc = 1;           % (0-1)

scene_data.Grid.h = 0.02;           % m
scene_data.Grid.num_sqrs_x = 40;    % m
scene_data.Grid.num_sqrs_y = 40;    % m
scene_data.Grid.line_width = 0.08;  % m
scene_data.Grid.clr = [1 1 1];      % [R G B]
scene_data.Grid.opc = 1;            % (0-1)

scene_data.Ice.x_min = 100-40;             % m
scene_data.Ice.x_max = 130-40;
%scene_data.Ice.x_ctr = (scene_data.Ice.x_max+scene_data.Ice.x_min)/2;
scene_data.Ice.y_min = -30;             % m
scene_data.Ice.y_max = 0;
%scene_data.Ice.y_ctr = (scene_data.Ice.y_max+scene_data.Ice.y_min)/2;
scene_data.Ice.z = 0.005;               % m
%scene_data.Ice.l = scene_data.Ice.x_max-scene_data.Ice.x_min;              % m
%scene_data.Ice.w = scene_data.Ice.y_max-scene_data.Ice.y_min;              % m
scene_data.Ice.h = 0.011;           % m
scene_data.Ice.clr = [0.8 1.0 1.0]; % [R G B]
scene_data.Ice.opc = 1;             % (0-1)
