function traj_coeff = CRG_Create_Nurburgring_N
% CRG_Create_Nurburgring_N    Create CRG file from centerline data
%
% If no outputs are requested, creates CRG and geometry files
%   Creates CRG file for track with and without elevation.
%   Creates STL files based on data in CRG file.
%
% If output is requested, provides default trajectory coefficients
%
% Copyright 2020-2021 The MathWorks, Inc.

if(nargout == 0)
    road_opts.create_stl_files = true;
    road_opts.create_no_elevation = true;
    road_opts.create_stl_files_f = true;
    road_opts.decim_data = 1;
    road_opts.decim_alti = 1;
    road_opts.road_width = 9;      % Half width of the road
    road_opts.blending_distance = 70;
    road_opts.xa = 1;
    road_opts.xb = -3;
    road_opts.ya = 0.1;
    road_opts.yb = 0;
    road_opts.za = 1;
    road_opts.zb = 0.4;
    road_opts.reverse = 0;
    road_opts.datasrc = 'gps';  % xyz or gps
    sm_car_centerline_to_crg('CRG Nurburgring N',road_opts)
end
%% Create driver trajectory
traj_coeff.blend_distance = 80;     % m
traj_coeff.diff_exp       = 1;    % Curvature exponent
traj_coeff.diff_smooth    = 100;    % Diff smoothing number of points
traj_coeff.curv_smooth    = 200;    % Curvature smoothing number of points
traj_coeff.lim_smooth     = 500;    % Limit smoothing number of points
traj_coeff.target_shape_smooth = 200;  % Number of points for smoothing
traj_coeff.vmax           = 26;   % Max speed, m/s
traj_coeff.vmin           = 5;  % Min speed, m/s
traj_coeff.decimation     = 8;      % Decimation for interpolation

if(nargout == 0)
    % Create driver trajectory for road with elevation
    sm_car_trajectory_calc('CRG_Nurburgring_N',traj_coeff)
    
    % Create driver trajectory for road with elevation
    sm_car_trajectory_calc('CRG_Nurburgring_N_f',traj_coeff)
end