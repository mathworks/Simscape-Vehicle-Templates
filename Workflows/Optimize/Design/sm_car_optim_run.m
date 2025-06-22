function [xFinal,fval,CarMetricsFinal] = sm_car_optim_run(mdl,Vehicle,par_list,metricName,tgtValue,metricWeights)
%sm_car_optim_dlc  Example to tune suspension hardpoints to minimize target metrics
%   This function permits the user to tune any number of hardpoint
%   coordinates to achieve a set of target performance metrics. Before the
%   function is called, it should be configured with the desired suspension
%   and set of hardpoints to tune.
%
%      mdl           Simulink model name
%      Vehicle       Vehicle data structure used by model, contains hardpoints
%      par_list       Structure defining hardpoints to tune
%           .path2Val   String defining path to value in Vehicle data structure
%                       Example: 'Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value(3)';
%           .valueSets  Vector defining range (first element min, last element max)
%      metricName    Target metrics for optimization (list as cell array)
%      tgtValue      Target value for metrics (vector, same length as metricName) 
%      metricWeights Weights for cost function (vector, same length as metricName) 
%
%   Outputs
%      xFinal             Vector with list of optimal hardpoint coordinates
%      fval               Optimized value of performance metrics
%      CarMetricsFinal  Metrics obtained with optimized parameters
%
% Copyright 2020-2024 The MathWorks, Inc.

%% Obtain and display default level of target metric
open_system(mdl);
set_param(mdl,'FastRestart','on');
out = sim(mdl);

disp('Metrics with Initial Set of Parameter Values')
CarMetricsStart = sm_car_perf_metrics(out.logsout_sm_car,false,true,false);
for mni = 1:length(metricName)
    metric_i(mni)  = find(strcmp(CarMetricsStart.Names,metricName{mni}));
end
CarMetricsStart(metric_i,:)

% Plot one value from simulation results to track progres
simResStr = 'aRoll';
simRes = sm_car_sim_res_get(out.logsout_sm_car,out.simlog_sm_car,Vehicle,simResStr);
time   = sm_car_sim_res_get(out.logsout_sm_car,out.simlog_sm_car,Vehicle,'time');
figure
plot(time.data, simRes.data, 'k', 'LineWidth', 3)
grid on
title(simRes.name)
ylabel([simRes.name ' (' simRes.units ')'])
xlabel('Time (sec)')
hold on

% Hold plot during optimization
fig_h = gca;

%% Set up optimization
% Load initial values and limits
for par_i = 1:length(par_list)
    % Variable initial values
    path2Val   = par_list(par_i).path2Val;
    x0(par_i) = eval(path2Val);

    % Upper and lower limits for hardpoint coordinates
    UB(par_i) = par_list(par_i).valueSet(end);
    LB(par_i) = par_list(par_i).valueSet(1);
end

% For debugging
assignin("base",'x0',x0);

%% Run optimization

% Record start time for optimization
tOptStart = tic;

% Use patternsearch
options = optimoptions('patternsearch','PollMethod','GSSPositiveBasis2N', ...
    'Display','iter','PlotFcn', @psplotbestf,'MaxIterations',40, ...
    'MeshTolerance',1e-3,'UseCompletePoll',true,'InitialMeshSize',min((UB-LB)/2), ...
    'MeshContractionFactor',0.25);

[x,fval,~,~] = ...
    patternsearch(@(x)obj_car_optim(x, mdl,par_list,Vehicle,metricName,tgtValue,metricWeights,simResStr,fig_h),...
    x0,[],[],[],[],LB,UB,[],options);

% Use fmincon
%{
options = optimoptions('fmincon','Display','iter');
[x,fval,~,~] = ...
    fmincon(@(x)obj_bump_steer(x, mdl,par_list,Vehicle,metricName,tgtValue,metricWeights,simResStr,fig_h),...
    x0,[],[],[],[],LB,UB,[],options);
%}

% Record duration of optimization
tOptDuration = toc(tOptStart);
disp(['Elapsed time for optimization = ' num2str(tOptDuration)]);

% Return final sets of values
xFinal = x;

% Load final set of values into structure in workspace
for par_i=1:length(par_list)
    eval([par_list(par_i).path2Val ' = ' num2str(xFinal(par_i)) ';']);
end
assignin('base','Vehicle',Vehicle)
assignin('base','xFinal',xFinal)

% Calculate, display, and return optimized performance metrics
out = sim(mdl);
set_param(mdl,'FastRestart','off')

disp(' ');
disp('Metrics with Optimized Set of Parameter Values')
CarMetricsFinal = sm_car_perf_metrics(out.logsout_sm_car,false,true,false);

for mni = 1:length(metricName)
    metric_i(mni)  = find(strcmp(CarMetricsFinal.Names,metricName{mni}));
    FinalValues(mni) = CarMetricsFinal.Values(metric_i(mni));
end
FinalValues = FinalValues';

CarMetricsSummary = CarMetricsStart(metric_i,:);
CarMetricsSummary = renamevars(CarMetricsSummary,"Values","StartValue");
CarMetricsSummary = addvars(CarMetricsSummary,FinalValues,'After',"StartValue"); 
CarMetricsSummary = addvars(CarMetricsSummary,tgtValue,'After','FinalValues') 

paramStruct.Initial = x0';
paramStruct.Final   = xFinal';

paramSummary = struct2table(paramStruct)




