function CRG_Create_Rough_Road
% CRG_Create_Rough_Road       Create CRG file from grid data
%
% Creates CRG file for rough road grid
% Creates STL files based on data in CRG file.
%
% Copyright 2020-2024 The MathWorks, Inc.

road_opts.create_stl_files = true;
road_opts.decim_data = 0.1;
sm_car_grid_to_crg('CRG Rough Road',road_opts)

%% Create driver trajectory 

% Standard RDF Rough Road trajectory used (Straight No Accel)

% --- --- --- 
% The code below can be used to overwrite Maneuver variable
% in MATLAB workspace with trajectory data to follow
% the centerline of this CRG file.
%
% Run directly at MATLAB prompt

%{
dat = crg_read('CRG_Rough_Road.crg');
u_pts = double(linspace(0,dat.u,size(dat.z,1)));
Maneuver.Trajectory.xTrajectory.Value = u_pts;
Maneuver.Trajectory.aYaw.Value = double([0 dat.p]);

[pxy, ~] = crg_eval_uv2xy(dat, [u_pts' u_pts'*0]);

Maneuver.Trajectory.x.Value  = pxy(:,1)';
Maneuver.Trajectory.y.Value  = pxy(:,2)';
Maneuver.Trajectory.z.Value  = 0*pxy(:,2)';
Maneuver.Trajectory.vx.Value = 6*ones(size(pxy(:,2)'));
%}