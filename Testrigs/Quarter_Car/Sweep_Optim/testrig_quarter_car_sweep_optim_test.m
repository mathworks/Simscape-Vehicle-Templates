%% Tuning Suspension Hardpoints to Minimize Bump Steer
%
% This example tunes suspension hardpoints to minimize the bump steer in a
% vehicle suspension. Using MATLAB scripts or an App you can specify the
% which hardpoints (such as outboard hardpoint on the upper wishbone) and
% which coordinates (such as along the x, y, or z axis) should be tuned.
%
% First a sweep is performed to show the design space. If two coordinates
% are selected for tuning, a 2D plot will be shown, otherwise a table of
% the tested values and the resulting performance metric.  Next,
% optimization algorithms are used to find the combination that comes
% closest to the target value of the selected performance metric.
%
% The documentation below shows the steps performed on
% testrig_quarter_car.slx.  They can also be performed on
% testrig_quarter_car_doublewishbone.slx and
% testrig_quarter_car_pullrod.slx.
%
% Copyright 2024 The MathWorks, Inc.

%% Quarter-Car Testrig Model
%
% The model <matlab:open_system('testrig_quarter_car');
% testrig_quarter_car> can be configured to test several different types of
% suspensions.  The suspension type is selected based on field
% Vehicle.Chassis.SuspA1.Linkage.class.Value within a MATLAB data
% structure. The locations of the hardpoints are defined within that
% structure.
%
% <matlab:open_system('testrig_quarter_car'); Open Model>

mdl = 'testrig_quarter_car';
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

open_system('testrig_quarter_car/Linkage/FiveLinkShockFront','force');

%% Define Sets of Values for Parameter Sweep
%
% The portion of the design space that will be tested is defined by
% selecting hardpoint coordinates and a set of values for that coordinate.
% In this example, we vary the z-coordinate for both ends of the track rod
% in the steering system.  MATLAB will test each combination of values for
% the two points and plot the result.  Any number of coordinates can be
% used for the sweep, we limited it to two in the example so that we could
% plot the results as a surface.

% Settings for first hardpoint coordinate
adjSet1 = -0.04:0.02:0.04;  % Relative range in m
hp_list(1).part  = 'TrackRod';
hp_list(1).point = 'sInboard';
hp_list(1).index = 3;
hp_list(1).valueSet = ...
    Vehicle.Chassis.SuspA1.Linkage.(hp_list(1).part). ...
    (hp_list(1).point).Value(hp_list(1).index) + adjSet1;

% Settings for second hardpoint coordinate
adjSet2 = -0.04:0.04:0.04;  % Relative range in m
hp_list(2).part  = 'TrackRod';
hp_list(2).point = 'sOutboard';
hp_list(2).index = 3;
hp_list(2).valueSet = ...
    Vehicle.Chassis.SuspA1.Linkage.(hp_list(2).part). ...
    (hp_list(2).point).Value(hp_list(2).index) + adjSet2;

% Performance metric to plot or display
metricName = 'Bump Steer';

%% Conduct Parameter Sweep
%
% This function will create a simulation input object where each entry has
% a unique combination of the hardpoint coordinate values specified above.
% The simulations will be run using the sim() command, and at the end a
% surface plot shows how the selected performance metric (in this case bump
% steer) varies with the two coordinate values.
%
% The toe and camber curves for each test are plotted.

[simInput, simOut, TSuspMetricsSet] = ...
    testrig_quarter_car_sweep(mdl,Vehicle,hp_list);

%% Display and Plot the Results of Sweep
%
% The parameter values tested and performance metric are shown in a table.
% For tests with two performance metrics, a surface plot is shown.

disp('Results of Sweep');
TSuspMetricsReq = ...
    testrig_quarter_car_sweep_plot(hp_list,TSuspMetricsSet,metricName)

%% Optimize Selected Hardpoints to Achieve Target Bump Steer
%
% Now that we have seen the design space, we will use optimization
% algorithms to identify the coordinates that achieve the desired level of
% bump steer.  The list of hardpoint coordinates and their ranges are
% provided to the optimization algorithm.  An objective function computes
% runs a simulation with those values and computes the performance metric.
% After the optimizer converges on a value or reaches the limit on the
% number of iterations permitted, the result is shown and overlaid on the
% parameter sweep plot.

tgtValue    = 2; % deg/m
[xFinal,fval,TSuspMetrics] = ...
    testrig_quarter_car_optim(mdl,Vehicle,hp_list,metricName,tgtValue);

%% Workflow Using MATLAB App
%
% An App lets you select the hardpoint coordinates you wish to sweep or
% optimize.  You can select the range and increment for a sweep, and you
% can select the range and target performance metric for an optimization.
% Once you have configured your sweep or optimization, press the Run
% button.
%
% Anything done with the App can also be done using MATLAB functions.
% As you configure and run the test, commands are echoed to the MATLAB
% command window so you know which commands will automate those steps.
 
%%
% 
% <<Simscape_Suspension_Tester_App.png>>
% 

%%
close all