function control_param = sm_car_controlparam_Ideal_L1_R1_L2_R2_achilles
%% Scene parameters
% Copyright 2018-2024 The MathWorks, Inc.

control_param.Name = 'Ideal_L1_R1_L2_R2_achilles';
control_param.trq_ratio_front = 0.5;

% Copy motor lookup tables exactly
Vehicle = evalin('base','Vehicle');
control_param.MotorL2 = Vehicle.Powertrain.Power.MotorL2;
control_param.MotorR2 = Vehicle.Powertrain.Power.MotorR2;

control_param.vx_enable          = 2.5; % m/s
control_param.aSteerWheel_enable = 4*pi/180; % m/s

control_param.aStr_to_aWhl       = 0.33*0.5; % ratio
control_param.max_torque_delta   = 200;   % N*m
control_param.pGain              = 4000;
control_param.iGain              = 100;
