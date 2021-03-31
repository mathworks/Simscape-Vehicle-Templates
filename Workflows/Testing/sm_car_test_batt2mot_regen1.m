% Script to test serial regenerative braking algorithm
% in sedan with powertrain that has battery and 2 motors.
% Manuever is simple acceleration and deceleration.

% Copyright 2019-2021 The MathWorks, Inc

% Open model and configure vehicle
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','179');

% Load default maneuver
sm_car_config_maneuver('sm_car','WOT Braking')

% -- Adjust maneuver to show torque blending
%    Achieve higher speed to show torque limit of motor
% Accelerate for longer
Maneuver.Accel.t.Value(4:5)      = [14 14.2];
% Boost request to 1.5 since there are two motors
Maneuver.Accel.rPedal.Value(3:4) = [0.8 0.8];

% Start braking later
Maneuver.Brake.t.Value(2:3)      = [15 15.2];
% Lower braking request so more regenerative braking can be used
Maneuver.Brake.rPedal.Value(3:4) = [0.5 0.5];

% Run simulation, show plot
sim('sm_car');
sm_car_plot8regen(logsout_sm_car)