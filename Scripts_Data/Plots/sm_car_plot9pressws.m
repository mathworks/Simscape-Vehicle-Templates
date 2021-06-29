% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot hydraulic pressures from brake calipers
%
% Copyright 2016-2020 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h9_sm_car', 'var') || ...
        ~isgraphics(h9_sm_car, 'figure')
    h9_sm_car = figure('Name', 'sm_car');
end
figure(h9_sm_car)
clf(h9_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_VehBus = logsout_sm_car.get('VehBus');

logsout_pFL = logsout_VehBus.Values.Brakes.pBrakeL1;
logsout_pFR = logsout_VehBus.Values.Brakes.pBrakeR1;
logsout_pRL = logsout_VehBus.Values.Brakes.pBrakeL2;
logsout_pRR = logsout_VehBus.Values.Brakes.pBrakeR2;

simlog_wsFL = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_L.DoubleWishbone.Upright.Revolute_Bearing.Revolute.Rz.w.series.values('rad/s')*Vehicle.Chassis.TireA1.tire_radius.Value/3.6;
simlog_wsFR = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA1.Linkage.Linkage_R.DoubleWishbone.Upright.Revolute_Bearing.Revolute.Rz.w.series.values('rad/s')*Vehicle.Chassis.TireA1.tire_radius.Value/3.6;
simlog_wsRL = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA2.Linkage.Linkage_L.DoubleWishboneA.Upright.Revolute_Bearing.Revolute.Rz.w.series.values('rad/s')*Vehicle.Chassis.TireA1.tire_radius.Value/3.6;
simlog_wsRR = simlog_sm_car.Vehicle.Vehicle.Chassis.SuspA2.Linkage.Linkage_R.DoubleWishboneA.Upright.Revolute_Bearing.Revolute.Rz.w.series.values('rad/s')*Vehicle.Chassis.TireA1.tire_radius.Value/3.6;

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
plot(...
    logsout_pFL.Time, logsout_pFL.Data, logsout_pFR.Time, logsout_pFR.Data,...
    logsout_pRL.Time, logsout_pRL.Data, logsout_pRR.Time, logsout_pRR.Data,...
    'LineWidth', 1)
hold off
grid on
title('Cylinder Pressure','FontSize',12);
ylabel('Pressure (bar)');
legend({'Front Left','Front Right','Rear Left','Rear Right'},'Location','Best');

simlog_handles(2) = subplot(2, 1, 2);
plot(...
    logsout_pFL.Time, simlog_wsFL, logsout_pFR.Time, simlog_wsFR,...
    logsout_pRL.Time, simlog_wsRL, logsout_pRR.Time, simlog_wsRR,...
    'LineWidth', 1)
hold off
grid on
title('Wheel Speed','FontSize',12);
ylabel('Speed (km/hr)');
xlabel('Time (s)');

linkaxes(simlog_handles,'x')

% Remove temporary variables
clear simlog_t simlog_handles
clear temp_colororder

