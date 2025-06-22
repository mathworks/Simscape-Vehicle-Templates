%% Tuning Suspension Hardpoints to Meet Vehicle Performance Metrics
%
% This example tunes suspension hardpoints to minimize the maximum body
% roll angle during a double-lane change. Using MATLAB scripts you can
% specify the which hardpoints (such as outboard hardpoint on the upper
% wishbone) and which coordinates (such as along the x, y, or z axis)
% should be tuned.
%
% First a sweep is performed to explore the design space. If two
% coordinates are selected for tuning, a 2D plot will be shown, otherwise a
% table of the tested values and the resulting performance metric are
% shown.  Next, optimization algorithms are used to find the combination
% that comes closest to the target value of the selected performance
% metric.
%
% The documentation below shows the steps performed on sm_car.slx.  
%
% Copyright 2025 The MathWorks, Inc.

%% Vehicle Model
%
% The model <matlab:open_system('sm_car'); sm_car> can be configured to
% test several different types of suspensions.  The suspension type is
% selected based on field Vehicle.Chassis.SuspA1.Linkage.class.Value within
% a MATLAB data structure. The locations of the hardpoints are defined
% within that structure.
%
% <matlab:open_system('sm_car'); Open Model>

mdl = 'sm_car';
open_system(mdl)
sm_car_load_vehicle_data(mdl,'064');
sm_car_config_variants(mdl);

%% Suspension Model
%
% This is the structure of the suspension.  The entire suspension is
% parameterized based on hardpoints.  Those hardpoints are defined based on
% [x y z] locations relative to a common reference point.  In the default
% set of data provided, that reference point is on the ground at the
% point midway between where the left and right tires touch the ground.
%
% <matlab:open_system('testrig_quarter_car');open_system('testrig_quarter_car/Linkage/FiveLinkShockFront','force'); Open Subsystem>

open_system('sm_car/Vehicle/Vehicle/Chassis/SuspA1/Linkage/Linkage L/FiveLinkShockFront','force');

%% Define Sets of Values for Parameter Sweep
%
% The portion of the design space that will be tested is defined by
% selecting hardpoint coordinates and a set of values for that coordinate.
% In this example, we vary the z-coordinate for both ends of the track rod
% in the steering system.  MATLAB will test each combination of values for
% the two points and plot the result.  Any number of coordinates can be
% used for the sweep, we limited it to two in the example so that we could
% plot the results as a surface.

% Settings parameters to be swept
% path2Val is complete path to variable and index in parentheses 
par_list(1).path2Val = 'Vehicle.Chassis.SuspA1.Linkage.TrackRod.sInboard.Value(3)';
par_list(1).relRange = -0.04:0.02:0.04;  % Relative range in m

par_list(2).path2Val = 'Vehicle.Chassis.SuspA1.Linkage.TrackRod.sOutboard.Value(3)';
par_list(2).relRange = -0.04:0.04:0.04;  % Relative range in m

for par_i = 1:length(par_list)
    par_list(par_i).initVal  = eval(par_list(par_i).path2Val);
    par_list(par_i).valueSet = par_list(par_i).initVal + par_list(par_i).relRange;
end

% Set up Maneuver
sm_car_config_maneuver('sm_car','Double Lane Change');
sim(mdl)

%% Conduct Parameter Sweep
%
% This function will create a simulation input object where each entry has
% a unique combination of the hardpoint coordinate values specified above.
% The simulations will be run using the sim() command, and at the end a
% surface plot shows how the selected performance metric (in this case
% maximum roll angle) varies with the two coordinate values.
%
% The roll angle versus time is plotted for each test.

[simInput, simOut] = sm_car_sweep_run(mdl,Vehicle,par_list);
CarMetricsSet = sm_car_sweep_plot_runs(simInput,simOut,'aRoll');

%% Display and Plot Performance Metrics Obtained from Sweep
%
% The parameter values tested and performance metric are shown in a table.
% For tests with two performance metrics, a surface plot is shown.
% The surface plot shows how the performance metric varies as the parameter
% values are modified.

disp('Results of Sweep');
[SweepTableMxRoll,ax_Ro] = sm_car_sweep_table_plot_metrics(par_list,CarMetricsSet,'Max Roll Angle');
displayWholeObj(SweepTableMxRoll)

% Use interpolation to highlight initial point of design
if(~isempty(ax_Ro))
    [vHP1, vHP2] = meshgrid(par_list(1).valueSet,par_list(2).valueSet);
    param1 = par_list(1).initVal;
    param2 = par_list(2).initVal;

    % Obtain performance metric for default design
    qBstr = interp2(vHP1,vHP2,...
        reshape(SweepTableMxRoll.("Max_Roll_Angle"),...
        [length(par_list(2).valueSet) length(par_list(1).valueSet)]),...
        param1,param2);

    % Add to plot
    hold on
    plot3(ax_Ro,param1,param2,qBstr,'kd','MarkerFaceColor','k','MarkerSize',6,...
        'DisplayName','Initial Design');
    hold off
    legend('Location','Best')
end

%% Optimize Selected Hardpoints to Achieve Target Performance Metrics
%
% Now that we have seen the design space, we will use optimization
% algorithms to identify the coordinates to minimize roll angle.  The list
% of hardpoint coordinates and their ranges are provided to the
% optimization algorithm.  An objective function runs a simulation with
% those values and computes the performance metrics. After the optimizer
% converges on values or reaches the limit on the number of iterations
% permitted, the results are shown and overlaid on the parameter sweep
% plots.
%
% In this optimization test, the target value for maximum roll angle is
% supplied.

metricName    = {'Max Roll Angle'};
tgtValue      = [0];  % Set to zero, try to minimize
metricWeights = [1];

[xFinal,fval,CarMetrics] = ...
    sm_car_optim_run(mdl,Vehicle,par_list,metricName,tgtValue,metricWeights);

%%
% The plots below show add the performance metrics from the new design.
% Values for the hardpoint locations were found that minimize the roll
% angle during the double-lane change.  

bs_i = find(strcmp(CarMetrics.Names,metricName{1}));

if(~isempty(ax_Ro))
    hold(ax_Ro,'on')
    plot3(ax_Ro,xFinal(1),xFinal(2),CarMetrics.Values(bs_i),...
        'rs','MarkerSize',10,...
        'DisplayName','Tuned Design');
    hold(ax_Ro,'off')
end

%%
%close all