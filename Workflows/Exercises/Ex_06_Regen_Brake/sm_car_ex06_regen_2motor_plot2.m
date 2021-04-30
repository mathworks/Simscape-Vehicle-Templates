% Exercise 6: Plot results of second test
% Copyright 2021 The MathWorks, Inc.

subplot(221)
vx_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vx;
plot(vx_runA.Time, vx_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
hold on
plot(vx_runB.Time, vx_runB.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
hold off
legend('Location','Best');
title('Vehicle Body Speed');

subplot(222)
time_runB  = simlog_sm_car.Vehicle.Vehicle.Powertrain.Power.Electric_A1_A2.Motor_A1.Motor.torque_elec.series.time;
trqR1_runB = simlog_sm_car.Vehicle.Vehicle.Brakes.PressureAbstract_DiscDisc.Sensing_Torque_R1.Ideal_Torque_Sensor.T.series.values;
trqA1_runB = simlog_sm_car.Vehicle.Vehicle.Powertrain.Power.Electric_A1_A2.Motor_A1.Motor.torque_elec.series.values;
plot(time_runA, trqR1_runA,'DisplayName','Brakes R1')
hold on
plot(time_runA, trqA1_runA,'DisplayName','Motor A1')
plot(time_runB, trqR1_runB,'DisplayName','Brakes R1')
plot(time_runB, trqA1_runB,'DisplayName','Motor A1')
hold off
legend('Location','Best');
title('Torques');

subplot(223)
SOC_runB = simlog_sm_car.Vehicle.Vehicle.Powertrain.Power.Electric_A1_A2.Battery.Battery.stateOfCharge.series.values;
plot(time_runA, SOC_runA)
hold on
plot(time_runB, SOC_runB)
hold off
title('Battery State of Charge');
xlabel('Time');

subplot(224)
BattdegC_runB = simlog_sm_car.Vehicle.Vehicle.Powertrain.Power.Electric_A1_A2.Battery.Battery.temperature.series.values;
plot(time_runA, BattdegC_runA)
hold on
plot(time_runB, BattdegC_runB)
hold off
title('Battery Temperature');
xlabel('Time');
