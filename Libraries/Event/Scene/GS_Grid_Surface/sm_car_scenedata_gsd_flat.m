function scene_data = sm_car_scenedata_gsd_flat(varargin)
% The code below adds the grid surface for a flat surface to the Scene
% database. This is mainly for testing purposes, as the Infinite Plane
% would be a better way to model a flat surface.  
%
% Default values for the surface are provided.  If you wish to overwrite
% those values, provide them as input arguments.
%
%   geometryParam   Structure with color, opacity, offset, and orientation
%   gridParam       Structure with length and width of plane
% 
% **Note that there are some naming restrictions for scenes using the Grid
% Surface block as the data is used two places in the model, Scene (for
% visualization) and connected to each tire (physics).
%
% Copyright 2018-2026 The MathWorks, Inc.

curr_dir = pwd;
cd(fileparts(which(mfilename)));

% Parameters for appearance and offset
if(nargin>0)
    geometryParam = varargin{1};
else
    % Defaults
    geometryParam.clr   = [1 1 1]*0.8;  % [R G B]
    geometryParam.opc   = 1;            % (0-1)

    % Offsets here are applied to scene and surface at tire
    geometryParam.x     = 0;         % m
    geometryParam.y     = 0;         % m
    geometryParam.z     = 0;         % m
    geometryParam.yaw   = 0;         % rad
    geometryParam.pitch = 0;         % rad
    geometryParam.roll  = 0;         % rad
end
       
% Parameters for grid points
if(nargin>1)
    gridParam = varargin{2};
else
    % Defaults
    gridParam.len   = 320;
    gridParam.wid   = 320;
end

% **Note** - Always have 'GS_' as prefix for grid surface scenes.
% **Note** - This data appears in the Scene database, but must be copied to
%            Scene.GS_Grid_Surface for use.  This lets us use the same
%            subsystem block in a library for all scenes defined using a
%            single Grid Surface definition.
scene_data.Name     = 'GS_Grid_Surface_Flat';
scene_data.Geometry = geometryParam;

% Define rectangular grid points using parameters
gsd.data.xg        = [-0.5 0.5]*gridParam.len;
gsd.data.yg        = [-0.5 0.5]*gridParam.wid;
gsd.data.z_heights = [0 0;0 0];

scene_data.gsd = gsd.data;

cd(curr_dir);
