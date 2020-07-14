function ssc_op = sm_car_op_gen(mdl,speed,whl_radius)

% Speed    Chassis speed in m/s

% Get Current Setup
stop_sys = [mdl '/Check'];
stop_thresh = get_param(stop_sys,'stop_speed');
start_check_time = get_param(stop_sys,'start_check_time');
Init_current = evalin('base','Init');

% Set up Event
%set_param([mdl '/Steer Input'],'popup_steer_input','Straight');
%set_param([mdl '/Torque Input'],'popup_torque_input','None');
%set_param(brake_sys,'brake_on_time','100');
sm_car_config_maneuver(mdl,'None')
set_param(stop_sys,...
    'stop_speed',num2str(speed),...
    'start_check_time','5');

% Define initial condition
%veh_sys = [mdl '/Vehicle'];
%init_vveh = get_param(veh_sys,'chassis_vx0');
%set_param(veh_sys,'chassis_vx0',num2str(speed+5/3.6));

%veh_sys2 = [mdl '/VehicleNoABS'];
%init_vveh = get_param(veh_sys2,'chassis_vx0');
%set_param(veh_sys2,'chassis_vx0',num2str(speed+5/3.6));

start_speed = speed+1;

Init_internal = Init_current;
Init_internal.Chassis.vChassis.Value = [start_speed 0 0];
Init_internal.Front.nWheel.Value = [1 1]*start_speed*whl_radius; 
Init_internal.Rear.nWheel.Value = [1 1]*start_speed*whl_radius;  
%assignin('base','Init.Chassis.vChassis.Value',[speed/3.6 0 0]);
%assignin('base','Init.Front.nWheel.Value',[1 1]*speed/3.6*0.4225);
%assignin('base','Init.Rear.nWheel.Value',[1 1]*speed/3.6*0.4225);
assignin('base','Init',Init_internal);


sim(mdl)

ssc_op_all = simscape.op.create(simlog_sm_car,max(tout));

%ssc_op = remove(ssc_op_all,'Vehicle/Vehicle/Body to World');

ssc_op = remove(ssc_op_all,'Vehicle/Vehicle/Body to World/Body World Joint/Px/p');
ssc_op = remove(ssc_op,'Vehicle/Vehicle/Body to World/Body World Joint/Py/p');

%% Reset model settings
set_param(stop_sys,'stop_speed',stop_thresh,...
    'start_check_time',start_check_time);

assignin('base','Init',Init_current);
