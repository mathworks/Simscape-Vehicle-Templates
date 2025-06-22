function sceneName = sm_car_plot3d_manv_to_scene(Maneuver)
% sm_car_plot3d_manv_to_scene  Select scene data based on maneuver
%   sceneName = sm_car_plot3d_manv_to_scene(Maneuver)
%   This function returns the scene name suitable for the maneuver. The
%   name is used to select the right set of data to visualize the road
%   surface.
%
%   Maneuver    Field Maneuver.Type is used to select the sceneName
%
% Copyright 2025 The MathWorks, Inc.

if(regexp(Maneuver.Type,'CRG_.*'))
    sceneName = Maneuver.Type;   % Road follows trajectory
elseif(any(strcmp(Maneuver.Type,{'Double_Lane_Change','Double_Lane_Change_ISO3888','Straight_Constant_Speed_12_50'})))
    sceneName = 'Road_Two_Lane'; % Two lane road with y-axis offset
elseif(any(strcmp(Maneuver.Type,  {'Slalom'})))
    sceneName = 'Slalom'; % Y-offset for road is 0
elseif(strcmp(Maneuver.Type,'Skidpad'))
    sceneName = 'Skidpad';       % Formula Student Skidpad maneuver
else
    sceneName = 'Flat';          % Large flat surface (default)
end

