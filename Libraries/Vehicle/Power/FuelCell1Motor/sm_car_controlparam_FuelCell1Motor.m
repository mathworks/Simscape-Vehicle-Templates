function control_param = sm_car_controlparam_FuelCell1Motor
%% Scene parameters
% Copyright 2018-2020 The MathWorks, Inc.

control_param.Name = 'FuelCell1Motor';

control_param.FuelCell.maxPWR = 128000;
control_param.FuelCell.opLimit = 0.4;
control_param.FuelCell.minV = 200;
control_param.FuelCell.SOCtgt = 60;
control_param.FuelCell.tempTgt = 80;

control_param.Power.RegenBrkCutOff = [0 1];
control_param.Power.RegenBrkSpd_bpt = [5 9];

control_param.Driver.Long.Ki = 1;
control_param.Driver.Long.Kp = 2;

% Copy motor lookup tables exactly
VDatabase = evalin('base','VDatabase');
control_param.MotorF = VDatabase.Power.FuelCell1Motor_default.MotorF;

control_param.Battery.SOC_bpt = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];
control_param.Battery.ChrgLmt_bpt = [1 1 1 1 1 1 1 1 0.7 0.35 0];
control_param.Battery.DischrgLmt_bpt = [0 0.5 0.7 0.9 1 1 1 1 1 1 1];
control_param.Battery.BattDischrgMax = 80000;
control_param.Battery.BattChrgMax = -80000;

control_param.Brakes.rMuKinetic.Value = 0.5;
control_param.Brakes.rMuStatic.Value = 0.7;
control_param.Brakes.lCylinderDiameter.Value = 0.01*5;
control_param.Brakes.lMeanRadius.Value = 0.15;
control_param.Brakes.NPads.Value = 2;

control_param.Brakes.Req = 4*(control_param.Brakes.rMuKinetic.Value*pi*...
    control_param.Brakes.lCylinderDiameter.Value^2*...
    control_param.Brakes.lMeanRadius.Value*control_param.Brakes.NPads.Value/4);

control_param.Brakes.pMax.Value = 8.2e6;
control_param.Brakes.pMax.Units = 'Pa';
control_param.Brakes.Ndiff_front = 5;

