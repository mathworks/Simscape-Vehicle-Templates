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

logsout_xSoftSpring  = squeeze(logsout_Spring.Values.GasSprSoft.x.Data);
logsout_xStiffSpring = squeeze(logsout_Spring.Values.GasSprStiff.x.Data);

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
plot(logsout_Time, logsout_xInput, 'LineWidth', 1,'DisplayName','Road')
hold on
plot(logsout_Time, logsout_xSpring+logsout_xInput, 'LineWidth', 1,'DisplayName','Sprung Mass')
hold off
grid on
title('Height')
ylabel('Height (m)')
xlabel('Time (s)')
legend('Location','Best')

simlog_handles(2) = subplot(2, 1, 2);
plot(logsout_Time, logsout_xSoftSpring,...
    'Color',temp_colororder(4,:),'LineWidth', 1,'DisplayName','Soft')
hold on
plot(logsout_Time, logsout_xStiffSpring,...
    'Color',temp_colororder(5,:),'LineWidth', 1,'DisplayName','Stiff')
hold off
grid on
title('Deflection, Gas Springs')
ylabel('Deflection (m)')
xlabel('Time (s)')
legend('Location','Best')

linkaxes(simlog_handles,'x')

% Keep logsout_* results for Offroad workshop
%delvars = setdiff(who('logsout_*'),{'logsout_testrig_AirOilPiston');
%clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


