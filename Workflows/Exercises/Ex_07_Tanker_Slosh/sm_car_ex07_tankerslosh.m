%% Model Liquid Slosh in Trailer
% 
% The commands below run a semi-truck with a trailer through an evasive
% maneuver.  An abstract model of liquid sloshing in the trailer is
% included. The test is run twice, one with sloshing enabled and another
% with the sloshing disabled. The Simulink Data Inspector let us easily
% compare vehicle and trailer body measurements.
%
% Copyright 2018-2021 The MathWorks, Inc.

%% Step 1: Open Model
% This can be done from the MATLAB UI, project shortcut, or MATLAB Command
% line. 
mdl = 'sm_car_Axle3';
open_system(mdl)

%% Step 2: Configure Model
% This can be done from the MATLAB UI or the MATLAB Command line.  It
% involves loading a data structure into the MATLAB workspace that includes
% the desired vehicle model configuration and parameters
if verLessThan('matlab', '9.11')
    % MFeval tire
    sm_car_load_vehicle_data(mdl,'Axle3_008'); 
    sm_car_load_trailer_data(mdl,'Axle2_004');
else
    % Multibody tire, R21b and higher
    sm_car_load_vehicle_data(mdl,'Axle3_019'); 
    sm_car_load_trailer_data(mdl,'Axle2_024');
end

%% Step 3: Select Event
% This can be done from the MATLAB UI or the MATLAB Command line. It
% configures the driver model for open/closed loop maneuvers and loads the
% necessary parameters into the MATLAB workspace.
% 
% The plot shows the actions the driver will take during this maneuver.
% You can produce this plot from the MATLAB UI or the MATLAB Command line.
sm_car_config_maneuver(mdl,'Double Lane Change');
sm_car_plot_maneuver(Maneuver)

%% Step 4: Run simulation with slosh
% This can be done from Simulink or from the MATLAB command line.

sim(mdl)

%% Step 5: Explore simulation results in Simulink Data Inspector
% Use the Simulink Data Inspector to plot the following quantities.

sm_car_ex07_tankerslosh_plot1

%% Step 6: Disable slosh
% Trailer parameters are adjusted to eliminate the slosh effect.
if verLessThan('matlab', '9.11')
    % MFeval tire
    sm_car_load_trailer_data(mdl,'Axle2_002');
else
    % Multibody tire, R21b and higher
    sm_car_load_trailer_data(mdl,'Axle2_023');
end

%% Step 7: Run simulation with slosh disabled.
% This can be done from Simulink or from the MATLAB command line.

sim(mdl)

%% Step 8: Add simulation results to the Simulink Data Inspector
% Use the Simulink Data Inspector to plot the following quantities from the
% both runs.

sm_car_ex07_tankerslosh_plot2

%%
close all
