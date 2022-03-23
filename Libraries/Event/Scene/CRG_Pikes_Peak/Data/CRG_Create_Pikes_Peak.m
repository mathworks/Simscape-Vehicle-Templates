function CRG_Create_Pikes_Peak
% CRG_Create_Pikes_Peak    Create CRG file from centerline data
%
% Creates CRG file for track with and without elevation.
% Creates STL files based on data in CRG file.
%
% Copyright 2020-2022 The MathWorks, Inc.

road_opts.create_stl_files = true;
road_opts.create_no_elevation = true;
road_opts.create_stl_files_f = true;
road_opts.decim_data = 1;
road_opts.decim_alti = 1;
road_opts.road_width = 3;      % Half width of the road
road_opts.blending_distance = 0;
road_opts.xa = 1;
road_opts.xb = -3;
road_opts.ya = 0.1;
road_opts.yb = 0;
road_opts.za = 1;
road_opts.zb = 0.4;
road_opts.reverse = 1;
road_opts.datasrc = 'gps';  % xyz or gps
sm_car_centerline_to_crg('CRG Pikes Peak',road_opts)

%% Create driver trajectory 
traj_coeff.blend_distance = 0;   % m
traj_coeff.diff_exp       = 1.2;  % Curvature exponent
traj_coeff.diff_smooth    = 100;   % Diff smoothing number of points
traj_coeff.curv_smooth    = 200;  % Curvature smoothing number of points
traj_coeff.lim_smooth     = 500;  % Limit smoothing number of points
traj_coeff.target_shape_smooth = 100;  % Number of points for smoothing
traj_coeff.vmax           = 10*2;   % Max speed, m/s
traj_coeff.vmin           = 3*2;    % Min speed, m/s
traj_coeff.decimation     = 8;    % Decimation for interpolation

% Create driver trajectory for road with elevation
sm_car_trajectory_calc('CRG_Pikes_Peak',traj_coeff)

load('CRG_Pikes_Peak_trajectory_default');
x.Value     = fliplr(x.Value);
y.Value     = fliplr(y.Value);
z.Value     = fliplr(z.Value);
vx.Value    = flipud(vx.Value);
xTrajectory.Value = [0 cumsum(sqrt((diff(x.Value)).^2+diff(y.Value).^2))];
aYaw.Value  = fliplr(aYaw.Value)+pi;
%clear mptemp
save(['CRG_Pikes_Peak_trajectory_down'],...
    'x','y','z','vx','aYaw','xTrajectory');


% Create driver trajectory for road with elevation
sm_car_trajectory_calc('CRG_Pikes_Peak_f',traj_coeff)