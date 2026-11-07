load Vehicle_189
Vehicle = Vehicle_189;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1S2_1D_1D_HA');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

%% Add bushings
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','Bushing_Sedan_LA');

Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','Bushing_Sedan_LA');


%% Remove bushings
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','Rigid_1Rev');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','Rigid_1Rev');

Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','Rigid_1Rev');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','Rigid_1Rev');


%% 5 Link Shock to Lower Arm Front
sm_car_load_vehicle_data('none','072');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAF','BushingUJ_SLGf_5LS2F_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_SLGf_5LS2F_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAR','BushingUJ_SLGf_5LS2F_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_SLGf_5LS2F_LAR');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'FiveLinkShockFront_Sedan_HambaLG_r','SuspA2');

Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAF','BushingUJ_SLGr_5LS2F_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushingUJ_SLGr_5LS2F_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAR','BushingUJ_SLGr_5LS2F_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushingUJ_SLGr_5LS2F_LAR');


%% 5 Link Shock to Lower Arm Rear
sm_car_load_vehicle_data('none','088');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAF','BushingUJ_SLGf_5LS2R_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_SLGf_5LS2R_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAR','BushingUJ_SLGf_5LS2R_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_SLGf_5LS2R_LAR');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'FiveLinkShockRear_Sedan_HambaLG_r','SuspA2');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAF','BushingUJ_SLGr_5LS2R_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushingUJ_SLGr_5LS2R_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAR','BushingUJ_SLGr_5LS2R_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushingUJ_SLGr_5LS2R_LAR');

%% Split Lower Arm Shock to Lower Arm Front
sm_car_load_vehicle_data('none','040');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA', 'Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_SLGf_S2LAF_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_SLGf_S2LAF_LAR');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'SplitLowerArmShockFront_Sedan_HambaLG_r','SuspA2');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA', 'Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushingUJ_SLGr_S2LAF_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushingUJ_SLGr_S2LAF_LAR');

%% Split Lower Arm Shock to Lower Arm Rear
sm_car_load_vehicle_data('none','056');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA', 'Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_SLGf_S2LAR_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_SLGf_S2LAR_LAR');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'SplitLowerArmShockRear_Sedan_HambaLG_r','SuspA2');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA', 'Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushingUJ_SLGr_S2LAR_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushingUJ_SLGr_S2LAR_LAR');

%% 5 Link Decoupled Achilles
sm_car_load_vehicle_data('none','209');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAF','BushingUJ_Achf_5LDecF_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_Achf_5LDecF_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAR','BushingUJ_Achf_5LDecF_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_Achf_5LDecF_LAR');

%% Sedan Split Lower Arm, Shock to Lower, Front Front and Rear
load Vehicle_189
Vehicle = Vehicle_189;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1S2_1D_1D_HA');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'SplitLowerArmShockFront_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA', 'Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_Sef_S2LAF_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_Sef_S2LAF_LAR');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'SplitLowerArmShockFront_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA', 'Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushingUJ_Ser_S2LAF_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushingUJ_Ser_S2LAF_LAR');

%% Sedan Five Link, Shock to Lower Rear, Front and Rear
load Vehicle_189
Vehicle = Vehicle_189;
Vehicle = sm_car_vehcfg_setDrv(Vehicle,'A2_S1S2_1D_1D_HA');
Vehicle = sm_car_vehcfg_setPower(Vehicle,'Ideal_L1_R1_L2_R2_default');
Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'None');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'FiveLinkShockRear_Sedan_Hamba_f','SuspA1');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAF','BushingUJ_Sef_5LS2R_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushingUJ_Sef_5LS2R_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAR','BushingUJ_Sef_5LS2R_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushingUJ_Sef_5LS2R_LAR');

Vehicle = sm_car_vehcfg_setSusp(Vehicle,'FiveLinkShockRear_Sedan_Hamba_r','SuspA2');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAF','BushingUJ_Ser_5LS2R_UAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushingUJ_Ser_5LS2R_LAF');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAR','BushingUJ_Ser_5LS2R_UAR');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushingUJ_Ser_5LS2R_LAR');

%% Achilles DW
sm_car_load_vehicle_data('none','213')
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','Bushing_Sedan_LA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','Bushing_Sedan_LA');

%% Achilles DW Pushrod
sm_car_load_vehicle_data('none','215')
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','Bushing_Sedan_LA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','Bushing_Sedan_LA');

%% Achilles DW Decoupled
sm_car_load_vehicle_data('none','214')
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','Bushing_Sedan_LA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','Bushing_Sedan_UA');
Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','Bushing_Sedan_LA');

Vehicle.Chassis.SuspA1.Linkage.Upper_Arm_to_Subframe.class.Value = 'Rigid_1Rev';
Vehicle.Chassis.SuspA1.Linkage.Lower_Arm_to_Subframe.class.Value = 'Rigid_1Rev';
