% Script to test four wheel steering in sedan 
% Manuever is Constant Radius Closed-Loop.

% Copyright 2019-2024 The MathWorks, Inc

% Test four wheel steering
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','189');  % Rack with variable gear

% Set up maneuver
sm_car_config_maneuver('sm_car','Constant Radius Closed-Loop');

% Run test 
sim('sm_car');
sim_time_mech = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_aStr_mech = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aSteer');
sim_pxVe_mech = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pxVeh');
sim_pyVe_mech = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pyVeh');

% Enable steer-by-wire with ideal actuator
sm_car_load_vehicle_data('sm_car','233');  % Steer-by-wire ideal actuator

% Rerun test 
sim('sm_car');
sim_time_vStr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_aStr_vStr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aSteer');
sim_pxVe_vStr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pxVeh');
sim_pyVe_vStr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pyVeh');

% Enable steer-by-wire with electricak actuator
sm_car_load_vehicle_data('sm_car','234');  % Steer-by-wire ideal actuator

% Rerun test 
sim('sm_car');
sim_time_sBwr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
sim_aStr_sBwr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'aSteer');
sim_pxVe_sBwr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pxVeh');
sim_pyVe_sBwr = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'pyVeh');

% Compare results
figure(99)
subplot(121)
plot(sim_time_mech.data, sim_aStr_mech.data,'LineWidth', 1,'DisplayName','Mechanical');
hold on
plot(sim_time_vStr.data, sim_aStr_vStr.data,'LineWidth', 1,'DisplayName','Steer By Wire, Ideal');
plot(sim_time_sBwr.data, sim_aStr_sBwr.data,'LineWidth', 1,'DisplayName','Steer By Wire, Electric');
hold off
grid on
title('Steering Wheel Angle')
ylabel('Angle (rad)')
xlabel('Time (sec)')
legend('Location','Best')

subplot(122)
plot(sim_pxVe_mech.data, sim_pyVe_mech.data,'LineWidth', 1,'DisplayName','Mechanical');
hold on
plot(sim_pxVe_vStr.data, sim_pyVe_vStr.data,'LineWidth', 1,'DisplayName','Steer By Wire, Ideal');
plot(sim_pxVe_sBwr.data, sim_pyVe_sBwr.data,'LineWidth', 1,'DisplayName','Steer By Wire, Electric');
hold off
grid on
title('Vehicle Position')
ylabel('X Position (m)')
xlabel('Y Position (m)')
axis(gca,'equal')
legend('Location','Best')

