cd(fileparts(which(mfilename)))

testnum = 0;
clear sm_car_res
now_string = datestr(now,'yymmdd_HHMM');

mdl = 'sm_car';

results_foldername = [mdl '_' now_string];
%results_foldername = 'sm_car_201121_0028';
mkdir(results_foldername)

%% Text two-axle suspensions
LinkageCfgsA2 = {...
    'DoubleWishbone_Sedan_Hamba_f',               'DoubleWishboneA_Sedan_Hamba_r',             'DW','DWA';...
    'FiveLinkShockRear_Sedan_Hamba_f',            'FiveLinkShockCenterAUNoSteer_Sedan_Hamba_r' , '5LS2R','5LS2RnoStr';...
    'ConstrFiveLinkShockFront_Sedan_HambaLG_f',   'FiveLinkShockCenterAUNoSteer_Sedan_Hamba_r',  '5LS2Fc','5LS2RnoStr';... %DUP
    'MacPherson_Sedan_HambaLG_f',                 'FiveLinkShockFront_Sedan_HambaLG_r',        '5LS2Fc','5LS2RnoStr';...
    'SplitLowerArmShockFront_Sedan_HambaLG_f',    'SplitLowerArmShockRear_Sedan_HambaLG_r',    'S2LAF','S2LAR';...
    'SplitLowerArmShockFrontAU_Sedan_Hamba_f',    'SplitLowerArmShockFrontAD_Sedan_Hamba_r',   'S2LAF_AU','S2LAF_AD';...
    'SplitLowerArmShockRearAD_Sedan_Hamba_f',     'SplitLowerArmShockRearAU_Sedan_Hamba_r',    'S2LAR_AD','S2LAR_AU';...
    'DoubleWishbonePullrod_FSAE_Achilles_f',      'DoubleWishbonePullrodNoSteer_FSAE_Achilles_r','DWPull','DWPullnoStr';...
    'DoubleWishbonePushrod_FSAE_Achilles_f',      'DoubleWishbonePushrodNoSteer_FSAE_Achilles_r','DWPush','DWPushnoStr'...
    };


DefCfgsA2 = {'HambaLG','216'; 'Hamba_','189';'Achilles','223'};

