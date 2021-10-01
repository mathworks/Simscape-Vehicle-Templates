function control_param = sm_car_controlparam_default
%% Scene parameters
% Copyright 2018-2021 The MathWorks, Inc.

control_param.Name = 'Default';

control_param.maxTrqRequest        = 1600;
control_param.pcnt_torque_on_f     = 0.5;
control_param.Steer.steer_ratio_axle2 = 0;
control_param.Steer.steer_ratio_axle3 = 0;
