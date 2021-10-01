%% Tune Suspension Damping in Braking Test
% 
% The commands below run the vehicle on a Wide Open Throttle (WOT) and
% braking test with two different values for the suspension damping.  The
% plots in the Simulink Data Inspector let us easily compare vehicle body
% measurements to see the effect of this parameter value on vehicle
% dynamics.
%
% Copyright 2018-2021 The MathWorks, Inc.

%% Step 1: Open Model
% This can be done from the MATLAB UI, project shortcut, or MATLAB Command
% line.
mdl = 'sm_car';
open_system(mdl)

%% Step 2: Configure Model
% This can be done from the MATLAB UI or the MATLAB Command line.  It
% involves loading a data structure into the MATLAB workspace that includes
% the desired vehicle model configuration and parameters
if verLessThan('matlab', '9.11')
    sm_car_load_vehicle_data(mdl,'139'); % MFeval tire
else
    sm_car_load_vehicle_data(mdl,'189'); % Multibody tire, R21b and higher
end

%% Step 3: Configure Event
% This can be done from the MATLAB UI or the MATLAB Command line. It
% configures the driver model for open/closed loop maneuvers and loads the
% necessary parameters into the MATLAB workspace.
% 
% The plot shows the actions the driver will take during this maneuver.
% You can produce this plot from the MATLAB UI or the MATLAB Command line.

sm_car_config_maneuver('sm_car','WOT Braking');
sm_car_plot_maneuver(Maneuver)
subplot(311);
set(gca,'XLim', [0 30])

%% Step 4: Run simulation with nominal damping
% This can be done from Simulink or from the MATLAB command line.
sim(mdl)

%% Step 5: Explore simulation results in Simulink Data Inspector
% Use the Simulink Data Inspector to plot the following quantities:

sm_car_ex01_damping_wot_plot1

%% Step 6: Increase damping of vehicle suspension
% Adjusting these numerical values in the Vehicle data structure will
% increase the damping at the front and rear.

Vehicle.Chassis.Damper.Axle1.Damping.d.Value = 10000;
Vehicle.Chassis.Damper.Axle2.Damping.d.Value = 10000;

%% Step 7: Run simulation with nominal damping
% This can be done from Simulink or from the MATLAB command line.

sim(mdl)

%% Step 8: Add simulation results to the Simulink Data Inspector
% Use the Simulink Data Inspector to plot the following quantities from the
% both runs.

sm_car_ex01_damping_wot_plot2

%%
close all



