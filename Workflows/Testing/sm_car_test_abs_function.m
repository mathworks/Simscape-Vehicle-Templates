function out_abs_test = sm_car_test_abs_function(test_vehicle_platform)
% Run ABS test on Ice Patch scene.
% 
% test_vehicle_platform:    "Hamba" or "HambaLG"
%
% 1. Run without ABS controller until just before ice patch
% 2. Create an operating point at the end of that run
% 3. Enable ABS controller
% 4. Start test run from operating point
%    with open-loop inputs shifted accordingly.
%
% Copyright 2019-2020 The MathWorks, Inc.

if (strcmpi(test_vehicle_platform,'hamba'))
    % Run test with Hamba
    veh_index = '156';
elseif (strcmpi(test_vehicle_platform,'hambalg'))
    % Run test with HambaLG
    veh_index = '130';
end

open_system('sm_car')

%% Set up model to get operating point
set_param('sm_car','SimMechanicsUnsatisfiedHighPriorityTargets','Error')
set_param('sm_car','SimscapeUseOperatingPoints','off')
sm_car_load_vehicle_data('sm_car',veh_index)
sm_car_config_maneuver('sm_car','Ice Patch');
sm_car_config_control_brake('sm_car',0)
sm_car_config_vehicle('sm_car')
out = sim('sm_car','StopTime','10.75');

%% Check time before you hit ice patch

%% Create op point
ABS_Event_Start_t = 10.5;
simlog_sm_car = out.simlog_sm_car;
ssc_op = simscape.op.create(simlog_sm_car,ABS_Event_Start_t);
assignin('base','ssc_op',ssc_op)

% Adjust brake start time to accommodate operating point
Maneuver = evalin('base','Maneuver');
Maneuver.Brake.t.Value = max(Maneuver.Brake.t.Value-ABS_Event_Start_t,0);
assignin('base','Maneuver',Maneuver)

%% Configure model for ABS Test
%  Many variable targets will be missed, so disable warnings and errors
set_param('sm_car','SimMechanicsUnsatisfiedHighPriorityTargets','none')
%  Many variable targets will be missed, so warn only
set_param('sm_car','SimscapeUseOperatingPoints','on')
%  Turn ABS controller on
sm_car_config_control_brake('sm_car',1)

% Change Stop time check, as event may be short
stop_sys = ['sm_car/Check'];
stop_thresh = get_param(stop_sys,'stop_speed');
set_param(stop_sys, 'start_check_time','1');

%% Run model
out_abs_test = sim('sm_car','StopTime','20');

%% Return model to original condition
set_param('sm_car','SimMechanicsUnsatisfiedHighPriorityTargets','error')
set_param('sm_car','SimscapeUseOperatingPoints','off')
sm_car_config_control_brake('sm_car',0)
set_param(stop_sys, 'start_check_time','5');


    