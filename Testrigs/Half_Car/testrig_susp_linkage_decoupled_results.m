%% Simscape Vehicle Library, Half Car KnC Testrig, Decoupled Linkage
%
% This half car model is used to perform kinematics and compliance tests on
% a single axle of a vehicle. Loading different dataset selects different 
% suspension models parameterizes the model.  Vertical, steering, roll,
% aligning torque, lateral compliance, and longitudinal compliance tests
% are performed and suspension metrics are extracted from the results.
%
% Copyright 2018-2024 The MathWorks, Inc.

%% Model
%
% <matlab:open_system('testrig_susp_linkage_decoupled'); Open Model>
 
open_system('testrig_susp_linkage_decoupled')
ann_h = find_system('testrig_susp_linkage_decoupled','FindAll', 'on','type','annotation','Tag','ModelFeatures');
for i=1:length(ann_h)
    set_param(ann_h(i),'Interpreter','off');
end

%% Test Input Sequence
%
% The plot below shows the test inputs for the KnC test.

sm_car_plot_maneuver(Maneuver);

%% Double Wishbone, Decoupled
%

sm_car_load_vehicle_data('none','206')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = sm_car_maneuverdata_knc(0.05,-0.03,0.01,1.25,0.03,500,1200,1200);

out=sim('testrig_susp_linkage_decoupled');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Five Link Suspension, Decoupled
%

sm_car_load_vehicle_data('none','209')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = sm_car_maneuverdata_knc(0.05,-0.03,0.01,1.25,0.03,500,1200,1200);

out=sim('testrig_susp_linkage_decoupled');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%%
bdclose all
close all

% 
% Copyright 2018-2024 The MathWorks(TM), Inc.
