function control_param = sm_car_controlparam_default
%% Scene parameters
% Copyright 2018-2024 The MathWorks, Inc.

control_param.Name = 'Default';

control_param.maxTrqRequest        = 1600;
control_param.pcnt_torque_on_f     = 0.5;

% Parameters for rear-axle steering algorithm
% Speed-dependent gain for steer command
str_gain_pts       = [0   -0.3000   -0.3000   -0.2000    0.3000    0.3000         0         0];
veh_spd_kmh_pts    = [0    5.0000   10.0000   25.0000   50.0000   70.0000   95.0000  180.0000];
veh_spd_kmh_interp = [linspace(0,100,20) 180];
str_gain_vec       = interp1(veh_spd_kmh_pts,str_gain_pts,veh_spd_kmh_interp,'pchip');

control_param.Steer.Gain.vVehicle.Value = veh_spd_kmh_interp;
control_param.Steer.Gain.vVehicle.Units = 'km/h';
control_param.Steer.Gain.n.Value        = str_gain_vec;
control_param.Steer.Gain.nRearAct.Value    = 0;  % Disabled if = 0

% Limits for rear steering
control_param.Steer.Limits.aUpper.Value   = 10*(pi/180);
control_param.Steer.Limits.aUpper.Units   = 'rad';
control_param.Steer.Limits.aLower.Value   = -10*(pi/180);
control_param.Steer.Limits.aUpper.Units   = 'rad';

% Variable Steer Ratio Lookup Table (as used in Steer-by-Wire)
aWheel = [-180	-162	-144	-126	-108	-90	-72	-54	-36	-18		0   18	36	54	72	90	108	126	144	162	180]*pi/180; % rad
xRack  = [-0.3	-0.273	-0.2436	-0.2112	-0.1778	-0.1462	-0.1178	-0.0912	-0.0636	-0.033	0	0.033	0.0636	0.0912	0.1178	0.1463	0.1778	0.2112	0.2436	0.273	0.3]; % m

control_param.Steer.Ratio_Table.aWheel.Value   = aWheel;
control_param.Steer.Ratio_Table.aWheel.Units   = 'rad';
control_param.Steer.Ratio_Table.aWheel.Comment = 'Steer By Wire';

control_param.Steer.Ratio_Table.xRack.Value    = xRack;  
control_param.Steer.Ratio_Table.xRack.Units    = 'm';
control_param.Steer.Ratio_Table.xRack.Comment  = 'Steer By Wire, Ratio';

% Speed Dependent Gain for Steer Ratio (as used in Steer-by-Wire)
control_param.Steer.Ratio_Scale.vVehicle.Value   = [0 3 20 100 150 200]/3.6/4;
control_param.Steer.Ratio_Scale.vVehicle.Units   = 'm/s';
control_param.Steer.Ratio_Scale.vVehicle.Comment = 'Steer By Wire';

control_param.Steer.Ratio_Scale.n.Value          = [1.05 1.05 1 1 0.8 0.8];  % Ensure no NaN
control_param.Steer.Ratio_Scale.n.Units          = '1';
control_param.Steer.Ratio_Scale.n.Comment        = 'Steer By Wire, Ratio Scale';

% Steering Actuator filter constant
control_param.Steer.fActuatorCutoff.Value = 50;
control_param.Steer.fActuatorCutoff.Units = 'Hz';
control_param.Steer.fActuatorCutoff.Comment = '';

% For 3 axle vehicles - placeholder variables
control_param.Steer.steer_ratio_axle2 = 0;
control_param.Steer.steer_ratio_axle3 = 0;
