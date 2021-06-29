% Script to test four wheel steering in sedan 
% Manuever is simple step steer.

% Copyright 2019-2021 The MathWorks, Inc

% Test four wheel steering
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','185');  % Ideal powertrain

% Set up maneuver
sm_car_config_maneuver('sm_car','Turn');
set_param('sm_car','StopTime','25');
Maneuver.Accel.rPedal.Value(5:6) = 0.25;
Maneuver.Brake.rPedal.Value  = Maneuver.Brake.rPedal.Value*0;

% Enable four-wheel steering
Control.Default.Steer.steer_ratio_axle2 = -1;

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
results_xCar_4ws_on = logsout_VehBus.Values.World.x;
results_yCar_4ws_on = logsout_VehBus.Values.World.y;

% Clear results from first test
clear simlog_sm_car logsout_sm_car out

% Disable four-wheel steering
Control.Default.Steer.steer_ratio_axle2 = 0;
out = sim('sm_car');
set_param('sm_car','FastRestart','off','ReturnWorkspaceOutputs','off');
warning('on','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');

% Process outputs
simlog_sm_car = out.get('simlog_sm_car');
logsout_sm_car = out.get('logsout_sm_car');
sm_car_plot1speed;
logsout_VehBus = logsout_sm_car.get('VehBus');
unreal_timeseries_compare = logsout_sm_car.get('Unreal_Timeseries');
results_xCar_4ws_off = logsout_VehBus.Values.World.x;
results_yCar_4ws_off = logsout_VehBus.Values.World.y;

% Compare results
figure(99)
plot(results_xCar_4ws_on.Data, results_yCar_4ws_on.Data, 'LineWidth', 1,'DisplayName','Four Wheel Steering On');
hold on
plot(results_xCar_4ws_off.Data, results_yCar_4ws_off.Data, '--', 'LineWidth', 1,'DisplayName','Four Wheel Steering Off');
hold off
legend('Location','Best');
axis equal
grid on
title('Position')
ylabel('Position (m)')
xlabel('Position (m)')

