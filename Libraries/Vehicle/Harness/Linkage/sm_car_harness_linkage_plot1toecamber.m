% Code to plot simulation results from sm_car_harness_linkage
%% Plot Description:
%
% <enter plot description here if desired>
%
% Copyright 2018-2021 The MathWorks, Inc.

% Generate simulation results if they don't exist
if ~exist('simlog_sm_car_harness_linkage', 'var')
    sim('sm_car_harness_linkage')
end

% Reuse figure if it exists, else create new figure
if ~exist('h1_sm_car_harness_linkage', 'var') || ...
        ~isgraphics(h1_sm_car_harness_linkage, 'figure')
    h1_sm_car_harness_linkage = figure('Name', 'sm_car_harness_linkage');
end
figure(h1_sm_car_harness_linkage)
clf(h1_sm_car_harness_linkage)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
simlog_pzTire = simlog_sm_car_harness_linkage.Actuator.Cartesian_Joint.Pz.p.series.values('m');

simlog_aCamber = logsout_sm_car_harness_linkage.get('aCamber');
simlog_aToe = logsout_sm_car_harness_linkage.get('aToe');

% Plot results
simlog_handles(1) = subplot(1, 2, 1);
plot(simlog_aCamber.Values.Data(:), simlog_pzTire-simlog_pzTire(1), 'LineWidth', 1)
grid on
title('Camber Curve')
ylabel('Suspension Travel (m)')
xlabel('Camber (deg)')
text(0.05,0.9,get_param([bdroot '/Linkage'],'ActiveVariant'),...
    'Units','Normalized','Color',[1 1 1]*0.5);

simlog_handles(2) = subplot(1, 2, 2);
plot(simlog_aToe.Values.Data(:), simlog_pzTire-simlog_pzTire(1), 'LineWidth', 1)
grid on
title('Toe Curve')
xlabel('Toe (deg)')

% Remove temporary variables
clear simlog_handles temp_colororder
clear simlog_aToe simlog_aCamber simlog_pzTire 

