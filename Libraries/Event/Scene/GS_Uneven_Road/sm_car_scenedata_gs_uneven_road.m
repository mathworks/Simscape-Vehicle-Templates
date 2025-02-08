function scene_data = sm_car_scenedata_gs_uneven_road
%% Scene parameters
% Copyright 2018-2024 The MathWorks, Inc.

%% Defining this maneuver
% The code below adds the grid surface for uneven road to the Scene
% database. It is expected that the grid surface will be derived from a crg
% file.  The base name for the files must be the same, and the prefix for
% the filename must be "GS_".
%
% If the .mat file exists, it will be loaded at this time.  If the .mat
% file does not exist, it and the STL will be created the first time the
% maneuver is selected.

%% Customizing this maneuver
% If you wish to replace the surface with a new CRG:
% 1. Replace the CRG file with your file
% 2. Delete (or rename) the existing <name>_GSD.mat file
% 3. Delete (or rename) the existing <name>.stl file
% 4. Load all scenes again
% 5. Select a maneuver that requires this scene.
%    This will trigger the .stl and .mat files to be regenerated.

curr_dir = pwd;
cd(fileparts(which(mfilename)));

% Note - always have 'GS_' as prefix for grid surface scenes.
scene_data.Name               = 'GS_Uneven_Road';
scene_data.CRGfile            = [scene_data.Name '.crg'];
scene_data.GSData.filename    = [scene_data.Name '_GSD.mat'];
scene_data.Geometry.filename  = [scene_data.Name '.stl'];
scene_data.Geometry.fileunits = 'm';
scene_data.Geometry.clr   = [1 1 1]*0.8; % [R G B]
scene_data.Geometry.opc   = 1;           % (0-1)
scene_data.Geometry.x     = 0;           % m
scene_data.Geometry.y     = 0;           % m
scene_data.Geometry.z     = 0;           % m
scene_data.Geometry.yaw   = 0;           % rad
scene_data.Geometry.pitch = 0;           % rad
scene_data.Geometry.roll  = 0;           % rad

% If the .mat file with the points for the grid surface exists, 
% load all fields into Scene definition under field "gsd".
if(exist(scene_data.GSData.filename,'file'))
    load(scene_data.GSData.filename)
    fnamesGSD = fieldnames(gsd);
    for fn_i = 1:length(fnamesGSD)
        scene_data.gsd.(fnamesGSD{fn_i}) = gsd.(fnamesGSD{fn_i});
    end
end
cd(curr_dir);