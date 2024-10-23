%% Simscape(TM) Vehicle Templates
%
% Simscape(TM) Vehicle Templates are designed to help engineers model and
% simulate vehicles using Simscape products. This includes one-axle,
% two-axle, multi-axle vehicles, and trailers that are integrated with
% powertrain and chassis controls.
% 
% The templates include a vehicle model that you can configure for
% different powertrain architectures, driveline concepts, and suspension
% designs. You can also use a MATLAB® app to help you configure the vehicle
% and the test scenario. A modular library of components gives you a
% starting point to create custom vehicle models.
%
% <html>
% <span style="font-family:Arial">
% <span style="font-size:10pt">
% <tr><b><u>Full Vehicle</u></b><br>
% <tr>1.  Vehicle: <a href="matlab:cd(fileparts(which('sm_car.slx')));sm_car;">Open Model</a>, <a href="matlab:web('sm_car.html');">Documentation</a><br> 
% <tr>2.  Library: <a href="matlab:cd(fileparts(which('sm_car_lib.slx')));sm_car_lib;">Open Library</a><br> 
% <br>
% <tr><b><u>Workflow Examples</u></b><br>
% <tr>1. <a href="matlab:web('Simscape_Vehicle_Templates_Exercises.html')">Vehicle Simulation Exercises</a><br>
% <tr>2. Lap Time Optimization: <a href="matlab:web('sm_car_optim_traj_vx_results_overview.html')">Overview</a>, <a href="matlab:edit('sm_car_optim_traj_vx_results_mallory_park.m');">Edit Code</a><br>
% <tr>3. Lap Time + Battery SOC Optimization: <a href="matlab:web('sm_car_optim_traj_vx_regen_results_overview.html')">Overview</a>, <a href="matlab:edit('sm_car_optim_traj_vx_regen_results_mallory_park.m');">Edit Code</a><br>
% <br>
% <tr><b><u>Testing Examples</u></b><br>
% <tr>1. Serial Regenerative Braking, 2 Motor: <a href="matlab:sm_car_test_batt2mot_regen1">Run</a>, <a href="matlab:edit('sm_car_test_batt2mot_regen1.m');">Edit Code</a>, <a href="matlab:web('sm_car_test_batt2mot_regen1.png');">Results</a><br>
% <tr>2. Torque Vectoring: <a href="matlab:sm_car_test_torque_vectoring">Run</a>, <a href="matlab:edit('sm_car_test_torque_vectoring.m');">Edit Code</a>, <a href="matlab:web('sm_car_test_torque_vectoring.png');">Results</a><br>
% <tr>3. Four-Wheel Steering: <a href="matlab:sm_car_test_four_wheel_steering">Run</a>, <a href="matlab:edit('sm_car_test_four_wheel_steering.m');">Edit Code</a>, <a href="matlab:web('sm_car_test_four_wheel_steering.png');">Results</a><br>
% <tr>4. Anti-Lock Brakes: <a href="matlab:sm_car_test_abs">Run</a>, <a href="matlab:edit('sm_car_test_abs.m');">Edit Code</a>, <a href="matlab:web('sm_car_test_abs.png');">Results</a><br>
% <tr>5. Generate GGV Diagram: <a href="matlab:sm_car_ggv_diagram_examples">Run</a>, <a href="matlab:edit('sm_car_ggv_diagram_examples.m');">Edit Code</a>, <a href="matlab:web('sm_car_ggv_diagram_examples.html');">Results</a><br>
% <tr>6. Display Battery Status: <a href="matlab:sm_car_display_battery_test">Run</a>, <a href="matlab:edit('sm_car_display_battery_test.m');">Edit Code</a><br>
% <tr>7. Protected Mode: <a href="matlab:edit('sm_car_test_protected_mode.m');">Edit Code</a><br>
% <br>
% <tr><b><u>Testrigs</u></b><br>
% <tr>1.  Quarter-Car Testrig: <a href="matlab:cd(fileparts(which('testrig_quarter_car.slx')));open_system('testrig_quarter_car');">Open Model</a><br>
% <tr>2.  Half-Car Testrig, Achilles Push Rod: <a href="matlab:cd(fileparts(which('testrig_half_car_pushrodua.slx')));open_system('testrig_half_car_pushrodua');">Open Model</a><br>
% <tr>3.  Half-Car Testrig, Achilles Push Rod, No Steering: <a href="matlab:cd(fileparts(which('testrig_half_car_pushrodua_noSteer.slx')));open_system('testrig_half_car_pushrodua_noSteer');">Open Model</a><br>
% <tr>4.  Half-Car Testrig, Achilles Double-Wishbone Decoupled: <a href="matlab:cd(fileparts(which('testrig_half_car_dwdecoupled.slx')));open_system('testrig_half_car_dwdecoupled');">Open Model</a><br>
% <tr>5.  Half-Car Testrig, Achilles Double-Wishbone Decoupled, No Steering: <a href="matlab:cd(fileparts(which('testrig_half_car_dwdecoupled_nosteer.slx')));open_system('testrig_half_car_dwdecoupled_nosteer');">Open Model</a><br>
% <tr>6.  Half-Car Testrig, Achilles Five Link Decoupled: <a href="matlab:cd(fileparts(which('testrig_half_car_l5decoupled.slx')));open_system('testrig_half_car_l5decoupled');">Open Model</a><br>
% <tr>7.  Steering Testrig: <a href="matlab:cd(fileparts(which('testrig_Steer_Rack.slx')));open_system('testrig_Steer_Rack');">Open Model</a><br>
% <tr>8.  Driveline: <a href="matlab:cd(fileparts(which('testrig_Driveline_Axle2.slx')));open_system('testrig_Driveline_Axle2');">Open Model</a><br>
% <tr>9.  Bushing: <a href="matlab:cd(fileparts(which('sm_bushing_test_radial.slx')));open_system('sm_bushing_test_radial');">Open Model</a><br>
% <br>
% <tr><b><u>Component Test Harnesses</u></b><br>
% <tr>1.  Camera Testrig: <a href="matlab:cd(fileparts(which('testrig_Camera.slx')));open_system('testrig_Camera');">Open Model</a><br>
% <tr>2.  Body Sensor: <a href="matlab:cd(fileparts(which('testrig_body_sensor.slx')));open_system('testrig_body_sensor');">Open Model</a><br>
% <tr>3.  Transforms: <a href="matlab:cd(fileparts(which('testrig_transform_align2pts.slx')));open_system('testrig_transform_align2pts');">Open Model</a><br>
% <br>
% <tr><b><u>Vehicle Parameters</u></b> <br>
% <tr>1.  See Data: <a href="matlab:open('sm_car_library_list_Demo_Script.html');">Vehicle Data and Libraries</a>, <a href="matlab:edit sm_car_gen_init_database;">Init</a>, <a href="matlab:sm_car_winopen_file('sm_car_database_Maneuver.xlsx');">Maneuver</a>, <a href="matlab:edit sm_car_gen_driver_database;">Driver</a>, <a href="matlab:sm_car_winopen_file('sm_car_database_Camera.xlsx');">Camera</a> (<a href="matlab:edit sm_car_import_vehicle_data_sheet;">see code</a>)<br> 
% <tr>2.  Load Data: <a href="matlab:VDatabase = sm_car_import_vehicle_data(0,1);">Vehicle</a>, <a href="matlab:sm_car_gen_init_database;">Init</a>, <a href="matlab:MDatabase = sm_car_import_database('sm_car_database_Maneuver.xlsx','',1);">Maneuver</a>, <a href="matlab:sm_car_gen_driver_database;">Driver</a>, <a href="matlab:CDatabase = sm_car_import_database('sm_car_database_Camera.xlsx','',1);">Camera</a><br> 
% <tr>3.  Assemble Data Sets: <a href="matlab:edit sm_car_assemble_presets;">See Code</a><br> 
% <br>
% <table border=1><tr>
% <td style="text-align:center" colspan=4><b>Scene and Trajectory Data</b></td></tr>
% <td><b>Road Two Lane</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_road_two_lane.slx')));open_system('sm_car_scene_road_two_lane.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_road_two_lane.m')));edit sm_car_scenedata_road_two_lane.m;">Data</a></td></tr>
% <td><b>Plane Grid</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_plane_grid.slx')));open_system('sm_car_scene_plane_grid.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_plane_grid.m')));edit sm_car_scenedata_plane_grid.m;">Data</a></td></tr>
% <td><b>Ice_Patch</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_ice_patch.slx')));open_system('sm_car_scene_ice_patch.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_ice_patch.m')));edit sm_car_scenedata_ice_patch.m;">Data</a></td></tr>
% <td><b>CRG Mallory Park</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_crg_mallory_park.slx')));open_system('sm_car_scene_crg_mallory_park.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_crg_mallory_park.m')));edit sm_car_scenedata_crg_mallory_park.m;">Data</a></td></tr>
% <td><b>RDF Rough Road</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_rdf_rough_road.slx')));open_system('sm_car_scene_rdf_rough_road.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_rdf_rough_road.m')));edit sm_car_scenedata_rdf_rough_road.m;">Data</a></td></tr>
% <td><b>Double Lane Change</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_double_lane_change.slx')));open_system('sm_car_scene_double_lane_change.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_double_lane_change.m')));edit sm_car_scenedata_double_lane_change.m;">Data</a></td>
% <td><a href="matlab:sm_car_plot_maneuver(MDatabase.Double_Lane_Change.Sedan_Hamba);">Plot Trajectory</a></td></tr>
% <td><b>Track Mallory Park</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scene_track_mallory_park.slx')));open_system('sm_car_scene_track_mallory_park.slx')">Library</a></td>
% <td><a href="matlab:cd(fileparts(which('sm_car_scenedata_track_mallory_park.m')));edit sm_car_scenedata_track_mallory_park.m;">Data</a></td>
% <td>Plot Trajectory: <a href="matlab:sm_car_plot_maneuver(MDatabase.Mallory_Park.Sedan_Hamba);">Clockwise</a>, <a href="matlab:sm_car_plot_maneuver(MDatabase.Mallory_Park.CCW_Sedan_Hamba);">Counterclockwise</a></td></tr>
% </table><br>
% <br>
% <table border=1><tr>
% <td style="text-align:center" colspan=4><b>Suspension Hardpoint Tests</b></td></tr>
% <td><b>Double-Wishbone A</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_testrig_susp_dwa_hp.slx')));sm_car_testrig_susp_dwa_hp;">Model</a></td>
% <td>No Steering: <a href="matlab:web('sm_car_testrig_susp_dwa_hp_results_hptest_No_Steer_offsetPos.png');">Positive Offsets</a>, <a href="matlab:web('sm_car_testrig_susp_dwa_hp_results_hptest_No_Steer_offsetNeg.png');">Negative Offsets</a><br>With Steer: <a href="matlab:web('sm_car_testrig_susp_dwa_hp_results_hptest_Steer_offsetPos.png');">Positive Offsets</a>, <a href="matlab:web('sm_car_testrig_susp_dwa_hp_results_hptest_Steer_offsetNeg.png');">Negative Offsets</a></td></tr>
% <td><b>Double Wishbone B</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_testrig_susp_dwb_hp.slx')));sm_car_testrig_susp_dwb_hp;">Model</a></td>
% <td>Results: <a href="matlab:web('sm_car_testrig_susp_dwb_hp_results_hptest_none_offsetPos.png');">Positive Offsets</a>, <a href="matlab:web('sm_car_testrig_susp_dwb_hp_results_hptest_none_offsetNeg.png');">Negative Offsets</a></tr>
% <td><b>Five Link, Shock to Rear</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_testrig_susp_link5_shockr_hp.slx')));sm_car_testrig_susp_link5_shockr_hp;">Model</a></td>
% <td>Results: <a href="matlab:web('sm_car_testrig_susp_link5_shockr_hp_results_hptest_none_offsetPos.png');">Positive Offsets</a>, <a href="matlab:web('sm_car_testrig_susp_link5_shockr_hp_results_hptest_none_offsetNeg.png');">Negative Offsets</a></tr>
% <td><b>Split Lower Arm, Shock to Front</b> </td>
% <td><a href="matlab:cd(fileparts(which('sm_car_testrig_susp_splitla_shockf_hp.slx')));sm_car_testrig_susp_splitla_shockf_hp;">Model</a></td>
% <td>Results: <a href="matlab:web('sm_car_testrig_susp_splitla_shockf_hp_results_hptest_none_offsetPos.png');">Positive Offsets</a>, <a href="matlab:web('sm_car_testrig_susp_splitla_shockf_hp_results_hptest_none_offsetNeg.png');">Negative Offsets</a></tr>
% </table><br>
% <br>
% <tr><b><u>Documentation</u></b><br>
% <tr>1.  <a href="matlab:web('sm_car_doc_overview.html');">Simscape Vehicle Templates Documentation</a><br>
% <br>
% <br>
% </style>
% </style>
% </html>
% 
% Copyright 2018-2024 The MathWorks(TM), Inc.

