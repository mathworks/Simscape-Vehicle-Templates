% Script to test torque vectoring algorithm
% in sedan for ideal or electric powertrains
% that have independent motors on the rear axle.
% Manuever is simple step steer.

% Copyright 2019-2021 The MathWorks, Inc

% Test Torque Vectoring 
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','181'); % Ideal powertrain
%sm_car_load_vehicle_data('sm_car','169');  % Electric powertrain

% Set up maneuver
sm_car_config_maneuver('sm_car','Turn');
set_param('sm_car','StopTime','25');
Maneuver.Accel.rPedal.Value(5:6) = 0.25;
Maneuver.Brake.rPedal.Value  = Maneuver.Brake.rPedal.Value*0;

% Enable Torque vectoring
set_param('sm_car/Controller','popup_control','Torque Vector 4 Motor');
set_param('sm_car/Controller/TrqVec 4Motor/Power_TqVec/Torque Vectoring','aSteerWheel_enable','4*pi/180');

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
results_xCar_TV_on = logsout_VehBus.Values.World.x;
results_yCar_TV_on = logsout_VehBus.Values.World.y;

% Clear results from first test
clear simlog_sm_car logsout_sm_car out

% Turn torque vectoring off for a test
set_param('sm_car/Controller/TrqVec 4Motor/Power_TqVec/Torque Vectoring','aSteerWheel_enable','4*pi/180*100');
out = sim('sm_car');
set_param('sm_car','FastRestart','off','ReturnWorkspaceOutputs','off');
warning('on','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');

% Turn Torque Vectoring back on
set_param('sm_car/Controller/TrqVec 4Motor/Power_TqVec/Torque Vectoring','aSteerWheel_enable','4*pi/180');

% Save results
simlog_sm_car = out.get('simlog_sm_car');
logsout_sm_car = out.get('logsout_sm_car');
sm_car_plot1speed;
logsout_VehBus = logsout_sm_car.get('VehBus');
unreal_timeseries_compare = logsout_sm_car.get('Unreal_Timeseries');
results_xCar_TV_off = logsout_VehBus.Values.World.x;
results_yCar_TV_off = logsout_VehBus.Values.World.y;

% Compare results
figure(99)
plot(results_xCar_TV_on.Data, results_yCar_TV_on.Data, 'LineWidth', 1,'DisplayName','Torque Vec On');
hold on
plot(results_xCar_TV_off.Data, results_yCar_TV_off.Data, '--', 'LineWidth', 1,'DisplayName','Torque Vec Off');
hold off
legend('Location','Best');
axis equal
grid on
title('Position')
ylabel('Position (m)')
xlabel('Position (m)')

