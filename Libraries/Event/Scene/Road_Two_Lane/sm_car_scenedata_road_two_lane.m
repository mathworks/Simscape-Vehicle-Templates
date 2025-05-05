function scene_data = sm_car_scenedata_road_two_lane

% Copyright 2018-2024 The MathWorks, Inc.

scene_data.Name = 'Road_Two_Lane';
scene_data.Dashes.pitch = 7.5;      % m
scene_data.Dashes.num = 58;         % m
scene_data.Dashes.l = 3;            % m
scene_data.Dashes.w = 0.15;         % m
scene_data.Dashes.h = 0.01;        % m
scene_data.Dashes.base_h = 0.025;   % m
scene_data.Dashes.clr = [1 1 1];    % [R G B]
scene_data.Dashes.opc = 1;          % (0-1)

% Road length matches dash length
scene_data.Road.l = scene_data.Dashes.pitch*scene_data.Dashes.num; % m
scene_data.Road.w = 8;              % m
scene_data.Road.h = 0.1;            % m
scene_data.Road.clr = [1 1 1]*0.5;  % [R G B]
scene_data.Road.opc = 1;            % (0-1)
scene_data.Road.x     = 218.4;      % m

% Adjustments due to Unreal scene change in R2022b
if(verLessThan('matlab','9.13'))
    scene_data.Road.y     = -1.2;  % m
else
    scene_data.Road.y     = -1.2-2.5;  % m
end

scene_data.Road.z     = 0;          % m
scene_data.Road.roll  = 0*pi/180;   % rad
scene_data.Road.pitch = 0*pi/180;   % rad
scene_data.Road.yaw   = 0*pi/180;   % rad



