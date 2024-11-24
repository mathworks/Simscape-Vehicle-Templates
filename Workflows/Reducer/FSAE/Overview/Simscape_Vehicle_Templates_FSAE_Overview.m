%% Simscape(TM) Vehicle Templates for Formula Student
%
% <<Simscape_Vehicle_Templates_FSAE_model.png>>
%
% <matlab:open_system('sm_car'); Open model sm_car>
%
% Simscape(TM) Vehicle Templates are designed to help engineers model and
% simulate vehicles using Simscape products.  This specialized subset of
% the templates includes targeted examples to help Formula Student teams
% get started. The templates include a fully parameterized vehicle model
% that you can configure, including different suspension types. You can
% also select from different events.
% 
% The full version of the Simscape Vehicle Templates with all variants can be accessed here:
% <https://www.mathworks.com/solutions/physical-modeling/simscape-vehicle-templates.html>.
% Because this set of files was extracted from this repository, you may come
% across unresolved library links for content that was not included.  See the
% full version for all content.

%% Events
%
% Supported events include *Accel/Decel*, *Hockenheim (Flat)*, *Hockenheim
% (Flat)*, and *Skidpad*. Change the event by clicking on the hyperlinks on
% the top level of the model. Examine the code behind the hyperlinks to see
% the necessary MATLAB commands to change the maneuver.
%

%% Suspension Types
% 
% Included suspension types are *Double Wishbone*, *Decoupled*, and
% *Pushrod*.  You can change between them by clicking on the hyperlinks on
% the top level of the model. *The data in the workspace selects which
% variants are active based on data within the Vehicle data structure.*
%
% *Note that the hyperlinks execute two commands*, one to load the default
% vehicle parameters and the other to configure the event.  *After loading
% vehicle parameters, you need to select the event again so that the tire
% models know which surface they are driving on.*
%
% You can explore the suspensions with these testrig models
%
% * Open model: <matlab:open_system('testrig_quarter_car_doublewishbone'); Quarter car, Double Wishbone>
% * Open model: <matlab:open_system('testrig_quarter_car_pullrod'); Quarter car, Pullrod>
% 
% See also the
% <matlab:cd(fileparts(which('testrig_quarter_car_doublewishbone.slx')));testrig_quarter_car_mlapp_sweep_optim; Suspension Tester App> (<matlab:web('testrig_quarter_car_sweep_optim_test.html'); Workflow>)
 

%% Vehicle Parameterization
%
% Vehicle parameters are defined in MATLAB Scripts
%
% * *Double Wishbone:* <matlab:edit('Vehicle_data_dwishbone.m') Vehicle_data_dwishbone.m> 
% * *Decoupled:*  <matlab:edit('Vehicle_data_decoupled.m') Vehicle_data_decoupled.m> 
% * *Pullrod:*  <matlab:edit('Vehicle_data_dwpullrod.m') Vehicle_data_dwpullrod.m> 
%
% Each of these defines a structure "Vehicle" in the MATLAB workspace.  You
% can modify parameter values in the workspace or in the file.  There are
% cases where some parameters depend on other parameters. *Take care when
% adjusting parameters in the tire, shocks, and track rod.* 
%
% # *The tire has parameters that define which surface it is on.* . The code in
% <matlab:edit('sm_car_config_maneuver.m') sm_car_config_maneuver.m> will ensure they are set properly.
% # *Some parameter values must be identical in two places within the
% Vehicle data structure.*  A function call at the bottom of the
% each vehicle data script will ensure the values are consistent. For more
% details see functions for ensuring parameter consistency
% <matlab:edit('addfieldVehicleDec.m') decoupled suspension> and
% <matlab:edit('addfieldVehicleDW.m') double wishbone>.
%
% Suspension link inboard connections can be set to <matlab:Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.class.Value='Rigid_1Rev';Vehicle.Chassis.SuspA1.Linkage.Lower_Arm_to_Subframe.class.Value='Rigid_1Rev';Vehicle.Chassis.SuspA2.Linkage.Upper_Arm_to_Subframe.class.Value='Rigid_1Rev';Vehicle.Chassis.SuspA2.Linkage.Lower_Arm_to_Subframe.class.Value='Rigid_1Rev'; kinematic> 
% or <matlab:Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.class.Value='Bushings';Vehicle.Chassis.SuspA1.Linkage.Lower_Arm_to_Subframe.class.Value='Bushings';Vehicle.Chassis.SuspA2.Linkage.Upper_Arm_to_Subframe.class.Value='Bushings';Vehicle.Chassis.SuspA2.Linkage.Lower_Arm_to_Subframe.class.Value='Bushings'; compliant> with bushings.

%% Control Algorithms
%
% A very simple torque vectoring algorithm is included.  You can enable it
% using the drop down menu on the Controller mask dialog. Take a look at it
% and customize it with your own algorithm.

% Copyright 2018-2024 The MathWorks(TM), Inc.

