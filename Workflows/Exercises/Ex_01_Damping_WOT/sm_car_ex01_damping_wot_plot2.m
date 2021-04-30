% Exercise 1: Plot results of second test
% Copyright 2021 The MathWorks, Inc.

subplot(221)
vx_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vx;
plot(vx_runA.Time, vx_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
hold on
plot(vx_runB.Time, vx_runB.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
hold off
legend
title('Vehicle Body Pitch');

subplot(222)
vz_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vz;
plot(vz_runA.Time, vz_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vz')
hold on
plot(vz_runB.Time, vz_runB.Data,'DisplayName','VehBus.Chassis.Body.CG.vz')
hold off
legend
title('Vehicle Body Height');

subplot(223)
aPitch_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.aPitch;
plot(aPitch_runA.Time, aPitch_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aPitch')
hold on
plot(aPitch_runB.Time, aPitch_runB.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aPitch')
hold off
legend
title('Vehicle Body Pitch');
xlabel('Time');

subplot(224)
nPitch_runB = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nPitch;
plot(nPitch_runA.Time, nPitch_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.nPitch')
hold on
plot(nPitch_runB.Time, nPitch_runB.Data(:),'DisplayName','VehBus.Chassis.Body.CG.nPitch')
hold off
legend
title('Vehicle Body Pitch Rate');
xlabel('Time');

