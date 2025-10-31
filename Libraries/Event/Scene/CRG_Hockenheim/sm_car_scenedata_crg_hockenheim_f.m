function scene_data = sm_car_scenedata_crg_hockenheim_f
%% Scene parameters
% Copyright 2018-2025 The MathWorks, Inc.

curr_dir = pwd;
cd(fileparts(which(mfilename)));

scene_data.Name               = 'CRG_Hockenheim_F';
scene_data.CRGfile            = 'CRG_Hockenheim_f.crg';
scene_data.Geometry.filename  = 'CRG_Hockenheim_f.stl';
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

scene_data.Geometry.centerline.filename  = 'CRG_Hockenheim_f_centerline.stl';
scene_data.Geometry.centerline.fileunits = 'm';
scene_data.Geometry.centerline.clr   = [1 1 1]*1; % [R G B]
scene_data.Geometry.centerline.opc   = 1;           % (0-1)
scene_data.Geometry.centerline.x     = 0;           % m
scene_data.Geometry.centerline.y     = 0;           % m
scene_data.Geometry.centerline.z     = 0.01;           % m
scene_data.Geometry.centerline.yaw   = 0;           % rad
scene_data.Geometry.centerline.pitch = 0;           % rad
scene_data.Geometry.centerline.roll  = 0;           % rad
load('CRG_Hockenheim_f_dat');
scene_data.Geometry.centerline.xyz   = [dat.rx' dat.ry' 0*dat.rx']; % m
% If STL files do not exist, they will be created when scene is selected.

scene_data.Geometry.finish_line.post.height  = 6;             % m
scene_data.Geometry.finish_line.post.radius  = 0.5;           % m
scene_data.Geometry.finish_line.post.separation = 12;         % m
scene_data.Geometry.finish_line.post.clr     = [0.8 0.0 0.2]; % [R G B]
scene_data.Geometry.finish_line.post.opc     = 1;             % (0-1)
scene_data.Geometry.finish_line.offset.xyz   = scene_data.Geometry.centerline.xyz(1,:); % m
scene_data.Geometry.finish_line.offset.yaw   = double(dat.p(1));      % rad
scene_data.Geometry.finish_line.offset.pitch = 0;      % rad
scene_data.Geometry.finish_line.offset.roll  = 0;      % rad

cd(curr_dir);
