% Exercise 3: Plot results of second test
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
aRoll_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.aRoll;
plot(aRoll_runA.Time, aRoll_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aRoll')
hold on
plot(aRoll_runB.Time, aRoll_runB.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aRoll')
hold off
legend
title('Vehicle Body Roll');
xlabel('Time');

subplot(224)
nRoll_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nRoll;
plot(nRoll_runA.Time, nRoll_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.nRoll')
hold on
plot(nRoll_runB.Time, nRoll_runB.Data(:),'DisplayName','VehBus.Chassis.Body.CG.nRoll')
hold off
legend
title('Vehicle Body Roll Rate');
xlabel('Time');

