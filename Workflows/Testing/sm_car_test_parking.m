% Script to test parking maneuvers in sedan 
%
% The driver models can be configured to combine closed-loop and open-loop
% driver commands.  The script below conducts parking maneuvers involving
% open-loop commands to the steering wheel and closed-loop commands to the
% accelerator pedal.  The rack force is plotted for each of the three tests
% (driving forward, standing still, driving in reverse).
%
% Copyright 2025 The MathWorks, Inc

% Load vehicle
open_system('sm_car');
sm_car_load_vehicle_data('sm_car','189')

%% Perform test at -7 km/hr
% Load constant speed maneuver (closed-loop control)
sm_car_config_maneuver('sm_car','Straight Constant Speed');
sm_car_config_road('sm_car','Plane Grid');
set_param([bdroot '/Check'],'start_check_time','1000');

% Limit speed to -7 km/hr
Maneuver.Trajectory.vx.Value = max(-Maneuver.Trajectory.vx.Value,-2);

% For low-speed tests, set off-trajectory speed limit to 0
Maneuver.vMinTarget.Value = 0;

% Disable off-trajectory speed limit
Maneuver.xMaxLat.Value = 1000;

% Set initial conditions for reverse
Init.Chassis.vChassis.Value(1) = -2;
Init.Axle1.nWheel.Value       = Init.Axle1.nWheel.Value.*[-2 -2 1];
Init.Axle2.nWheel.Value       = Init.Axle2.nWheel.Value.*[-2 -2 1];

Init.Chassis.sChassis.Value(1) = 35;

% Set Steering Wheel Input to be open loop
set_param('sm_car/Driver/Closed Loop/Driver Override','popup_driver_override','Override');

Maneuver.TStart.aSteer.Value = 0;   % Use open-loop commands for steering
Maneuver.TStart.rBrake.Value = 12;   % Use open-loop commands for brake
Maneuver.TStart.rAccel.Value = 12;  % Use closed-loop commands for accel

% Steering command
Maneuver.Steer.t.Value      = [0 4 6 10 12 200];
Maneuver.Steer.aWheel.Value = [0 0 1 -1  0   0]*-0.4363;
Maneuver.Brake.t.Value      = [0 4 6 12 14 200];
Maneuver.Brake.rPedal.Value = [0 0 0  0  1   1]*0.5;

% Accel and brake commands - need to be defined, but are not used
Maneuver.Accel.t.Value      = [0 4 6 10 14 200];
Maneuver.Accel.rPedal.Value = [0 0 0  0  0   0];

% Simulate model
set_param('sm_car','StopTime','14');
sim('sm_car');

% Plot 
figure(11)
ahv(1) = subplot(211);
sm_car_sim_res_plot('time','vVeh',ahv(1));
vVehRev  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'vVeh');
timeRev  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
title('Parking Maneuver, Reverse')
ahv(2) = subplot(212);
sm_car_sim_res_plot('time','fRack',ahv(2));
fRackRev = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'fRack');

%% Parking Maneuver, Standing Still
sm_car_config_maneuver('sm_car','None');
set_param([bdroot '/Check'],'start_check_time','1000');

Init.Chassis.vChassis.Value(1) = 0;
Init.Axle1.nWheel.Value       = Init.Axle1.nWheel.Value.*[0 0 1];
Init.Axle2.nWheel.Value       = Init.Axle2.nWheel.Value.*[0 0 1];

Maneuver.Accel.t.Value      = [0 4 6 10 12 200];
Maneuver.Accel.rPedal.Value = [1 1 1  1  1   1]*0;
Maneuver.Steer.t.Value      = [0 4 6 10 12 200];
Maneuver.Steer.aWheel.Value = [0 0 1 -1  0   0]*0.4363;

% Simulate model
set_param('sm_car','StopTime','14');
sim('sm_car');

figure(12)
ahs(1) = subplot(211);
sm_car_sim_res_plot('time','vVeh',ahs(1));
vVehPark  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'vVeh');
timePark  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
title('Parking Maneuver, Standing Still')

