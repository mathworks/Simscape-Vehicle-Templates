% Code to plot simulation results from testrig_AirOilPiston
%% Plot Description:
%
% Plot results from spring system
%
% Copyright 2018-2024 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_testrig_AirOilPiston', 'var')
    error('logsout_testrig_AirOilPiston data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_testrig_AirOilPiston', 'var') || ...
        ~isgraphics(h1_testrig_AirOilPiston, 'figure')
    h1_testrig_AirOilPiston = figure('Name', 'AirSpringOilDamper');
end
figure(h1_testrig_AirOilPiston)
clf(h1_testrig_AirOilPiston)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_Spring = logsout_testrig_AirOilPiston.get('L1');
logsout_Ctrl   = logsout_testrig_AirOilPiston.get('Ctrl');
logsout_xInput = squeeze(logsout_testrig_AirOilPiston.get('xInput').Values.Data);

logsout_Time      = squeeze(logsout_Spring.Values.xSpring.Time);
logsout_xSpring   = squeeze(logsout_Spring.Values.xSpring.Data);

logsout_freq      = logsout_testrig_AirOilPiston.get('Freq').Values.Data;

% Plot results
if(length(logsout_freq)>1)
    simlog_handles(1) = subplot(2, 1, 1);
end

plot(logsout_Time, logsout_xInput, 'LineWidth', 1,'DisplayName','Road')
hold on
plot(logsout_Time, logsout_xSpring+logsout_xInput, 'LineWidth', 1,'DisplayName','Sprung Mass')
hold off
grid on
title('Height')
ylabel('Height (m)')
xlabel('Time (s)')
legend('Location','Best')

if(length(logsout_freq)>1)
    simlog_handles(2) = subplot(2, 1, 2);
    plot(logsout_Time, logsout_freq,'k','LineWidth', 1)
    grid on
    title('Road Input Frequency')
    ylabel('Frequency (Hz)')
    xlabel('Time (s)')
    linkaxes(simlog_handles,'x')
end

% Keep logsout_* results for Offroad workshop
%delvars = setdiff(who('logsout_*'),{'logsout_testrig_AirOilPiston');
%clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


