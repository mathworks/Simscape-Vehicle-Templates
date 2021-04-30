% Exercise 1: Plot results of first test
% Copyright 2021 The MathWorks, Inc.

subplot(221)
vx_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vx;
plot(vx_runA.Time, vx_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vx')
legend
title('Vehicle Body Speed');

subplot(222)
vz_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.vz;
plot(vz_runA.Time, vz_runA.Data,'DisplayName','VehBus.Chassis.Body.CG.vz')
legend
title('Vehicle Body Height');

subplot(223)
aPitch_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.aPitch;
plot(aPitch_runA.Time, aPitch_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.aPitch')
legend
title('Vehicle Body Pitch');
xlabel('Time');

subplot(224)
nPitch_runA = logsout_sm_car.get('VehBus').Values.Chassis.Body.CG.nPitch;
plot(nPitch_runA.Time, nPitch_runA.Data(:),'DisplayName','VehBus.Chassis.Body.CG.nPitch')
legend
title('Vehicle Body Pitch Rate');
xlabel('Time');