% Exercise 7: Plot results of second test
% Copyright 2021 The MathWorks, Inc.

subplot(221)
vx_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vx;
plot(vx_runA.Time, vx_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
hold on
plot(vx_runB.Time, vx_runB.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
hold off
legend
title('Vehicle Body Speed');

subplot(222)
aStrWhl_runB = logsout_sm_car.get('DrvBus').Values.aSteerWheel;
plot(aStrWhl_runA.Time, aStrWhl_runA.Data,'DisplayName','DrvBus.aSteerWheel')
hold on
plot(aStrWhl_runB.Time, aStrWhl_runB.Data,'DisplayName','DrvBus.aSteerWheel')
hold off
legend
title('Steering Wheel Command');

subplot(223)
aRollV_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.aRoll;
plot(aRollV_runA.Time, aRollV_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aRoll')
hold on
plot(aRollV_runB.Time, aRollV_runB.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aRoll')
hold off
legend
title('Vehicle Body Roll');
xlabel('Time');

subplot(224)
aRollT_runB = logsout_sm_car.get('TrlBus').Values.Chassis.Body.CG.aRoll;
plot(aRollT_runA.Time, aRollT_runA.Data(:),'DisplayName','TrlBus.Chassis.Body.CG.aRoll')
hold on
plot(aRollT_runB.Time, aRollT_runB.Data(:),'DisplayName','TrlBus.Chassis.Body.CG.aRoll')
hold off
legend
title('Trailer Body Roll');
xlabel('Time');

