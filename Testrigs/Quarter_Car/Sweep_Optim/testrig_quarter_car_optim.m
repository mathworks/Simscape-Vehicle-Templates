function [xFinal,fval,TSuspMetricsFinal] = testrig_quarter_car_optim(mdl,Vehicle,hp_list,metricName,tgtValue,Maneuver)
%testrig_quarter_car_optim  Example to tune suspension hardpoints to minimize target metric
%   This function permits the user to tune any number of hardpoint
%   coordinates to achieve a target performance metric. Before the model
%   is called, it should be configured with the desired suspension and set
%   of hardpoints to tune
%
%      mdl         Simulink model name
%      Vehicle     Vehicle data structure used by model, contains hardpoints
%      hp_list     Structure defining hardpoints to tune
%           .part        Part where hardpoint is defined  (example: 'UpperArm')
%           .point       Name of hardpoint                (example: 'sOutboard')
%           .index       Index of coordinate (1 = x, 2 = y, 3 = z)
%           .valueSets   Vector defining range (first element min, last element max)
%      metricName  Target metric for optimization
%      tgtValue    Target value for metric 
%
%   Outputs
%      xFinal             Vector with list of optimal hardpoint coordinates
%      fval               Optimized value of performance metric
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

disp('Metrics with Initial Set of Parameter Values')
TSuspMetricsStart = sm_car_knc_plot1toecamber(out.logsout_sm_car_testrig_quarter_car,true,true,false)

% Hold plot during optimization
fig_h = gcf;
hold(fig_h.Children(1),'on');
hold(fig_h.Children(2),'on');

%% Set up optimization
% Load initial values and limits
for hp_i = 1:length(hp_list)
    % Variable initial values
    x0(hp_i) = Vehicle.Chassis.SuspA1.Linkage.(hp_list(hp_i).part).(hp_list(hp_i).point).Value(hp_list(hp_i).index);
    % Upper and lower limits for hardpoint coordinates
    UB(hp_i) = hp_list(hp_i).valueSet(end);
    LB(hp_i) = hp_list(hp_i).valueSet(1);
end


%% Run optimization

% Record start time for optimization
tOptStart = tic;

% Use patternsearch
options = optimoptions('patternsearch','PollMethod','GSSPositiveBasis2N', ...
    'Display','iter','PlotFcn', @psplotbestf,'MaxIterations',40, ...
    'MeshTolerance',1e-4,'UseCompletePoll',true,'InitialMeshSize',min((UB-LB)/4), ...
    'MeshContractionFactor',0.25);
[x,fval,~,~] = ...
    patternsearch(@(x)obj_bump_steer(x, mdl,hp_list,Vehicle,metricName,tgtValue,fig_h),...
    x0,[],[],[],[],LB,UB,[],options);

% Use fmincon
%{
options = optimoptions('fmincon','Display','iter');
[x,fval,~,~] = ...
    fmincon(@(x)obj_bump_steer(x, mdl,hp_list,Vehicle,metricName,tgtValue,fig_h),...
    x0,[],[],[],[],LB,UB,[],options);
%}

% Record duration of optimization
tOptDuration = toc(tOptStart);
disp(['Elapsed time for optimization = ' num2str(tOptDuration)]);

% Return final sets of values
xFinal = x;

% Load final set of values into structure in workspace
for hp_i=1:length(hp_list)
    Vehicle.Chassis.SuspA1.Linkage.(hp_list(hp_i).part).(hp_list(hp_i).point).Value(hp_list(hp_i).index) = xFinal(hp_i);
end
assignin('base','Vehicle',Vehicle)

% Calculate, display, and return optimized performance metrics
out = sim(mdl);

disp(' ');
disp('Metrics with Optimized Set of Parameter Values')
[TSuspMetricsFinal, ~, ~] = sm_car_knc_plot1toecamber(out.logsout_sm_car_testrig_quarter_car,false,true,false)
set_param(mdl,'FastRestart','off')
set_param(mdl,'StopTime',tempStopTime)

metric_i  = find(strcmp(TSuspMetricsFinal.Names,metricName));
metricVal = TSuspMetricsFinal.Values(metric_i);

%% If sweep was performed and figure present, plot result on sweep
handle_var = evalin('base','who(''h2_testrig_quarter_car_sweep'')');
if(~isempty(handle_var))
    if (isgraphics(evalin('base',handle_var{:})))

        % If figure still exists, add optimal solution to plot
        fig_h = evalin('base','h2_testrig_quarter_car_sweep');
        figure(fig_h)
        hold on
        plot3(xFinal(1),xFinal(2),metricVal,'rd','MarkerFaceColor','r','MarkerSize',8)
        hold off
    end
end
