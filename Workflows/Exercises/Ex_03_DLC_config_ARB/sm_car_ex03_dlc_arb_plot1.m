% Exercise 3: Plot results of first test
% Copyright 2021 The MathWorks, Inc.

subplot(221)
vx_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vx;
plot(vx_runA.Time, vx_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
legend
title('Vehicle Body Speed');

subplot(222)
aStrWhl_runA = logsout_sm_car.get('DrvBus').Values.aSteerWheel;
plot(aStrWhl_runA.Time, aStrWhl_runA.Data,'DisplayName','DrvBus.aSteerWheel')
legend
title('Steering Wheel Command');

subplot(223)
aRoll_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.aRoll;
plot(aRoll_runA.Time, aRoll_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aRoll')
legend
title('Vehicle Body Roll');
xlabel('Time');

subplot(224)
nRoll_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nRoll;
plot(nRoll_runA.Time, nRoll_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.nRoll')
legend
title('Vehicle Body Roll Rate');
xlabel('Time');

