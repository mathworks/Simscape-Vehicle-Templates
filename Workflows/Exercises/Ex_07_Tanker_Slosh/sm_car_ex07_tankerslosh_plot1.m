% Exercise 7: Plot results of first test
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
aRollV_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.aRoll;
plot(aRollV_runA.Time, aRollV_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aRoll')
legend
title('Vehicle Body Roll');
xlabel('Time');

subplot(224)
aRollT_runA = logsout_sm_car.get('TrlBus').Values.Chassis.Body.CG.aRoll;
plot(aRollT_runA.Time, aRollT_runA.Data(:),'DisplayName','TrlBus.Chassis.Body.CG.aRoll')
legend
title('Trailer Body Roll');
xlabel('Time');

