%% Script to sweep target trajectory for car (vx along path)

% Get trajectory parameters
traj_coeff = CRG_Create_Mallory_Park;

% Open model
open_system('sm_car');

% Select vehicle configuration (basic, flat roads only)
sm_car_load_vehicle_data('sm_car','164');
Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

% Select flat Mallory Park maneuver
sm_car_config_maneuver('sm_car','Mallory Park');

% Enable checks to terminate run if lap is complete
set_param('sm_car/Check','start_check_time_end_lap','5');

% FastRestart: VERY IMPORTANT to enable for sweeps and optimization 
% When FastRestart is on, general plotting scripts may not work
% because output is all placed in one variable
set_param(bdroot,'FastRestart','on')

%% First parameter set
% Initial values for tunable trajectory parameters
traj_coeff.vmax           = 15*2;   % Max speed, m/s
traj_coeff.vmin           = 3*2;    % Min speed, m/s

% Generate new trajectory
new_trajectory = sm_car_trajectory_calc('CRG_Mallory_Park_f',traj_coeff);

% Load trajectory into variable referenced by sm_car
Maneuver.Trajectory = new_trajectory;

% Simulate model
% All outputs into one variable due to FastRestart
simOut=sim('sm_car');

% Check lap time, lateral deviation
check_lap_time(simOut,Maneuver);

%% Second parameter set
% Initial values for tunable trajectory parameters
traj_coeff.vmax           = 15*1;   % Max speed, m/s
traj_coeff.vmin           = 3*1;    % Min speed, m/s

% Generate new trajectory
new_trajectory = sm_car_trajectory_calc('CRG_Mallory_Park_f',traj_coeff);

% Load trajectory into variable referenced by sm_car
Maneuver.Trajectory = new_trajectory;

% Simulate model
% All outputs into one variable due to FastRestart
simOut=sim('sm_car');

% Check lap time, lateral deviation
check_lap_time(simOut,Maneuver);

% Disable checks to terminate run if lap is complete
set_param('sm_car/Check','start_check_time_end_lap','10000');

% Turn off Fast Restart
set_param(bdroot,'FastRestart','off')


%% ------- Lap Time Check
function [lap_time, max_ld] = check_lap_time(simOut,Maneuver)
% -- Find time for lap
% dist_car: distance along trajectory to 
% point on trajectory that is closest to car's current position
logsout_sm_car = simOut.get('logsout_sm_car');
logsout_DrvBus = logsout_sm_car.get('DrvBus');
dist_car = logsout_DrvBus.Values.Reference.dist;

getPose_simres_matrix  = logsout_sm_car.get('getPose_simres');
getPose_simres_vec = reshape(getPose_simres_matrix.Values.Data(:)',12,[])';
ld = getPose_simres_vec(:,9);
%max_ld = max(ld);

% Find when car was near finish line
lap_t_ind = find(dist_car.Data>(max(Maneuver.Trajectory.xTrajectory.Value)-10));

% Ignore first 5 seconds for max lateral deviation
min_ld_ind = find(dist_car.Time>5);
max_ld = max(ld(min_ld_ind:lap_t_ind(1)));

%if(~isempty(lap_t_ind) && max_ld<4.5)  % To throw away lap if ld too big
if(~isempty(lap_t_ind) )
    % Take first time car was close to finish line (dist_car wraps)
    lap_time = dist_car.Time(lap_t_ind(1)); 
else
    % Assign very high value if lap was not completed
    lap_time = 1000;
end

laptime_str = sprintf('%5.2f',lap_time);
maxld_str   = sprintf('%5.2f',max_ld);
disp(['Lap Time: ' pad(laptime_str,7,'left') ', Max lateral deviation: ' pad(maxld_str,5,'left') ]);

end
