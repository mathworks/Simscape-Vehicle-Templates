% Script to regenerate all databases and presets
% Copyright 2019-2020 The MathWorks, Inc.

VDatabase = sm_car_import_vehicle_data('sm_car_database_Vehicle.xlsx',{'Structure','NameConvention'},0,1);
sm_car_vehicle_data_assemble_set
sm_car_gen_upd_database('Init',0);
sm_car_gen_upd_database('Maneuver',0);
sm_car_gen_upd_database('Driver',0);
sm_car_gen_upd_database('Camera',0);
Scene = sm_car_import_scene_data;

