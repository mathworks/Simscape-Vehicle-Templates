function traj_coeff = CRG_Create_Suzuka
% CRG_Create_Suzuka    Create CRG file from centerline data
%
% If no outputs are requested, creates CRG and geometry files
%   Creates CRG file for track with and without elevation.
%   Creates STL files based on data in CRG file.
%
% If output is requested, provides default trajectory coefficients
%
% Copyright 2020-2023 The MathWorks, Inc.

if(nargout == 0)
    road_opts.create_stl_files = true;
    road_opts.create_no_elevation = true;
    road_opts.create_stl_files_f = true;
    road_opts.decim_data = 1;
    road_opts.decim_alti = 1;
    road_opts.road_width = 9;      % Half width of the road
    road_opts.blending_distance = 70;
    road_opts.xa = 1;
    road_opts.xb = -0.2;
    road_opts.ya = 1;
    road_opts.yb = +0.3;
    road_opts.za = 1;
    road_opts.zb = 0;
    road_opts.reverse = 0;
    road_opts.datasrc = 'gps';  % xyz or gps
    sm_car_centerline_to_crg('CRG Suzuka',road_opts)
end

%% Create driver trajectory
traj_coeff.blend_distance = 80;     % m
traj_coeff.diff_exp       = 1.8;    % Curvature exponent
traj_coeff.diff_smooth    = 100;    % Diff smoothing number of points
traj_coeff.curv_smooth    = 300;    % Curvature smoothing number of points
traj_coeff.lim_smooth     = 500;    % Limit smoothing number of points
traj_coeff.target_shape_smooth = 50;  % Number of points for smoothing
traj_coeff.vmax           = 13*2;   % Max speed, m/s
traj_coeff.vmin           = 4*2;    % Min speed, m/s
traj_coeff.decimation     = 8;      % Decimation for interpolation

if(nargout == 0)
    % Create driver trajectory for road with elevation
    sm_car_trajectory_calc('CRG_Suzuka',traj_coeff)
    
    % Create driver trajectory for road with elevation
    sm_car_trajectory_calc('CRG_Suzuka_f',traj_coeff)
end