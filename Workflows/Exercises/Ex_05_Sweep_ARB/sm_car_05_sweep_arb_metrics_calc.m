function [metrics] = sm_car_05_sweep_arb_metrics_calc(logsout_sm_car)
% Get simulation results logged in the Vehicle bus and Road bus.
vehBus = logsout_sm_car.get("VehBus");
roadBus = logsout_sm_car.get("RdBus");

% Get the three body accelerations (heave, pitch, roll) and the roll
% angle from simulation results.
gZ = vehBus.Values.World.gz.Data; %#ok<*NASGU> 
nRoll = vehBus.Values.Chassis.Body.CG.nRoll.Data(:);
nPitch = vehBus.Values.Chassis.Body.CG.nPitch.Data(:);
nRoll_t = vehBus.Values.Chassis.Body.CG.nRoll.Time(:);

gRoll = gradient(nRoll)./gradient(nRoll_t);
gPitch = gradient(nPitch)./gradient(nRoll_t);

% Get the roll angle and lateral deviation.
aRoll = vehBus.Values.Chassis.Body.CG.aRoll.Data(:);

% Get the simulation time vector and total time.
time = vehBus.Values.World.gz.Time;

% Get the wheel centre vertical positions timeseries data.
zFL = vehBus.Values.Chassis.WhlL1.xyz.Data(:,3);
zFR = vehBus.Values.Chassis.WhlR1.xyz.Data(:,3);
zRL = vehBus.Values.Chassis.WhlL2.xyz.Data(:,3);
zRR = vehBus.Values.Chassis.WhlR2.xyz.Data(:,3);

% Get the road profile values for every wheel.
roadFL = roadBus.Values.L1.gz.Data;
roadFR = roadBus.Values.R1.gz.Data;
roadRL = roadBus.Values.L2.gz.Data;
roadRR = roadBus.Values.R2.gz.Data;

% Get unloaded tyre radius.
% Handle case where tirFile field contains "which" or only filename.
file_str = evalin('base','Vehicle.Chassis.TireA1.tirFile.Value');
if(contains(file_str,'which'))
    tire_file = eval(file_str);
else
    tire_file = which(file_str);
end

temptirparams = mfeval.readTIR(tire_file);
r = temptirparams.UNLOADED_RADIUS;

% Compute max roll angle for t > 15 seconds.
metrics.maxRoll = max( abs( aRoll(time>15) ) );

% Compute ride discomfort for t < 15 seconds.
t = time < 15; % time index
T = 15;
metrics.rideDiscomfort =  1/T * trapz( time(t), ...
    sqrt(gZ(t).^2 + gRoll(t).^2 + gPitch(t).^2) );

