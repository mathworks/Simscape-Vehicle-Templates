function scene_data = sm_car_scenedata_gsd_bump_trpz(varargin)
% The code below adds the grid surface for a trapezoidal bump to the Scene
% database.
%
% Default values for the surface are provided.  If you wish to overwrite
% those values, provide them as input arguments.
%
%   geometryParam   Structure with color, opacity, offset, and orientation
%   gridParam       Structure with length and width of plane
%
% **Note** -- there are some naming restrictions for scenes using the Grid
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
    % Offsets applied yaw-pitch-roll, then x-y-z.
    % Rotation done first to simplify asymmetrical bumps (left/right only)
    geometryParam.x     = 50;        % m (bump distance)
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
    % Size of plane
    gridParam.len   = geometryParam.x*3;
    gridParam.wid   = geometryParam.x*3;

    % Shape of trapezoidal bump defined by four distances
    % Longitudinal 
    gridParam.bumptrpz_xFlr1 =   0.05;  % Distance to start of bump surface (m)
    gridParam.bumptrpz_xFlr2 =   1.95;  % Distance to end of bump surface (m)
    gridParam.bumptrpz_len   =   2;     % Distance to end of bump opening (m)
                                       % Must be less than gridParam.bumptrpz_len
    gridParam.bumptrpz_dep   =  -0.15;  % Depth of bump floor (m)
    gridParam.bumptrpz_side  =  'both'; % Affects 'both', 'left', or 'right' wheels
end

% Note - always have 'GS_' as prefix for grid surface scenes.
scene_data.Name     = 'GS_Grid_Surface_BumpTrpz';
scene_data.Geometry = geometryParam;

% Error checking
if(gridParam.bumptrpz_xFlr2>=gridParam.bumptrpz_len)
    error(['Distance to end of bump surface (bumptrpz_xFlr2 = ' num2str(gridParam.bumptrpz_xFlr2) ') must be less than length of bump opening (bumptrpz_len = ' num2str(gridParam.bumptrpz_len) ').']);
end

% Form x-vector for grid
gsd.data.xg        = [...
    0 ...
    gridParam.len/2 ...
    gridParam.len/2+gridParam.bumptrpz_xFlr1 ...
    gridParam.len/2+gridParam.bumptrpz_xFlr2 ...
    gridParam.len/2+gridParam.bumptrpz_len ...
    gridParam.len]-gridParam.len/2;

% Form y-vector and heights for grid
yDistBumpEdge = 0.01; % Lateral distance for bump edge (m)
switch gridParam.bumptrpz_side
    case 'both'
        gsd.data.yg        = [-0.5 0.5]*gridParam.wid;
        gsd.data.z_heights = repmat([0 0 gridParam.bumptrpz_dep gridParam.bumptrpz_dep 0 0],2,1)';
    case {'right'}
        % Left side is flat, right side has bump
        gsd.data.yg        = [-0.5 -0.01 0 0.01 0.5]*gridParam.wid;
        gsd.data.yg(2) = -yDistBumpEdge;
        gsd.data.yg(4) =  yDistBumpEdge;        
        gsd.data.z_heights = [...
            repmat([0 0 gridParam.bumptrpz_dep gridParam.bumptrpz_dep 0 0],2,1);
            zeros(3,length(gsd.data.xg))]';
    case {'left'}
        % Left side has bump, right side is flat
        gsd.data.yg        = [-0.5 -0.01 0 0.01 0.5]*gridParam.wid;
        gsd.data.yg(2) = -yDistBumpEdge;
        gsd.data.yg(4) =  yDistBumpEdge;        
        gsd.data.z_heights = flipud([...
            repmat([0 0 gridParam.bumptrpz_dep gridParam.bumptrpz_dep 0 0],2,1);
            zeros(3,length(gsd.data.xg))])';
end
scene_data.gsd = gsd.data;

cd(curr_dir);
