function scene_data = sm_car_scenedata_skidpad
%% Skidpad parameters
% Copyright 2018-2025 The MathWorks, Inc.

scene_data.Name = 'Skidpad';
scene_data.Circle_Inner.d    = 15.25;      % m
scene_data.Circle_Outer.d    = 15.25+6;         % m

scene_data.Circle_Inner.sep  = 18.25;         % m
scene_data.Circle_Inner.w    = 0.2;      % m
scene_data.Circle_Inner.clr = [1.0 1.0 0.8];    % [R G B]
scene_data.Circle_Inner.opc = 1;          % (0-1)
scene_data.Circle_Inner.h = 0.011;          % m

scene_data.Circle_Outer.ang1 = -180+acosd((18.25/2)/(15.25/2+3));         % m
scene_data.Circle_Outer.ang2 = -180+360-acosd((18.25/2)/(15.25/2+3));         % m
scene_data.Circle_Outer.w    = 0.2;      % m
scene_data.Circle_Outer.h = 0.011;          % m
scene_data.Circle_Outer.clr = [1.0 1.0 0.8];    % [R G B]
scene_data.Circle_Outer.opc = 1;          % (0-1)

a1 = scene_data.Circle_Outer.ang1;
a2 = scene_data.Circle_Outer.ang2;
r  = (scene_data.Circle_Inner.d+scene_data.Circle_Outer.d)/4;
sep = scene_data.Circle_Inner.sep;

x = [sind([a1:1:a2])*r+sep/2  sind(360-[a2:-1:a1])*r-sep/2];
y = [cosd([a1:1:a2])*r+sep/2  cosd(360-[a2:-1:a1])*r-sep/2];
x = [sind([a1:1:a2])*r  -sind(360-[a2:-1:a1])*r];
y = [cosd([a1:1:a2])*r+sep/2  -cosd(360-[a2:-1:a1])*r-sep/2];
z = zeros(size(x));
ctrline = [x' y' z'];
scene_data.Track.ctrline = ctrline;
scene_data.Track.w       = 6;

scene_data.Plane.l = 15.25+6*8; % m
scene_data.Plane.w = 18.25+15.25+12*1.5; % m
scene_data.Plane.h = 0.01;          % m
scene_data.Plane.x = 0;           % m
scene_data.Plane.y = 0;             % m
scene_data.Plane.z = 0;             % m
scene_data.Plane.clr = [1 1 1]*0.8; % [R G B]
scene_data.Plane.opc = 1;            % (0-1)


