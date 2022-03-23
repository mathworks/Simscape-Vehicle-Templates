function scene_data = sm_car_scenedata_rdf_plateau
%% RDF Plateau parameters
% Copyright 2018-2022 The MathWorks, Inc.

scene_data.Name           = 'RDF_Plateau';
scene_data.Road.filename  = 'Plateau_Road.rdf';
scene_data.Road.depth     = 0.1;            % m
[xy_data_L, xy_data_R] = Extr_Data_RDF(scene_data.Road.filename,scene_data.Road.depth);
scene_data.Road.extr_data_L   = xy_data_L;  % m
scene_data.Road.extr_data_R   = xy_data_R;  % m
scene_data.Road.w           = 0.7;          % m

scene_data.Road.clr      = [1 1 1]*0.8;     % [R G B]
scene_data.Road.opc      = 1;               % (0-1)
scene_data.Road.x        = 0;               % m
scene_data.Road.profile_separation = 2.0;   % m
scene_data.Road.z        = 0;               % m
scene_data.Road.yaw      = 0;               % rad

