function CRG_Create_Plateau
% CRG_Create_Plateau       Create CRG file from centerline data
%
% Creates CRG file for track with and without elevation.
% Creates STL files based on data in CRG file.
%
% Copyright 2020-2021 The MathWorks, Inc.

road_opts.create_stl_files = true;
road_opts.create_no_elevation = false;
road_opts.create_stl_files_f = false;
road_opts.decim_data = 1;
road_opts.decim_alti = 1;
road_opts.road_width = 6;      % Half width of the road
road_opts.blending_distance = 0;
road_opts.xa = 0;
road_opts.xb = 0;
road_opts.ya = 0;
road_opts.yb = 0;
road_opts.za = 0;
road_opts.zb = 0;
road_opts.reverse = 0;
road_opts.datasrc = 'xyz';  % xyz or gps
sm_car_centerline_to_crg('CRG Plateau',road_opts)

%% Create driver trajectory 

% No trajectory - this is an open-loop maneuver

