% Code to plot simulation results from testrig_AirOilPiston
%% Plot Description:
%
% Plot results from ride height system.
%
% Copyright 2018-2024 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_testrig_AirOilPiston', 'var')
    error('logsout_testrig_AirOilPiston data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h3_testrig_AirOilPiston', 'var') || ...
        ~isgraphics(h3_testrig_AirOilPiston, 'figure')
    h3_testrig_AirOilPiston = figure('Name', 'AirSpringOilDamper');
end
figure(h3_testrig_AirOilPiston)
clf(h3_testrig_AirOilPiston)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_Spring = logsout_testrig_AirOilPiston.get('L1');
logsout_Ctrl   = logsout_testrig_AirOilPiston.get('Ctrl');
logsout_xInput = squeeze(logsout_testrig_AirOilPiston.get('xInput').Values.Data);

logsout_Time      = squeeze(logsout_Spring.Values.xSpring.Time);
logsout_xSpring   = squeeze(logsout_Spring.Values.xSpring.Data);
logsout_qmInlet   = squeeze(logsout_Spring.Values.RideHeight.qmInlet.Data);
logsout_qmOutlet  = squeeze(logsout_Spring.Values.RideHeight.qmOutlet.Data);
logsout_ctrlRHin  = logsout_Ctrl.Values.RideHeightIn;
logsout_ctrlRHout = logsout_Ctrl.Values.RideHeightOut;

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
yyaxis left
plot(logsout_Time, logsout_qmInlet, 'LineWidth', 1,'DisplayName','Inlet')
hold on
plot(logsout_Time, logsout_qmOutlet, 'LineWidth', 1,'DisplayName','Outlet')
hold off
ylabel('Mass Flow (kg/s)')

yyaxis right
plot(logsout_Time, logsout_xSpring, 'LineWidth', 1,'DisplayName','Spring')

grid on
title('Damper Mass Flow')
ylabel('Deflection (m)')
xlabel('Time (s)')
legend('Location','Best')

simlog_handles(2) = subplot(2, 1, 2);
plot(logsout_ctrlRHin.Time, logsout_ctrlRHin.Data, 'LineWidth', 1,'DisplayName','Inlet')
hold on
plot(logsout_ctrlRHout.Time, logsout_ctrlRHout.Data, 'LineWidth', 1,'DisplayName','Outlet')
hold off
grid on
title('Valve Control Signals')
ylabel('Signal')
xlabel('Time (s)')
legend('Location','Best')

linkaxes(simlog_handles,'x')

delvars = setdiff(who('logsout_*'),'logsout_testrig_AirOilPiston');
clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