testSuspKA2Tic = tic; 
for i = 1:size(LinkageCfgsA2,1)
    for def_i = 1:size(DefCfgsA2,1)
        vehType(def_i) = contains(LinkageCfgsA2{i,1},DefCfgsA2{def_i,1});
    end
    preset_ind = DefCfgsA2{vehType,2};
    sm_car_load_vehicle_data('sm_car',preset_ind);
    if(startsWith(LinkageCfgsA2{i,1},'Constr'))
        SuspA1cfg = strrep(LinkageCfgsA2{i,1},'Constr','');
    else
        SuspA1cfg = LinkageCfgsA2{i,1};
    end
    Vehicle = sm_car_vehcfg_setSusp(Vehicle,SuspA1cfg,'SuspA1');
    Vehicle = sm_car_vehcfg_setSusp(Vehicle,LinkageCfgsA2{i,2},'SuspA2');
    if(startsWith(LinkageCfgsA2{i,1},'Constr'))
        Vehicle.Chassis.SuspA1.Linkage.class.Value = 'FiveLinkConstraintShockFront';
    end
    set_param(bdroot,'StopTime','0.5');

    out = [];
    testnum = testnum+1;
    
    logsout_sm_car = [];
    try
        sim('sm_car');
        test_success = 'Pass';
    catch ME
        disp(['Error: ' ME.message ', ' ME.identifier]);
        Elapsed_Sim_Time = toc;
        test_success = 'Fail';
    end

    if(~isempty(logsout_sm_car))
        %logsout_sm_car = out.logsout_sm_car;
        sm_car_plot1speed
        filenamefig = ['Test_' pad(num2str(i),3,'left','0') '.png']; 
        saveas(gcf,['.\' results_foldername '\' filenamefig]);
        logsout_VehBus = logsout_sm_car.get('VehBus');
        logsout_xCar = logsout_VehBus.Values.World.x;
        nStp = length(logsout_xCar.Time);
    else
        % Simulation failed
        nStp = -1;
        xFin = 0;
        yFin = 0;
        figname = 'failed';
    end
    sm_car_res(testnum).Elap = Elapsed_Sim_Time;
    sm_car_res(testnum).nStp = nStp;
    sm_car_res(testnum).figname = figname;
    sm_car_res(testnum).result = test_success;
    sm_car_res(testnum).A1 = LinkageCfgsA2{i,3};
    sm_car_res(testnum).A2 = LinkageCfgsA2{i,4};
end
durSuspKA2 = toc(testSuspKA2Tic);

%% With Bushings

testSuspCA2Tic = tic; 
for i = 1:size(LinkageCfgsA2,1)

    for def_i = 1:size(DefCfgsA2,1)
        vehType(def_i) = contains(LinkageCfgsA2{i,1},DefCfgsA2{def_i,1});
    end
    preset_ind = DefCfgsA2{vehType,2};
    sm_car_load_vehicle_data('sm_car',preset_ind);
    if(startsWith(LinkageCfgsA2{i,1},'Constr'))
        SuspA1cfg = strrep(LinkageCfgsA2{i,1},'Constr','');
    else
        SuspA1cfg = LinkageCfgsA2{i,1};
    end
    Vehicle = sm_car_vehcfg_setSusp(Vehicle,SuspA1cfg,'SuspA1');
    Vehicle = sm_car_vehcfg_setSusp(Vehicle,LinkageCfgsA2{i,2},'SuspA2');
    if(startsWith(LinkageCfgsA2{i,1},'Constr'))
        Vehicle.Chassis.SuspA1.Linkage.class.Value = 'FiveLinkConstraintShockFront';
    end

    switch i
        case 1
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','BushArm_AxRad_Sef_DW_LA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','BushArm_AxRad_Sef_DW_LA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','ARB','BushARB_Ax3_Sef_DW');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','ARB','BushARB_Ax3_Ser_DW');
        case 2
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAF','BushLink_AxRad_SLGf_5LS2F_UAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UAR','BushLink_AxRad_SLGf_5LS2F_UAR');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushLink_AxRad_SLGf_5LS2F_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushLink_AxRad_SLGf_5LS2F_LAR');

            Vehicle.Chassis.SuspA2.Linkage.UpperArmF_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_UAF;
            Vehicle.Chassis.SuspA2.Linkage.UpperArmR_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_UAR;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmF_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAF;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmC_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAC;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmR_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAR;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmR_to_Upright   = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAROuter;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Sef_DW;
            Vehicle.Chassis.SuspA2.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Ser_DW;
        case 3
            Vehicle.Chassis.SuspA2.Linkage.UpperArmF_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_UAF;
            Vehicle.Chassis.SuspA2.Linkage.UpperArmR_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_UAR;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmF_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAF;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmC_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAC;
            Vehicle.Chassis.SuspA2.Linkage.LowerArmR_to_Subframe  = VDatabase.Subframe_Conn.BushLink_Tr3Ro3_Ser_5LS2C_LAR;
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Sef_DW;
            Vehicle.Chassis.SuspA2.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Ser_DW;
        case 4
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','BushArm_Tr3Ro3_Sef_MacP_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','ARB','BushARB_Tr3Ro3_SLGf_MacP');
            Vehicle.Chassis.SuspA1.Linkage.Shock_to_Subframe = VDatabase.Subframe_Conn.BushARB_Tr3Ro3_SLGf_MacP;
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAF','BushLink_AxRad_SLGf_5LS2R_UAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UAR','BushLink_AxRad_SLGf_5LS2R_UAR');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushLink_AxRad_SLGf_5LS2R_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushLink_AxRad_SLGf_5LS2R_LAR');
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Sef_DW;
            Vehicle.Chassis.SuspA2.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Ser_DW;
        case 5
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushLink_AxRad_SLGf_S2LAF_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushLink_AxRad_SLGf_S2LAF_LAR');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushLink_AxRad_SLGf_S2LAR_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushLink_Ax3_SLGf_S2LAF_LAR');
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Sef_DW;
            Vehicle.Chassis.SuspA2.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Ser_DW;
        case 6
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushLink_AxRad_SLGf_S2LAF_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushLink_AxRad_SLGf_S2LAF_LAR');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushLink_AxRad_SLGf_S2LAF_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushLink_Ax3_SLGf_S2LAF_LAR');
            Vehicle.Chassis.SuspA1.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Sef_DW;
            Vehicle.Chassis.SuspA2.AntiRollBar.SubframeConnection = VDatabase.Subframe_Conn.BushARB_Ax3_Ser_DW;
        case 7
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAF','BushLink_AxRad_SLGf_S2LAR_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LAR','BushLink_AxRad_SLGf_S2LAR_LAR');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAF','BushLink_AxRad_SLGf_S2LAR_LAF');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LAR','BushLink_Ax3_SLGf_S2LAF_LAR');
        case 8
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','BushArm_AxRad_Sef_DW_LA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','BushArm_AxRad_Sef_DW_LA');
        case 9
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A1','LA','BushArm_AxRad_Sef_DW_LA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','UA','BushArm_AxRad_Sef_DW_UA');
            Vehicle = sm_car_vehcfg_setSubframeConn(Vehicle,'A2','LA','BushArm_AxRad_Sef_DW_LA');
    end
     set_param(bdroot,'StopTime','0.5');
    sim('sm_car')
    sm_car_plot1speed
    saveas(gcf,['Test_' pad(num2str(i+size(LinkageCfgsA2,1)),3,'left','0') '.png'])
