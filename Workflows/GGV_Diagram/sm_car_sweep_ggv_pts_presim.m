function sm_car_sweep_ggv_pts_presim(modelName, stop_time)
%sm_car_sweep_ggv_pts_presim  PreSimFcn for GGV parameter sweep
%    Configures model for GGV test.   
%    Required to ensure model is properly configured on parallel workers.

% Copyright 2021 The MathWorks, Inc.

% Ensure correct dataset is loaded into workspace
evalin('base','Vehicle = Vehicle_GGV_Sweep;')
evalin('base','Vehicle = sm_car_vehcfg_checkConfig(Vehicle);');
bdclose('Custom_lib');

% Ensure proper stop time is set
set_param(modelName,'StopTime',num2str(stop_time));

% Test settings
% Stop when vehicle starts to slip
% Start checking after 15 seconds to ensure vehicle settles
set_param([modelName '/Check'],'start_check_time_max_speed','15','max_speed','0.4')
set_param([modelName '/Check'],'start_check_time','10000','stop_speed','0.1')

% No acceleration, hold the brakes
evalin('base','Maneuver.Accel.rPedal.Value = Maneuver.Accel.rPedal.Value*0;');
evalin('base','Maneuver.Brake.rPedal.Value = [0 1 1 1 1 1]*0.9;');

