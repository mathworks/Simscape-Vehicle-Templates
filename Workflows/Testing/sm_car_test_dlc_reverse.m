% Script to test double lane change driving reverse in sedan
%
% The driver models are capable of guiding the vehicle as it is driven in
% reverse.  The script below makes a few adjustments to the provided
% trajectory so that the driver model completes the event while driving in
% reverse.  The adjustments shown below will work for other maneuvers.
% Tuning of the driver parameters may be required to get good driving
% performance.
%
% Copyright 2025 The MathWorks, Inc

% Load vehicle
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','189')

%% Configure maneuver
sm_car_config_maneuver('sm_car','Double Lane Change');

% Apply offsets for reverse
% * Add 180 degrees to yaw
Maneuver.Trajectory.aYaw.Value = Maneuver.Trajectory.aYaw.Value+pi;
Init.Chassis.aChassis.Value(3) = Init.Chassis.aChassis.Value(3) + pi;

% * Swap sign on pitch and roll
Init.Chassis.aChassis.Value(2) = -Init.Chassis.aChassis.Value(2);
Init.Chassis.aChassis.Value(1) = -Init.Chassis.aChassis.Value(1);

% * Swap sign on target velocity, scale if needed
Maneuver.Trajectory.vx.Value = -Maneuver.Trajectory.vx.Value*1;

% * Swap sign on initial velocities
Init.Chassis.vChassis.Value(1) = -Init.Chassis.vChassis.Value(1);
Init.Axle1.nWheel.Value = Init.Axle1.nWheel.Value.*[-1 -1 1];
Init.Axle2.nWheel.Value = Init.Axle2.nWheel.Value.*[-1 -1 1];

% * Extend preview distance - must start steering earlier in the trajectory
Maneuver.xPreview.x.Value = Maneuver.xPreview.x.Value+5; 

% For testing Pure Pursuit
%Driver.Lateral.Pursuit.nWeightHeadingErr.Value = 2;
%Driver.Lateral.class.Value = 'Pure_Pursuit'

% Simulate model
sim('sm_car');

% Plot Results
sm_car_plot3maneuver(Maneuver,logsout_sm_car);
