%% Simscape Vehicle Library, KnC Tests, Pullrod Quarter Car Testrig
%
% This quarter car model is used to perform kinematics and compliance tests on
% a single corner of a vehicle. Loading different dataset selects different 
% suspension models parameterizes the model.  Vertical, steering, roll,
% aligning torque, lateral compliance, and longitudinal compliance tests
% are performed and suspension metrics are extracted from the results.
%
% Copyright 2018-2024 The MathWorks, Inc.

%% Model
%
% <matlab:open_system('testrig_quarter_car_pullrod'); Open Model>

open_system('testrig_quarter_car_pullrod.slx')
ann_h = find_system('testrig_quarter_car_pullrod','FindAll', 'on','type','annotation','Tag','ModelFeatures');
for i=1:length(ann_h)
    set_param(ann_h(i),'Interpreter','off');
end

%% Test Input Sequence
%
% The plot below shows the test inputs for the KnC test.

sm_car_plot_maneuver(Maneuver);

%% Double Wishbone, Rigid Inboard Connections
%

sm_car_load_vehicle_data('sm_car','198')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = sm_car_maneuverdata_knc(0.05,-0.03,0.01,1.3,0.03,500,1200,1200,1200,1200,-0.3);

out=sim('testrig_quarter_car_pullrod');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%%
bdclose all
close all