end
durSuspCA2 = toc(testSuspCA2Tic);
   
%%
DecoupCfgsA2 = {...
        'DWDecoupled_Achilles_f',                     'DWDecoupledNoSteer_Achilles_r';...
        'L5Decoupled_Achilles_f',                     'DWDecoupledNoSteer_Achilles_r'... %DUP
    };

SuspCfgsA2 = {...
        'AxleTA2PR_SUV_Landy_f',                     'AxleTA3_SUV_Landy_r';...
        'AxleTA2PR_SUV_Landy_f',                     'AxleTA4Watts_SUV_Landy_r';...  %DUP
        'Simple15DOF_Sedan_Hamba_f',                 'LiveAxle_Sedan_Hamba_r';...
        'Simple15DOF_Sedan_Hamba_f',                 'TwistBeam_Sedan_Hamba_r';...   %DUP
        'Simple15DOF_Sedan_Hamba_f',                 'Simple15DOF_Sedan_Hamba_r'...   %DUP
    };

%% Process results
res_out_titles = {'Run' 'A1' 'A2' '# Steps' 'Time' 'Figure' 'Pass'};

clear res_out
for testnum=1:length(sm_car_res)
    if (strcmpi(sm_car_res(testnum).figname,'failed'))
        fig_hyperlink =  ' ';
    else
        fig_hyperlink =  ['=HYPERLINK(".\' results_foldername '\'  sm_car_res(testnum).figname '";"figure")'];
    end
    res_out(testnum,1:7) = {...
        num2str(testnum), ...
        sm_car_res(testnum).A1, ...
        sm_car_res(testnum).A2, ...
        sm_car_res(testnum).nStp, ...
        sm_car_res(testnum).Elap, ...
        fig_hyperlink,...
        sm_car_res(testnum).result};
end

sheetname = [version('-release') '_' now_string];
computername = getenv('COMPUTERNAME');
filename = which('sm_car_testcomp.xlsx');
xlswrite(filename,res_out_titles,sheetname,'A1');
xlswrite(filename,res_out,sheetname,'A2');
xlswrite(filename,{['''' datestr(now)]},sheetname,'S1');
xlswrite(filename,{['''' computername]},sheetname,'S2');
xlswrite(filename,{['''' version]},sheetname,'S3');
xlswrite(filename,{['''' 'MF-Swift Version: ' sm_car_check_mfswiftversion]},sheetname,'S4');

