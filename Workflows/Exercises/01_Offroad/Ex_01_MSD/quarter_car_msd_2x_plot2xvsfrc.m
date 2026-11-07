% Code to plot simulation results from quarter_car_msd_2x
%% Plot Description:
%
% Plot results from spring system
%
% Copyright 2018-2024 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_quarter_car_msd_2x', 'var')
    error('logsout_quarter_car_msd_2x data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h2_quarter_car_msd_2x', 'var') || ...
        ~isgraphics(h2_quarter_car_msd_2x, 'figure')
    h2_quarter_car_msd_2x = figure('Name', 'xSpring');
end
figure(h2_quarter_car_msd_2x)
clf(h2_quarter_car_msd_2x)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_t     = simlog_quarter_car_msd_2x.Sensor_SM.Motion_Sensor.x.series.time;
simlog_xSM   = simlog_quarter_car_msd_2x.Sensor_SM.Motion_Sensor.x.series.values;
simlog_xUSM  = simlog_quarter_car_msd_2x.Sensor_USM.Motion_Sensor.x.series.values;
simlog_xRoad = simlog_quarter_car_msd_2x.Sensor_Road.Motion_Sensor.x.series.values;

simlog_fSp = simlog_quarter_car_msd_2x.Spring_SM.f.series.values;
simlog_xSp = simlog_quarter_car_msd_2x.Spring_SM.x.series.values;
simlog_fSM = simlog_quarter_car_msd_2x.Sprung_Mass.f.series.values;

indStart = find(simlog_t>8.5,1);

ah(1) = subplot(211);
plot(simlog_t, simlog_xSM,...
    'LineWidth', 2,'DisplayName','Sprung Mass')
hold on
plot(simlog_t, simlog_xUSM,...
    'LineWidth', 2,'DisplayName','Unsprung Mass')
plot(simlog_t, simlog_xRoad,...
    'k--','LineWidth', 1,'DisplayName','Road')
hold off
grid on
title('Quarter-Car Response')
ylabel('Height (m)')
xlabel('Time (s)')
legend('Location','Best')
grid on

ah(2) = subplot(212);
plot(simlog_xSp(indStart:end),simlog_fSM(indStart:end))
title('Suspension Force vs. Deflection')
xlabel('Deflection (m)')
ylabel('Force (N)')
grid on
