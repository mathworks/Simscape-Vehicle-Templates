% Script to regenerate all databases and presets
% Copyright 2019-2024 The MathWorks, Inc.

VDatabase = sm_car_import_vehicle_data(0,1);
sm_car_assemble_presets
sm_car_gen_init_database;
MDatabase = sm_car_import_maneuver_data;
sm_car_gen_driver_database;
CDatabase.Camera = sm_car_gen_camera_database;
Scene = sm_car_import_scene_data;

