function scene_data = sm_car_scenedata_mcity
%% Scene parameters
% Copyright 2020-2022 The MathWorks, Inc.

curr_dir = pwd;
cd(fileparts(which(mfilename)));

scene_data.Name               = 'MCity';
scene_data.Geometry.filename  = 'MCity_roads.stl';
scene_data.Geometry.fileunits = 'm';
scene_data.Geometry.clr   = [1 1 1]*0.8; % [R G B]
scene_data.Geometry.opc   = 1;           % (0-1)
scene_data.Geometry.x     = -117;           % m
scene_data.Geometry.y     = -173;           % m
scene_data.Geometry.z     = -1;           % m
scene_data.Geometry.yaw   = 0;           % rad
scene_data.Geometry.pitch = 0;           % rad
scene_data.Geometry.roll  = 0;           % rad

scene_data.Geometry.grass.filename  = 'MCity_grass.stl';
scene_data.Geometry.grass.fileunits = 'm';
scene_data.Geometry.grass.clr   = [0.30 0.57 0.45]; % [R G B]
scene_data.Geometry.grass.opc   = 1;           % (0-1)
scene_data.Geometry.grass.x     = scene_data.Geometry.x;           % m
scene_data.Geometry.grass.y     = scene_data.Geometry.y;           % m
scene_data.Geometry.grass.z     = scene_data.Geometry.z-0.01;           % m
scene_data.Geometry.grass.yaw   = 0;           % rad
scene_data.Geometry.grass.pitch = 0;           % rad
scene_data.Geometry.grass.roll  = 0;           % rad

cd(curr_dir);