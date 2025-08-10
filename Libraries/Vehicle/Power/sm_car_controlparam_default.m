function control_param = sm_car_controlparam_default
%% Scene parameters
% Copyright 2018-2024 The MathWorks, Inc.

control_param.Name = 'Default';

control_param.maxTrqRequest        = 1600;
control_param.pcnt_torque_on_f     = 0.5;

% Parameters for four-wheel steering algorithm
str_gain_pts       = [0   -0.3000   -0.3000   -0.2000    0.3000    0.3000         0         0];
veh_spd_kmh_pts    = [0    5.0000   10.0000   25.0000   50.0000   70.0000   95.0000  180.0000];
veh_spd_kmh_interp = [linspace(0,100,20) 180];
str_gain_vec       = interp1(veh_spd_kmh_pts,str_gain_pts,veh_spd_kmh_interp,'pchip');

control_param.Steer.Gain.vVehicle.Value = veh_spd_kmh_interp;
control_param.Steer.Gain.vVehicle.Units = 'km/h';
control_param.Steer.Gain.n.Value        = str_gain_vec;
control_param.Steer.Gain.nRearAct.Value    = 0;  % Disabled
control_param.Steer.fActuatorCutoff.Value = 50;
control_param.Steer.fActuatorCutoff.Units = 'Hz';
control_param.Steer.Limits.aUpper.Value   = 10*(pi/180);
control_param.Steer.Limits.aUpper.Units   = 'rad';
control_param.Steer.Limits.aLower.Value   = -10*(pi/180);
control_param.Steer.Limits.aUpper.Units   = 'rad';


% For 3 axle vehicles - placeholder variables
control_param.Steer.steer_ratio_axle2 = 0;
control_param.Steer.steer_ratio_axle3 = 0;