ahs(2) = subplot(212);
sm_car_sim_res_plot('time','fRack',ahs(2));
fRackPark  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'fRack');

%% Perform test at +7 km/hr 
% Load constant speed maneuver (closed-loop control)
sm_car_config_maneuver('sm_car','Straight Constant Speed');
set_param([bdroot '/Check'],'start_check_time','1000');
Driver.Long.Kp.Value = 0.6250/2;
Driver.Long.Ki.Value = 0.0098;


% Limit speed to 7 km/hr
Maneuver.Trajectory.vx.Value = min(Maneuver.Trajectory.vx.Value,2);

% For low-speed tests, set off-trajectory speed limit to 0
Maneuver.vMinTarget.Value = 0;

% Disable off-trajectory speed limit
Maneuver.xMaxLat.Value = 1000;

% If tire radius has been adjusted, you may need to adjust initial height of chassis
Init.Chassis.sChassis.Value(3) = Init.Chassis.sChassis.Value(3)+0;
Init.Chassis.vChassis.Value(1) = 0;
Init.Axle1.nWheel.Value       = Init.Axle1.nWheel.Value.*[0 0 1];
Init.Axle2.nWheel.Value       = Init.Axle2.nWheel.Value.*[0 0 1];

% Set Steering Wheel Input to be open loop
set_param('sm_car/Driver/Closed Loop/Driver Override','popup_driver_override','Override');

Maneuver.TStart.aSteer.Value = 0;     % Use open-loop commands for steering
Maneuver.TStart.rAccel.Value = 0;     % Use closed-loop commands for accel
Maneuver.TStart.rBrake.Value = 1000;  % Use closed-loop commands for brake

% Steering command
Maneuver.Steer.t.Value      = [0 1 3 7 8.7 10 200];
Maneuver.Steer.aWheel.Value = [0 0 1 1 -1  0   0]*0.6;

% Accel and brake commands - need to be defined, but are not used
Maneuver.Accel.t.Value      = [0 4 6 10 12 200];
Maneuver.Accel.rPedal.Value = [0 0 1  1  1   1]*0.1;
Maneuver.Brake.t.Value      = [0 4 6 10 12 200];
Maneuver.Brake.rPedal.Value = [1 1 1  1  1   1]*0;

% Simulate model
set_param('sm_car','StopTime','14');
sim('sm_car');

% Plot 
figure(10)
ahv(1) = subplot(211);
sm_car_sim_res_plot('time','vVeh',ahv(1));
vVehFwd  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'vVeh');
timeFwd  = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'time');
title('Parking Maneuver, Forwards')
ahv(2) = subplot(212);
sm_car_sim_res_plot('time','fRack',ahv(2));
fRackFwd = sm_car_sim_res_get(logsout_sm_car,simlog_sm_car,Vehicle,'fRack');

linkaxes(ahv,'x')

%% Compare results
figure(99)
ah(1) = subplot(211);
plot(timeRev.data, vVehRev.data,'LineWidth', 1,'DisplayName','Reverse');
hold on
plot(timePark.data, vVehPark.data,'LineWidth', 1,'DisplayName','Park');
plot(timeFwd.data, vVehFwd.data,'LineWidth', 1,'DisplayName','Forward');
hold off

legend('Location','Best');
grid on
title('Parking Maneuver')
ylabel('Vehicle Speed (m/s)')

ah(2) = subplot(212);
plot(timeRev.data, fRackRev.data,'LineWidth', 1,'DisplayName','Reverse');
hold on
plot(timePark.data, fRackPark.data,'LineWidth', 1,'DisplayName','Park');
plot(timeFwd.data, fRackFwd.data,'LineWidth', 1,'DisplayName','Forward');
hold off
grid on
title('Rack Actuation Force')
ylabel('Rack Force (N)')
xlabel('Time (sec)')

linkaxes(ah,'x')