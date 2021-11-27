function F  = obj_traj_vx(x,mdl,trackname,h_vx,h_xy)
% Objective function to optimize trajectory of car (velocity along path)
% Copyright 2020-2021 The MathWorks, Inc.

load_system(mdl);

% -- Calculate new trajectory
% Get trajectory coefficients from base workspace
traj_coeff = evalin('base','traj_coeff');

% Overwrite tuned parameters with new values from optimizer
traj_coeff.vmin           = x(1);   % Min speed, m/s
traj_coeff.vmax           = x(2);   % Max speed, m/s
traj_coeff.diff_exp       = x(3);   % Scaling coefficient

% Calculate new trajectory
new_trajectory = sm_car_trajectory_calc(trackname,traj_coeff);

% Write new trajectory to base workspace so sm_car can access it
Maneuver = evalin('base','Maneuver');
Maneuver.Trajectory = new_trajectory;
assignin('base','Maneuver',Maneuver);

% Run simulation
if(x(3)>=1)
    simOut=sim(mdl);
else
    % Only run a short simulation if diff_exp < 1
    simOut=sim(mdl,'StopTime','1');
end

% -- Compute cost function
% Extract relevant measurements
logsout_sm_car = simOut.get('logsout_sm_car');
logsout_DrvBus = logsout_sm_car.get('DrvBus');
dist_car = logsout_DrvBus.Values.Reference.dist;
ld = logsout_DrvBus.Values.Reference.latdev.Data;
track_length = max(Maneuver.Trajectory.xTrajectory.Value);

% Calculate cost
max_ld_threshold = str2double(get_param([mdl '/Check'],'lat_dev_threshold'));
[lap_time, max_ld] = check_lap_time(dist_car,track_length,ld,max_ld_threshold);

if(x(3)<1)
    % Prevent values of diff_exp that are less than 1
    % Only necessary for optimization algorithms that do not permit
    % boundaries on parameter values, like fminsearch
    lap_time = 10000;
end

if(lap_time == 10000)
    F = NaN;
else
    F = lap_time;
end
% Assemble legend string
vmin_str = sprintf('%2.2f',x(1));
vmax_str = sprintf('%2.2f',x(2));
dexp_str = sprintf('%2.2f',x(3));
lapt_str = sprintf('%2.2f',lap_time);
display_name = [pad(vmin_str,5) ' ' pad(vmax_str,5) ' ' pad(dexp_str,5) ' ' lapt_str];

% Plot velocity trajectory
figure(h_vx)
plot(new_trajectory.xTrajectory.Value,new_trajectory.vx.Value,'DisplayName',display_name);

% Plot path taken
figure(h_xy)
VehBus = logsout_sm_car.get('VehBus');
plot(VehBus.Values.World.x.Data,VehBus.Values.World.y.Data,'DisplayName',display_name);

% Save data for each iteration for post-processing
opt_iter.param   = x;
opt_iter.laptime = lap_time;
opt_iter.latdev  = max_ld;
opt_iter.x       = VehBus.Values.World.x.Data;
opt_iter.y       = VehBus.Values.World.y.Data;
opt_iter.vx      = VehBus.Values.Chassis.Body.CG.vx.Data;
opt_iter.bgx      = VehBus.Values.Chassis.Body.CG.gx.Data;
opt_iter.bgy      = VehBus.Values.Chassis.Body.CG.gy.Data;
opt_iter.xpath   = dist_car;
opt_iter.traj_x  = new_trajectory.xTrajectory.Value;
opt_iter.traj_vx = new_trajectory.vx.Value;

numiter = evalin('base',['length(OptRes_' trackname ');']);
assignin('base','opt_iter',opt_iter);
if(numiter==0)
    evalin('base',['clear OptRes_' trackname ]);
end
evalin('base',['OptRes_' trackname '(' num2str(numiter+1) ') = opt_iter;']);

function [lap_time, max_ld] = check_lap_time(dist_car,track_length,ld,max_ld_threshold)
% Find time for lap and maximum deviation
% If car leaves track, set lap time arbitrarily high
%
% dist_car:     Distance along trajectory to point on trajectory
%               that is closest to car's current position
% track_length: Length of track
% ld:           Lateral deviation from target path

% Find range of values to check for max
min_ld_ind = find(dist_car.Time>5);   % Ignore first 5 seconds
lap_t_ind  = find(dist_car.Data>(max(track_length)-10));
if(isempty(lap_t_ind))
    max_ld = max(ld(min_ld_ind:end));
else
    max_ld = max(ld(min_ld_ind:lap_t_ind(1)));
end

if(~isempty(lap_t_ind) && max_ld<max_ld_threshold)
    %if(~isempty(lap_t_ind) )
    % Take first time car was close to finish line (dist_car can wrap)
    lap_time = dist_car.Time(lap_t_ind(1));
else
    % Assign very high value if lap was not completed
    lap_time = 10000;
end

% To display iteration results
%{
laptime_str = sprintf('%5.2f',lap_time);
maxld_str   = sprintf('%5.2f',max_ld);
disp(['Lap Time: ' pad(laptime_str,7,'left') ', Max lateral deviation: ' pad(maxld_str,5,'left') ]);
%}
