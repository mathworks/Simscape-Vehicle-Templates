function control_param = sm_car_controlparam_Ideal_L1_R1_L2_R2_default
%% Scene parameters
% Copyright 2018-2021 The MathWorks, Inc.

control_param.Name = 'Ideal_L1_R1_L2_R2_default';
control_param.trq_ratio_front = 0.5;

% Copy motor lookup tables exactly
VDatabase = evalin('base','VDatabase');
control_param.MotorL2 = VDatabase.Power.Electric_A1_A2_default.MotorA1;
control_param.MotorR2 = VDatabase.Power.Electric_A1_A2_default.MotorA2;


