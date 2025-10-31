function F  = obj_testrig_optim(x,mdl,par_list,Vehicle,metricName,tgtValue,metricWeights,h_toeCamber)
% obj_bump_steer Objective function to minimize a performance metric
%   This objective runs a test with the new set of parameter values
%   selected by the optimizer and calculates the performance metric.
%
%      mdl         Simulink model name
%      par_list     Structure defining hardpoints to tune
%           .path2Val   String defining path to value in Vehicle data structure
%                       Example: 'Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value(3)';
%           .valueSets  Vector defining range (first element min, last element max)
%      Vehicle     Vehicle data structure used by model, contains hardpoints
%      metricname  metric to be minimized
%      h_toeCamber Handle to figure with toe and camber curves
%
%   Outputs
%      F          Optimized value of performance metric
%
% Copyright 2020-2025 The MathWorks, Inc.

load_system(mdl);

% Overwrite tuned parameters with new values from optimizer
for hp_i = 1:length(x)
    path2Val   = par_list(hp_i).path2Val;
    % Overwrite value
    eval([path2Val ' = ' num2str(x(hp_i)) ';']);
end

% Write updated variable to workspace
assignin('base','Vehicle',Vehicle)

%% Simulate model
simOut=sim(mdl);

%% Calculate performance metrics, update plot
[TSuspMetrics, toeCurve, camCurve] = sm_car_knc_plot1toecamber(simOut.logsout_sm_car_testrig_quarter_car,false,true,false);

% Extract desired performance metric

for mni = 1:length(metricName)
    metric_i(mni) = find(strcmp(TSuspMetrics.Names,metricName{mni}));
end

metricWeights = metricWeights/sum(metricWeights);
if(isrow(metricWeights))
    metricWeights = metricWeights';
end
F = sum(abs(TSuspMetrics.Values(metric_i)-tgtValue).*metricWeights);

% Debugging
%{
xStr = sprintf('%2.3f %2.3f',x(1),x(2));
mStr = sprintf('%2.3f %2.3f',TSuspMetrics.Values(metric_i(1)),TSuspMetrics.Values(metric_i(2)));
disp(['Param Vals: ' xStr ' Metric: ' mStr ' F: ' num2str(F)]);
%}


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

