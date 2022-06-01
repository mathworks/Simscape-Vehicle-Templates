function scene_data = sm_car_scenedata_crg_rough_road
%% Scene parameters
% Copyright 2018-2022 The MathWorks, Inc.

curr_dir = pwd;
cd(fileparts(which(mfilename)));

scene_data.Name               = 'CRG_Rough_Road';
scene_data.CRGfile            = 'CRG_Rough_Road.crg';
scene_data.Geometry.filename  = 'CRG_Rough_Road.stl';
scene_data.Geometry.fileunits = 'm';
scene_data.Geometry.clr   = [1 1 1]*0.8; % [R G B]
scene_data.Geometry.opc   = 1;           % (0-1)
scene_data.Geometry.x     = 0;           % m
scene_data.Geometry.y     = 0;           % m
scene_data.Geometry.z     = 0;           % m
scene_data.Geometry.yaw   = 0;           % rad
scene_data.Geometry.pitch = 0;           % rad
scene_data.Geometry.roll  = 0;           % rad
scene_data.Geometry.w     = 12;          % m

cd(curr_dir);