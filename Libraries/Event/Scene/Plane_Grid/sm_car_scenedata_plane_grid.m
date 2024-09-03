function scene_data = sm_car_scenedata_plane_grid
%% Floor and Grid parameters
% Copyright 2018-2024 The MathWorks, Inc.

scene_data.Name = 'Plane_Grid';
scene_data.Plane.l = 400;           % m
scene_data.Plane.w = 400;           % m
scene_data.Plane.h = 0.01;          % m
scene_data.Plane.x = 200;           % m
scene_data.Plane.y = 0;             % m
scene_data.Plane.z = 0;             % m
scene_data.Plane.clr = [1 1 1]*0.8; % [R G B]
scene_data.Plane.opc = 1;           % (0-1)
scene_data.Grid.h = 0.02;           % m
scene_data.Grid.num_sqrs_x = 40;    % m
scene_data.Grid.num_sqrs_y = 40;    % m
scene_data.Grid.line_width = 0.08;  % m
scene_data.Grid.clr = [1 1 1];      % [R G B]
scene_data.Grid.opc = 1;            % (0-1)

