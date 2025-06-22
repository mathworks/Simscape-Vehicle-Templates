%% Simscape Vehicle Library, KnC Tests, Quarter Car Testrig
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
% <matlab:open_system('testrig_quarter_car'); Open Model>

open_system('testrig_quarter_car.slx')
ann_h = find_system('testrig_quarter_car','FindAll', 'on','type','annotation','Tag','ModelFeatures');
for i=1:length(ann_h)
    set_param(ann_h(i),'Interpreter','off');
end

%% Test Input Sequence
%
% The plot below shows the test inputs for the KnC test.

sm_car_plot_maneuver(Maneuver);

%% Double Wishbone, Rigid Inboard Connections
%

sm_car_load_vehicle_data('none','000')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Double Wishbone, Bushing Inboard Connections
%
sm_car_load_vehicle_data('none','000')
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','BushArm_AxRad_Sedan_LA');
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Double Wishbone, No Steering
%

sm_car_load_vehicle_data('none','016')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Split Lower Arm, Shock to Lower Arm Front
%

sm_car_load_vehicle_data('none','032')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Split Lower Arm, Shock to Lower Arm Rear
%

sm_car_load_vehicle_data('none','048')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Five Link, Shock to Lower Arm Front
%

sm_car_load_vehicle_data('none','064')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Five Link, Shock to Lower Arm Front, Constraints
%

sm_car_load_vehicle_data('none','080')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Five Link, Shock to Lower Arm Rear
%

sm_car_load_vehicle_data('none','096')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = MDatabase.KnC.Sedan_HambaLG;

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% MacPherson
%

sm_car_load_vehicle_data('none','218')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = sm_car_maneuverdata_knc(0.1,-0.1,0.01,1.0,0.10,500,1200,1200,1200,1200,-0.3);

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Formula Student Vehicle, Pullrod
%

sm_car_load_vehicle_data('none','198')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = sm_car_maneuverdata_knc(0.05,-0.03,0.01,1.3,0.03,500,1200,1200,1200,1200,-0.3);

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%% Formula Student Vehicle, Pushrod
%

sm_car_load_vehicle_data('none','223')
Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0],'SuspA1');
Maneuver = sm_car_maneuverdata_knc(0.05,-0.03,0.01,1.3,0.03,500,1200,1200,1200,1200,-0.3);

out=sim('testrig_quarter_car');
TSuspMetrics = sm_car_knc_plot1toecamber(logsout_sm_car_testrig_quarter_car,true,true,false);

%%
TSuspMetrics

%%
bdclose all
close all

