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
if ~exist('h6_testrig_AirOilPiston', 'var') || ...
        ~isgraphics(h6_testrig_AirOilPiston, 'figure')
    h6_testrig_AirOilPiston = figure('Name', 'p vs. x');
end
figure(h6_testrig_AirOilPiston)
clf(h6_testrig_AirOilPiston)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_t         = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Strut.volume.series.time; 
simlog_vStrut    = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Strut.volume.series.values('l'); 
simlog_vOilSoft  = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Oil_Soft.volume.series.values('l'); 
simlog_vOilStiff = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Oil_Stiff.volume.series.values('l'); 
simlog_vGasSoft  = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Gas_Spring_Soft.volume.series.values('l'); 
simlog_vGasStiff = simlog_testrig_AirOilPiston.AirOilPiston.Chamber_Gas_Spring_Stiff.volume.series.values('l'); 

% Plot results
plot(simlog_t, simlog_vStrut, 'LineWidth', 1,'DisplayName','Strut')
hold on
plot(simlog_t, simlog_vOilSoft,  'LineWidth', 1,'DisplayName','Oil Soft');
plot(simlog_t, simlog_vOilStiff, 'LineWidth', 1,'DisplayName','Oil Stiff');
plot(simlog_t, simlog_vGasSoft,  'LineWidth', 1,'DisplayName','Gas Soft');
plot(simlog_t, simlog_vGasStiff, 'LineWidth', 1,'DisplayName','Gas Stiff');
hold off
grid on
title('Chamber Volumes')
ylabel('Deflection (m)')
xlabel('Time (s)')
legend('Location','Best')

delvars = setdiff(who('simlog_*'),'simlog_testrig_AirOilPiston');
clear(delvars{:},'delvars');

clear simlog_handles temp_colororder


