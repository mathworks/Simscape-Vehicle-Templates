function F  = obj_bump_steer(x,mdl,hp_list,Vehicle,metricName,tgtValue,h_toeCamber)
% obj_bump_steer Objective function to minimize a performance metric
%   This objective runs a test with the new set of parameter values
%   selected by the optimizer and calculates the performance metric.
%
%      mdl         Simulink model name
%      hp_list     Structure defining hardpoints to tune
%           .part        Part where hardpoint is defined  (example: 'UpperArm')
%           .point       Name of hardpoint                (example: 'sOutboard')
%           .index       Index of coordinate (1 = x, 2 = y, 3 = z)
%      Vehicle     Vehicle data structure used by model, contains hardpoints
%      metricname  metric to be minimized
%      h_toeCamber Handle to figure with toe and camber curves
%
%   Outputs
%      F          Optimized value of performance metric
%
% Copyright 2020-2024 The MathWorks, Inc.

load_system(mdl);

% Overwrite tuned parameters with new values from optimizer
for hp_i = 1:length(x)
    part_name  = hp_list(hp_i).part;
    hp_name    = hp_list(hp_i).point;
    index_val  = hp_list(hp_i).index;

    % Overwrite value
    Vehicle.Chassis.SuspA1.Linkage.(part_name).(hp_name).Value(index_val) ...
        = x(hp_i);
end

% Write updated variable to workspace
assignin('base','Vehicle',Vehicle)

%% Simulate model
simOut=sim(mdl);

%% Calculate performance metrics, update plot
[TSuspMetrics, toeCurve, camCurve] = sm_car_knc_plot1toecamber(simOut.logsout_sm_car_testrig_quarter_car,false,true,false);

% Extract desired performance metric
metric_i = find(strcmp(TSuspMetrics.Names,metricName));
F = abs(TSuspMetrics.Values(metric_i)-tgtValue);

%% Update existing plot
figure(h_toeCamber)
% Plot Camber
simlog_handles(1) = subplot(1, 2, 2);
plot(camCurve.qCam, camCurve.pzTire, 'LineWidth', 1)
grid on
title('Camber Curve')
xlabel('Camber (deg)')
hold on

% Plot Toe
simlog_handles(2) = subplot(1, 2, 1);
plot(toeCurve.qToe, toeCurve.pzTire, 'LineWidth', 1)
grid on
title('Toe Curve')
xlabel('Toe (deg)')
ylabel('Suspension Travel (m)')
hold on

