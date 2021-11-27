% Script to test four wheel steering in sedan 
% Manuever is simple step steer.

% Copyright 2019-2021 The MathWorks, Inc

% Test four wheel steering
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','185');  % Ideal powertrain

% Set up maneuver
sm_car_config_maneuver('sm_car','Turn');
set_param('sm_car','StopTime','50');
Maneuver.Accel.rPedal.Value = [0 0 0.1 0.1 0.1 0.1];
Maneuver.Steer.aWheel.Value = abs(Maneuver.Steer.aWheel.Value);
Maneuver.Brake.rPedal.Value  = Maneuver.Brake.rPedal.Value*0;

% Disable four-wheel steering
temp_strGain = Control.Default.Steer.Gain.n.Value;
Control.Default.Steer.Gain.n.Value = temp_strGain*0;

% Run test 
set_param('sm_car','FastRestart','on','ReturnWorkspaceOutputs','on');
warning('off','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');
out = sim('sm_car');
simlog_sm_car = out.get('simlog_sm_car');
logsout_sm_car = out.get('logsout_sm_car');
sm_car_plot1speed;

% Save results
logsout_VehBus = logsout_sm_car.get('VehBus');
unreal_timeseries = logsout_sm_car.get('Unreal_Timeseries');
results_xCar_4ws_off = logsout_VehBus.Values.World.x.Data;
results_yCar_4ws_off = logsout_VehBus.Values.World.y.Data;
results_time_4ws_off = logsout_VehBus.Values.World.nYaw.Time;
results_nYaw_4ws_off = logsout_VehBus.Values.World.nYaw.Data;
results_vx_4ws_off = logsout_VehBus.Values.Chassis.Body.CG.vx.Data;

% Clear results from first test
clear simlog_sm_car logsout_sm_car out

% Re-enable four wheel steering
Control.Default.Steer.Gain.n.Value = temp_strGain;

% Rerun simulation
out = sim('sm_car');
set_param('sm_car','FastRestart','off','ReturnWorkspaceOutputs','off');
warning('on','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');

% Process outputs
simlog_sm_car = out.get('simlog_sm_car');
logsout_sm_car = out.get('logsout_sm_car');
sm_car_plot1speed;
logsout_VehBus = logsout_sm_car.get('VehBus');
unreal_timeseries_compare = logsout_sm_car.get('Unreal_Timeseries');
results_xCar_4ws_on = logsout_VehBus.Values.World.x.Data;
results_yCar_4ws_on = logsout_VehBus.Values.World.y.Data;
results_time_4ws_on = logsout_VehBus.Values.World.nYaw.Time;
results_nYaw_4ws_on = logsout_VehBus.Values.World.nYaw.Data;
results_vx_4ws_on = logsout_VehBus.Values.Chassis.Body.CG.vx.Data;

% Compare results
figure(99)
subplot(221)
plot(Maneuver.Steer.t.Value, Maneuver.Steer.aWheel.Value,'k','LineWidth', 1);
legend('Location','Best');
grid on
title('Steering Wheel Angle')
ylabel('Angle (rad)')
xlabel('Time (sec)')
set(gca,'XLim',[0 results_time_4ws_off(end)])

subplot(222)
plot(squeeze(results_time_4ws_on), squeeze(results_vx_4ws_on), 'LineWidth', 1,'DisplayName','Four Wheel Steering On');
hold on
plot(squeeze(results_time_4ws_off), squeeze(results_vx_4ws_off), '--', 'LineWidth', 1,'DisplayName','Four Wheel Steering Off');
hold off
legend('Location','Best');
grid on
title('Vehicle Speed')
ylabel('Speed (m/s)')
xlabel('Time (sec)')

subplot(223)
plot(squeeze(results_time_4ws_on), squeeze(results_nYaw_4ws_on), 'LineWidth', 1,'DisplayName','Four Wheel Steering On');
hold on
plot(squeeze(results_time_4ws_off), squeeze(results_nYaw_4ws_off), '--', 'LineWidth', 1,'DisplayName','Four Wheel Steering Off');
hold off
legend('Location','Best');
grid on
title('Yaw Rate')
ylabel('Yaw Rate (rad/s)')
xlabel('Time (Sec)')

% Compare results
subplot(224)
plot(squeeze(results_xCar_4ws_on), squeeze(results_yCar_4ws_on), 'LineWidth', 1,'DisplayName','Four Wheel Steering On');
hold on
plot(squeeze(results_xCar_4ws_off), squeeze(results_yCar_4ws_off), '--', 'LineWidth', 1,'DisplayName','Four Wheel Steering Off');
hold off
legend('Location','Best');
axis equal
grid on
title('Position')
ylabel('Position (m)')
xlabel('Position (m)')

