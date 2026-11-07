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
if ~exist('h5_testrig_AirOilPiston', 'var') || ...
        ~isgraphics(h5_testrig_AirOilPiston, 'figure')
    h5_testrig_AirOilPiston = figure('Name', 'Volumes');
end
figure(h5_testrig_AirOilPiston)
clf(h5_testrig_AirOilPiston)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_Spring = logsout_testrig_AirOilPiston.get('L1');
logsout_Time      = squeeze(logsout_Spring.Values.xSpring.Time);
logsout_xSpring   = squeeze(logsout_Spring.Values.xSpring.Data);

logsout_Ctrl   = logsout_testrig_AirOilPiston.get('Ctrl');
logsout_xInput = squeeze(logsout_testrig_AirOilPiston.get('xInput').Values.Data);

simlog_pStrut  = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Strut.p_I.series.values('MPa'); 

%logsout_xSoftSpring  = squeeze(logsout_Spring.Values.GasSprSoft.x.Data);
%logsout_xStiffSpring = squeeze(logsout_Spring.Values.GasSprStiff.x.Data);

% Plot results
simlog_handles(1) = subplot(2, 1, 1);
plot(logsout_Time, logsout_xInput, 'LineWidth', 1,'DisplayName','Input')
hold on
plot(logsout_Time, logsout_xSpring, 'LineWidth', 1,'DisplayName','Spring')
hold off
grid on
title('Deflection, Spring-Damper')
ylabel('Deflection (m)')
xlabel('Time (s)')
legend('Location','Best')

simlog_handles(2) = subplot(2, 1, 2);

timeInd10s = find(logsout_Time>=10,1);
plot(logsout_xSpring(timeInd10s:end), simlog_pStrut(timeInd10s:end), 'LineWidth', 1,'DisplayName','Input')
title('Pressure vs. Displacement, Strut')
ylabel('Pressure (MPa)')
xlabel('Deflection (m)')
grid on

delvars = setdiff(who('logsout_*'),'logsout_testrig_AirOilPiston');
clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


