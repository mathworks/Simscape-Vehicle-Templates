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
if ~exist('h1_quarter_car_msd_2x', 'var') || ...
        ~isgraphics(h1_quarter_car_msd_2x, 'figure')
    h1_quarter_car_msd_2x = figure('Name', 'xSpring');
end
figure(h1_quarter_car_msd_2x)
clf(h1_quarter_car_msd_2x)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_t     = simlog_quarter_car_msd_2x.Sensor_SM.Motion_Sensor.x.series.time;
simlog_xSM   = simlog_quarter_car_msd_2x.Sensor_SM.Motion_Sensor.x.series.values;
simlog_xUSM  = simlog_quarter_car_msd_2x.Sensor_USM.Motion_Sensor.x.series.values;
simlog_xRoad = simlog_quarter_car_msd_2x.Sensor_Road.Motion_Sensor.x.series.values;

logsout_freq = logsout_quarter_car_msd_2x.get('Freq').Values;

% Plot results
if(length(logsout_freq.Data)>1)
    ah(1) = subplot(211);
end
plot(simlog_t, simlog_xSM,...
    'LineWidth', 2,'DisplayName','Sprung Mass')
hold on
plot(simlog_t, simlog_xUSM,...
    'LineWidth', 2,'DisplayName','Unsprung Mass')
plot(simlog_t, simlog_xRoad,...
    'g--','LineWidth', 1,'DisplayName','Road')
hold off
grid on
title('Quarter-Car Response')
ylabel('Height (m)')
xlabel('Time (s)')
legend('Location','Best')

if(length(logsout_freq.Data)>1)
    ah(2) = subplot(212);
    plot(logsout_freq.Time, logsout_freq.Data,'g','LineWidth', 1);
    title('Road Input Frequency')
    xlabel('Time (s)')
    ylabel('Freq (Hz)')
    grid on
    linkaxes(ah,'x')
end




% Keep logsout_* results for Offroad workshop
%delvars = setdiff(who('logsout_*'),{'logsout_quarter_car_msd_2x');
%clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


