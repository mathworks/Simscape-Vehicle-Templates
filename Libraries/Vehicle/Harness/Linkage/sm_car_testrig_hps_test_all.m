% Script to test hardpoints in all suspension types
% Copyright 2019-2023 The MathWorks, Inc.

sm_car_testrig_hps_test('sm_car_testrig_susp_dwa_hp','Steer','none',0.1)
sm_car_testrig_hps_test('sm_car_testrig_susp_dwa_hp','Steer','none',-0.1)
sm_car_testrig_hps_test('sm_car_testrig_susp_dwa_hp','No Steer','none',0.1)
sm_car_testrig_hps_test('sm_car_testrig_susp_dwa_hp','No Steer','none',-0.1)
bdclose('sm_car_testrig_susp_dwa_hp');

sm_car_testrig_hps_test('sm_car_testrig_susp_dwb_hp','none','none',0.1)
sm_car_testrig_hps_test('sm_car_testrig_susp_dwb_hp','none','none',-0.1)
bdclose('sm_car_testrig_susp_dwb_hp');

sm_car_testrig_hps_test('sm_car_testrig_susp_link5_shockr_hp','none','none',0.1)
sm_car_testrig_hps_test('sm_car_testrig_susp_link5_shockr_hp','none','none',-0.1)
bdclose('sm_car_testrig_susp_link5_shockr_hp');

sm_car_testrig_hps_test('sm_car_testrig_susp_splitla_shockf_hp','none','none',0.1)
sm_car_testrig_hps_test('sm_car_testrig_susp_splitla_shockf_hp','none','none',-0.1)
bdclose('sm_car_testrig_susp_splitla_shockf_hp');
