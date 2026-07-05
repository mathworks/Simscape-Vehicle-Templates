% Script to test trapezoidal bump
%
% The grid surface block can be used to define various surfaces.  In this
% script, it is used to define a trapezoidal bump with parameterized depth,
% orientation, and targeting the left and/or right wheels.
%
% Copyright 2026 The MathWorks, Inc

%% Open models and load vehicle data
% 
open_system('sm_car')

% Preset number
preset_num = '189'; % Double Wishbone

% Load preset
sm_car_load_vehicle_data('none',preset_num);

% Enable bushings
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'DoubleWishbone_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','BushArm_AxRad_Sef_DW_LA');
Vehicle = sm_car_vehcfg_setSusp(Vehicle,'DoubleWishboneA_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','BushArm_AxRad_Sef_DW_LA');

%% Configure maneuver, default trapezoidal bump
if(verLessThan('matlab','9.14'))
    sm_car_config_maneuver('sm_car','CRG Rough Road');
else
    sm_car_config_maneuver('sm_car','GS Grid Surface BumpTrpz');
end

%% Customize pothole
geometryParam.clr   = [1 1 1]*0.8; % [R G B]
geometryParam.opc   = 1;           % (0-1)

% Offsets - applied yaw-pitch-roll, then x-y-z.
% Rotation done first to simplify asymmetrical bumps (left/right only)
geometryParam.x     = 50;        % m (pothole distance)
geometryParam.y     = 0;         % m
geometryParam.z     = 0;         % m
geometryParam.yaw   = 15*pi/180; % rad (rotation of surface)
geometryParam.pitch = 0;         % rad
geometryParam.roll  = 0;         % rad


gridParam.len   = geometryParam.x*3;
gridParam.wid   = geometryParam.x*3;

% 
gridParam.bumptrpz_len   =   4;
gridParam.bumptrpz_xFlr1 =   0.25;
gridParam.bumptrpz_xFlr2 =   3.75; % Must be less than gridParam.bumptrpz_len
gridParam.bumptrpz_dep   =  -0.15;
gridParam.bumptrpz_side  =  'both';

Scene.GS_Grid_Surface = sm_car_scenedata_gsd_bump_trpz(geometryParam,gridParam);

%% Simulate model
sim('sm_car');

% Plot Results
figure(1)
clf
ax_1 = subplot(221);
sm_car_gs_grid_surface_plot(Scene.GS_Grid_Surface,ax_1);
title('Surface (Both, Rotated)')

ax_2 = subplot(222);
sm_car_sim_res_plot('time','pzWhl',ax_2)

if(verLessThan('matlab','9.14'))
    text(0.9,0.9,'Surface not used','Units','Normalized',...
        'HorizontalAlignment','right')
else
    set(ax_2,'XLim',[12.5 16])
end

%% Custom pothole
gridParam.bumptrpz_dep   =   0.15;
gridParam.bumptrpz_side  =  'left';

Scene.GS_Grid_Surface = sm_car_scenedata_gsd_bump_trpz(geometryParam,gridParam);

%% Simulate model
sim('sm_car');

%% Plot Results
ax_3 = subplot(223);
sm_car_gs_grid_surface_plot(Scene.GS_Grid_Surface,ax_3);
title('Surface (Left, Rotated)')


ax_4 = subplot(224);
sm_car_sim_res_plot('time','pzWhl',ax_4)

if(verLessThan('matlab','9.14'))
    text(0.9,0.9,'Surface not used','Units','Normalized',...
        'HorizontalAlignment','right')
else
    set(ax_4,'XLim',[12.5 16])
end

%% Plot Bushing results
bushRes = sm_car_sim_res_bushings(logsout_sm_car);
figure(2)
clf
sm_car_plot_bushings(bushRes,{'A1_L','A2_L'},{'LAf'},{'fy','fz'},gca);
