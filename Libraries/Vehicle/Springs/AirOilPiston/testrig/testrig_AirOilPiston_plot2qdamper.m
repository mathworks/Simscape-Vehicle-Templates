% Code to plot simulation results from testrig_AirOilPiston
%% Plot Description:
%
% Plot results from damper system
%
% Copyright 2018-2024 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_testrig_AirOilPiston', 'var')
    error('logsout_testrig_AirOilPiston data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h2_testrig_AirOilPiston', 'var') || ...
        ~isgraphics(h2_testrig_AirOilPiston, 'figure')
    h2_testrig_AirOilPiston = figure('Name', 'AirSpringOilDamper');
end
figure(h2_testrig_AirOilPiston)
clf(h2_testrig_AirOilPiston)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_Spring = logsout_testrig_AirOilPiston.get('L1');
logsout_Ctrl   = logsout_testrig_AirOilPiston.get('Ctrl');
logsout_xInput = squeeze(logsout_testrig_AirOilPiston.get('xInput').Values.Data);

logsout_Time      = squeeze(logsout_Spring.Values.xSpring.Time);
logsout_xSpring   = squeeze(logsout_Spring.Values.xSpring.Data);

logsout_qmReb   = squeeze(logsout_Spring.Values.Damper.qmReb.Data);
logsout_qmComp  = squeeze(logsout_Spring.Values.Damper.qmComp.Data);
logsout_qmCVD   = squeeze(logsout_Spring.Values.Damper.qmCVD.Data);
logsout_qmOrif  = squeeze(logsout_Spring.Values.Damper.qmOrifice.Data);

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
plot(logsout_Time, logsout_xInput, 'LineWidth', 1,'DisplayName','Input')
hold on
plot(logsout_Time, logsout_xSpring+logsout_xInput, 'LineWidth', 1,'DisplayName','Sprung Mass')
hold off
grid on
title('Height, Spring-Damper')
ylabel('Height (m)')
xlabel('Time (s)')
legend('Location','Best')

simlog_handles(2) = subplot(2, 1, 2);
plot(logsout_Time, logsout_qmReb,'Color','#ff6929', 'LineWidth', 1,'DisplayName','Rebound')
hold on
plot(logsout_Time, logsout_qmComp,'Color','#77ac30', 'LineWidth', 1,'DisplayName','Compression')
plot(logsout_Time, logsout_qmCVD, 'LineWidth', 1,'DisplayName','CVD')
plot(logsout_Time, logsout_qmOrif, 'LineWidth', 1,'DisplayName','Orifice')
hold off
grid on
title('Damper Mass Flow')
ylabel('Mass Flow (kg/s)')
xlabel('Time (s)')
legend('Location','Best')

linkaxes(simlog_handles,'x')

delvars = setdiff(who('logsout_*'),'logsout_testrig_AirOilPiston');
clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


