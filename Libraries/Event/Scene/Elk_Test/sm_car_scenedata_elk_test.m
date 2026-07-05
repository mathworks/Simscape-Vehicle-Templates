function scene_data = sm_car_scenedata_elk_test
%% Elk Test parameters
% Copyright 2018-2026 The MathWorks, Inc.

scene_data.Name = 'Elk_Test';
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

% Snowbank
scene_data.Snowbank.l = scene_data.Road.l;
scene_data.Snowbank.w = scene_data.Road.w;
scene_data.Snowbank.h = 1.2;

% Elk Motion
scene_data.Elk_Motion.x0      = -12;    % Initial position relative to road center
scene_data.Elk_Motion.y0      =  -4.6;  % Initial position relative to road center
scene_data.Elk_Motion.z0      =   0.2;  % Initial position relative to road center

scene_data.Elk_Motion.q0      = 180; % deg  (180 for left, 0 for right)

scene_data.Elk_Motion.t0      =    10;    % Elk motion start time
scene_data.Elk_Motion.speed   =    1.3;  % Elk motion speed
scene_data.Elk_Motion.xmax    =    2.6;  % Elk motion min (right limit of elk motion)
scene_data.Elk_Motion.xmin    = -100.0;  % Elk motion max (left limit of elk motion)

% Offsets are from road reference frame (center of upper surface)
scene_data.Ice.offsetRoadCtr.x = 20;
scene_data.Ice.offsetRoadCtr.y =  0;
scene_data.Ice.offsetRoadCtr.z =  0;

% Dimensions are local
scene_data.Ice.x = 80.0;
scene_data.Ice.y = scene_data.Road.w*2;
scene_data.Ice.h = 0.011;
scene_data.Ice.clr   = [0.8 1.0 1.0]; % [R G B]
scene_data.Ice.opc   = 1;             % (0-1)

% Mu Scaling x and y must be global
ice_x_min = scene_data.Road.x+scene_data.Ice.offsetRoadCtr.x-scene_data.Ice.x/2;
ice_x_max = ice_x_min + scene_data.Ice.x;

ice_y_min = scene_data.Road.y+scene_data.Ice.offsetRoadCtr.y-scene_data.Ice.y/2;
ice_y_max = ice_y_min + scene_data.Ice.y;

scene_data.Mu_Scaling.x = [           0  ice_x_min-0.1  ice_x_min ice_x_max  ice_x_max+0.1 ice_x_max+200];
scene_data.Mu_Scaling.y = [ice_y_min-30  ice_y_min-0.1  ice_y_min ice_y_max  ice_y_max+0.1 ice_y_max+30];
scene_data.Mu_Scaling.scale = [  ...
    1   1     1      1     1     1;
    1   1     1      1     1     1;
    1   1     0.1    0.55  1     1;
    1   1     0.1    0.55  1     1;
    1   1     1      1     1     1;
    1   1     1      1     1     1];








