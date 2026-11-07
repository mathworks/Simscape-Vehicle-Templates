%% Customize bump - left side, convex bump
geometryParam.clr   = [1 1 1]*0.8; % [R G B]
geometryParam.opc   = 1;           % (0-1)

% Offsets - applied yaw-pitch-roll, then x-y-z.
% Rotation done first to simplify asymmetrical bumps (left/right only)
geometryParam.x     = 50;        % m (pothole distance)
geometryParam.y     = 0;         % m
geometryParam.z     = 0;         % m
geometryParam.yaw   = 15*pi/180*0; % rad (rotation of surface)
geometryParam.pitch = 0;         % rad
geometryParam.roll  = 0;         % rad

% Size of plane
gridParam.len   = geometryParam.x*3;
gridParam.wid   = geometryParam.x*3;

% Shape of trapezoidal bump defined by four distances
gridParam.bumptrpz_xFlr1 =   0.7;  % Distance to start of bump surface (m)
gridParam.bumptrpz_xFlr2 =   0.7+0.310;  % Distance to end of bump surface (m)
gridParam.bumptrpz_len   =   1.710;     % Distance to end of bump opening (m)
% Must be less than gridParam.bumptrpz_len
gridParam.bumptrpz_dep   =   0.15;  % Depth of bump floor (m)
gridParam.bumptrpz_side  =  'left'; % Affects 'both', 'left', or 'right' wheels

Scene.GS_Grid_Surface = sm_car_scenedata_gsd_bump_trpz(geometryParam,gridParam);
