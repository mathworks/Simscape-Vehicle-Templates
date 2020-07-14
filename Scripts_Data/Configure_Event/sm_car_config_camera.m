function sm_car_config_camera
% Copyright 2018-2020 The MathWorks, Inc.

veh_config = evalin('base','Vehicle.config');
veh_config_set = strsplit(veh_config,'_');
veh_body =  veh_config_set{1};

camera_str = ['Camera = CDatabase.Camera.' strrep(veh_body,'HambaLG','Hamba') ';'];
evalin('base',camera_str)
