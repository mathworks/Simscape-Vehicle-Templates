function scene_data = sm_car_scenedata_double_lane_change
%% Floor and Grid parameters
% Copyright 2018-2024 The MathWorks, Inc.

scene_data.Name = 'Double_Lane_Change';
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

scene_data.Cones.lane_a_offset       = 173.8; % m
scene_data.Cones.lane_width          = 3.3;  % m
scene_data.Cones.lane_lateral_offset = 4.1;  % m
scene_data.Cones.lane_a_length       = 12.5; % m
scene_data.Cones.gap_a_to_b          = 12.7; % m
scene_data.Cones.lane_b_length       = 12.3; % m
scene_data.Cones.gap_b_to_c          = 12.7; % m
scene_data.Cones.lane_c_length       = 12.0; % m
scene_data.Cones.height              = 0.6;  % m
scene_data.Cones.base_thickness      = 0.04; % m
scene_data.Cones.base_width          = 0.35;  % m
scene_data.Cones.bottom_diameter     = 0.24; % m
scene_data.Cones.top_diameter        = 0.06; % m
scene_data.Cones.strip_height        = 0.3;  % m
scene_data.Cones.clr                 = [248 78 25]/255;  % [RGB]
scene_data.Cones.strip_clr           = [0.75 0.75 0.75]; % [RGB]







