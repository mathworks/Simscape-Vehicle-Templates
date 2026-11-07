% Code to plot simulation results from testrig_AirOilPiston
%% Plot Description:
%
% Plot results from chambers
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

logsout_xSpring   = squeeze(logsout_Spring.Values.xSpring.Data);

logsout_time = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Gas_Spring_Soft.volume.series.time;
logsout_volGasSoft = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Gas_Spring_Soft.volume.series.values;
logsout_volGasStiff = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Gas_Spring_Stiff.volume.series.values;
logsout_volOilSoft = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Oil_Soft.volume.series.values;
logsout_volOilStiff = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Oil_Stiff.volume.series.values;
logsout_volOilStrut = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Strut.volume.series.values;

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
yyaxis left
plot(logsout_time, logsout_volGasStiff,'LineWidth', 1,'DisplayName','Gas, Stiff')
hold on
plot(logsout_time, logsout_volOilStiff,'LineWidth', 1,'DisplayName','Oil, Stiff')
hold off
ylabel('Volume (m^3)')
yyaxis right
plot(logsout_time, logsout_volGasSoft,'LineWidth', 1,'DisplayName','Gas, Soft')
hold on
plot(logsout_time, logsout_volOilSoft,'LineWidth', 1,'DisplayName','Oil, Soft')
plot(logsout_time, logsout_volOilStrut,'LineWidth', 1,'DisplayName','Strut')
hold off
grid on
title('Chamber Volumes')
ylabel('Volume (m^3)')
xlabel('Time (s)')
legend('Location','Best')

simlog_handles(2) = subplot(2, 1, 2);
plot(logsout_time, logsout_xInput, 'LineWidth', 1,'DisplayName','Input')
hold on
plot(logsout_time, logsout_xSpring, 'LineWidth', 1,'DisplayName','Spring')
hold off
grid on
title('Deflection, Spring-Damper')
ylabel('Deflection (m)')
xlabel('Time (s)')
legend('Location','Best')


linkaxes(simlog_handles,'x')

delvars = setdiff(who('logsout_*'),'logsout_testrig_AirOilPiston');
clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


