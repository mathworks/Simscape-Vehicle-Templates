function [xFinal,fval,TSuspMetricsFinal] = testrig_quarter_car_optim_run(mdl,Vehicle,par_list,metricName,tgtValue,metricWeights,Maneuver)
%testrig_quarter_car_optim  Example to tune suspension hardpoints to minimize target metrics
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
%      TSuspMetricsFinal  Metrics obtained with optimized parameters
%
% Copyright 2020-2024 The MathWorks, Inc.

%% Obtain and display default level of target metric (such as "bump steer")
open_system(mdl)
stopTimeBzn = Maneuver.tRange.Bumpzn(2);
tempStopTime = get_param(mdl,'stopTime');
set_param(mdl,'StopTime',num2str(stopTimeBzn))
set_param(mdl,'FastRestart','on')
out = sim(mdl);

% Add short name to par_list
par_list = sm_car_param_short_name(par_list);

disp('Metrics with Initial Set of Parameter Values')
TSuspMetricsStart = sm_car_knc_plot1toecamber(out.logsout_sm_car_testrig_quarter_car,true,true,false);
for mni = 1:length(metricName)
    metric_i(mni)  = find(strcmp(TSuspMetricsStart.Names,metricName{mni}));
end
TSuspMetricsStart(metric_i,:)

% Hold plot during optimization
fig_h = gcf;
hold(fig_h.Children(1),'on');
hold(fig_h.Children(2),'on');

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
    patternsearch(@(x)obj_testrig_optim(x, mdl,par_list,Vehicle,metricName,tgtValue,metricWeights,fig_h),...
    x0,[],[],[],[],LB,UB,[],options);

% Use fmincon
%{
options = optimoptions('fmincon','Display','iter');
[x,fval,~,~] = ...
    fmincon(@(x)obj_bump_steer(x, mdl,par_list,Vehicle,metricName,tgtValue,fig_h),...
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

disp(' ');
disp('Metrics with Optimized Set of Parameter Values')
[TSuspMetricsFinal, ~, ~] = sm_car_knc_plot1toecamber(out.logsout_sm_car_testrig_quarter_car,false,true,false);

set_param(mdl,'FastRestart','off')
set_param(mdl,'StopTime',tempStopTime)

for mni = 1:length(metricName)
    metric_i(mni)  = find(strcmp(TSuspMetricsFinal.Names,metricName{mni}));
    FinalValues(mni) = TSuspMetricsFinal.Values(metric_i(mni));
end
FinalValues = FinalValues';

TSuspMetricsSummary = TSuspMetricsStart(metric_i,:);
TSuspMetricsSummary = renamevars(TSuspMetricsSummary,"Values","StartValue");
TSuspMetricsSummary = addvars(TSuspMetricsSummary,FinalValues,'After',"StartValue"); 
TSuspMetricsSummary = addvars(TSuspMetricsSummary,tgtValue,'After','FinalValues') 

paramStruct.Initial = x0';
paramStruct.Final   = xFinal';

paramSummary = struct2table(paramStruct)

