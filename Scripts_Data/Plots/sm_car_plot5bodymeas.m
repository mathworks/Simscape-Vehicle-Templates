% Code to plot simulation results from sm_car
%% Plot Description:
%
% The plot below shows body pitch and roll as the vehicle
% is exposed to a specific test profile on the four-post testrig.
%
% Copyright 2019-2020 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h5_sm_car', 'var') || ...
        ~isgraphics(h5_sm_car, 'figure')
    h5_sm_car = figure('Name', 'sm_car');
end
figure(h5_sm_car)
clf(h5_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_RdBus = logsout_sm_car.get('RdBus');
simlog_pzFL  = simlog_RdBus.Values.FL.gz.Data;
simlog_pzFR  = simlog_RdBus.Values.FR.gz.Data;
simlog_pzRL  = simlog_RdBus.Values.RL.gz.Data;
simlog_pzRR  = simlog_RdBus.Values.RR.gz.Data;

simlog_VehBus = logsout_sm_car.get('VehBus');
simlog_t      = simlog_VehBus.Values.World.aPitch.Time;
simlog_aPitch = simlog_VehBus.Values.World.aPitch.Data(:)*180/pi;
simlog_aRoll  = simlog_VehBus.Values.World.aRoll.Data(:)*180/pi;
simlog_aYaw   = simlog_VehBus.Values.World.aYaw.Data(:)*180/pi;

% Plot results
simlog_handles(1) = subplot(3, 1, 1);
plot(simlog_t, simlog_aPitch, 'LineWidth', 1)
grid on
title('Body Pitch Angle')
ylabel('Pitch (deg)')

simlog_handles(2) = subplot(3, 1, 2);
plot(simlog_t, simlog_aRoll, 'LineWidth', 1)
grid on
title('Body Roll Angle')
ylabel('Roll (deg)')

simlog_handles(3) = subplot(3, 1, 3);
if(sum([simlog_pzFL simlog_pzFR simlog_pzRL simlog_pzRR],'all')>0)
    plot(simlog_t, simlog_pzFL,'LineWidth', 2 );
    hold on
    plot(simlog_t, simlog_pzFR,'--','LineWidth', 1);
    plot(simlog_t, simlog_pzRL,'--','LineWidth', 2);
    plot(simlog_t, simlog_pzRR','-.','LineWidth', 1);
    hold off
    grid on
    title('Post Height')
    ylabel('Height (m)')
    xlabel('Time (s)')
    legend({'FL','FR','RL','RR'},'Location','Best')
else
    plot(simlog_t, simlog_aYaw,'LineWidth', 1 );
    grid on
    title('Body Yaw Angle')
    ylabel('Yaw (deg)')
    xlabel('Time (s)')
end
linkaxes(simlog_handles, 'x')

% Remove temporary variables
clear simlog_t simlog_handles temp_colororder
clear simlog_pz* simlog_aRoll simlog_aPitch simlog_aYaw
clear simlog_RdBus simlog_VehBus

