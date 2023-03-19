% Script to test Multibody Tire configurations under many events
% Copyright 2019-2023 The MathWorks, Inc.

maneuver_list = {...
    'CRG Mallory Park',       'CMP';
    'CRG Mallory Park F',     'CMF';
    'CRG Kyalami',            'CKY';
    'CRG Kyalami F',          'CKF';
    'CRG Nurburgring N',      'CNN';
    'CRG Nurburgring N F',    'CNF';
    'CRG Suzuka',             'CSZ';
    'CRG Suzuka F',           'CSF';
    'CRG Pikes Peak',         'CPU';
    'CRG Pikes Peak Down',    'CPD';
    'CRG Plateau',            'CPL';
    'Mallory Park Obstacle',  'MPO';
    'Mallory Park',           'MPK';
    'Mallory Park CCW'        'MPC';
    'MCity',                  'MCI';
    'Double Lane Change',     'DLC';
    'Ice Patch',              'IPA';
    'CRG Slope',              'CSL';
    'WOT Braking',            'WOT';
    'Low Speed Steer',        'LSS';
    'Turn',                   'TUR';
    'Trailer Disturbance',    'TRD';
    'Testrig 4 Post'          'PST';
    'Skidpad',                'SKD';
    'Constant Radius Closed-Loop', 'RAD';
    'RDF Plateau',            'RDP';
    'RDF Rough Road',         'RDR';
    'Plateau Z Only',         'ZPL';
    'Rough Road Z Only',      'ZRR';
    'Drive Cycle FTP75',      'DCA';
    'Drive Cycle UrbanCycle1','DC1';
    };


% Script to test many configurations of vehicle model
prompt = {'Enter comment for test'};
dlgtitle = 'Comment for test sweep';
dims = [1 35];
definput = {''};
answer = inputdlg(prompt,dlgtitle,dims,definput);

% Generate and load all vehicle presets
sm_car_assemble_presets

cd(fileparts(which('Vehicle_000.mat')));
veh_data_sets = dir('Vehicle*.mat');
for vds_i=1:length(veh_data_sets)
    load(veh_data_sets(vds_i).name)
end
clear veh_data_sets vds_i

load Vehicle_000
Vehicle = Vehicle_000;

mdl = 'sm_car';
cd(fileparts(which(mdl)));
cd('SimResults')

% Open and configure model for fast simulations
open_system(mdl);
set_param([mdl '/Camera Frames'],'Commented','on');
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off');
sm_car_config_road(mdl,'Plane Grid')
sm_car_config_maneuver(mdl,'WOT Braking');
sm_car_load_trailer_data('sm_car','none');

% Disable warnings that come from Delft-Tyre
warning('off','Simulink:blocks:AssumingDefaultSimStateForSFcn');
warning('off','Simulink:blocks:AssumingDefaultSimStateForL2MSFcn');
warning('off','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');       

testnum = 0;
clear sm_car_res
now_string = datestr(now,'yymmdd_HHMM');

num_config = size(whos('-regexp','Vehicle_[0-9].*'),1);
results_foldername = [mdl '_' now_string];
results_foldername = ['MbodyTests_' now_string];
%results_foldername = 'sm_car_201121_0028';
mkdir(results_foldername)

control_chg = 'none';


%% Test Set 1 - Hamba Default
manv_set = {'WOT Braking','Turn','Mallory Park','Double Lane Change','Mallory Park Obstacle'};
solver_typ = {'variable step'};
veh_set = [140 189];
trailer_set = {'none'};
plotstr = {'sm_car_plot1speed','sm_car_plot10_tire_force_torque'};
sm_car_test_variants_testloop

%% Test Set 2 - Hamba 15 DOF
manv_set = {'WOT Braking','Turn','Mallory Park','Double Lane Change','Mallory Park Obstacle'};
solver_typ = {'variable step'};
veh_set = [165 193];
trailer_set = {'none'};
plotstr = {'sm_car_plot1speed','sm_car_plot10_tire_force_torque'};
sm_car_test_variants_testloop

%% Test Set 3 - Makhulu 6 Wheels
manv_set = {'WOT Braking','Turn','Mallory Park','Double Lane Change','Mallory Park Obstacle'};
solver_typ = {'variable step'};
veh_set = [145 199];
trailer_set = {'none'};
plotstr = {'sm_car_plot1speed','sm_car_plot10_tire_force_torque'};

% Temporary increase in throttle
MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value = MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value*2;
sm_car_test_variants_testloop
MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value = MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value/2;

%% Switch to 3-Axle model
set_param([mdl '/Camera Frames'],'Commented','off');
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','on');
bdclose(mdl)

mdl = 'sm_car_Axle3';
open_system(mdl);
set_param([mdl '/Camera Frames'],'Commented','on');
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off');
sm_car_config_road(mdl,'Plane Grid')
sm_car_config_maneuver(mdl,'WOT Braking');
sm_car_load_trailer_data(mdl,'none');

%% Test Set 4 -- 3 Axle Bus Makhulu 6x2
manv_set = {'WOT Braking','Turn','Mallory Park','Double Lane Change','Mallory Park Obstacle'};
solver_typ = {'variable step'};
veh_set = {'Axle3_002', 'Axle3_016'};
trailer_set = {'none'};
plotstr = {'sm_car_plot1speed','sm_car_plot10_tire_force_torque'};

% Temporary increase in throttle
MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value = MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value*2;
MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value          = MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value*2;
sm_car_test_variants_testloop
MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value = MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value/2;
MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value          = MDatabase.Turn.Bus_Makhulu.Accel.rPedal.Value/2;

%% Test Set 5 -- 18 Wheels, Amandla 6x4 MF Swift
manv_set = {'WOT Braking','Turn','Mallory Park','Double Lane Change','Mallory Park Obstacle'};
solver_typ = {'variable step'};
veh_set = {'Axle3_011'};
trailer_set = {'Axle2_001'};
plotstr = {'sm_car_plot1speed','sm_car_plot10_tire_force_torque'};

% Temporary increase in throttle
MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value = MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value*2;
MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value        = MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value*2;
sm_car_test_variants_testloop
MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value = MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value/2;
MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value        = MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value/2;

%% Test Set 19 -- 3 Axle Truck Amandla trailer MFSwift
manv_set = {'WOT Braking','Turn','Mallory Park','Double Lane Change','Mallory Park Obstacle'};
solver_typ = {'variable step'};
veh_set = {'Axle3_020'};
trailer_set = {'Axle2_022'};
plotstr = {'sm_car_plot1speed','sm_car_plot10_tire_force_torque'};

% Temporary increase in throttle
MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value = MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value*2;
MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value = MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value*2;
sm_car_test_variants_testloop
MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value = MDatabase.WOT_Braking.Truck_Amandla.Accel.rPedal.Value/2;
MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value = MDatabase.Turn.Truck_Amandla.Accel.rPedal.Value/2;

%% Process results
res_out_titles = {'Run' 'Preset' 'Body' 'SuspF' 'Tire' 'TirDyn' 'Drv' 'Trail' 'Mane' 'Solv' '# Steps' 'Time' 'xFinal' 'yFinal' 'Figure'  'Pass'};

clear res_out
for testnum=1:length(sm_car_res)
    if(~isempty(sm_car_res(testnum).Cars))
        car_config_set = strsplit(sm_car_res(testnum).Cars,'_');
    else
        car_config_set = {'fail' 'fail' 'fail' 'fail' 'fail' };
    end
    if (strcmpi(sm_car_res(testnum).figname,'failed'))
        fig_hyperlink =  ' ';
    else
        fig_hyperlink =  ['=HYPERLINK(".\' results_foldername '\'  sm_car_res(testnum).figname '";"figure")'];
    end
    res_out(testnum,1:16) = {...
        num2str(testnum), ...
        sm_car_res(testnum).preset, ...
        car_config_set{1}, ...
        car_config_set{2}, ...
        car_config_set{3}, ...
        car_config_set{4}, ...
        car_config_set{5}, ...
        sm_car_res(testnum).trailer_type, ...
        sm_car_res(testnum).Mane, ...
        sm_car_res(testnum).Solv, ...
        sm_car_res(testnum).nStp, ...
        sm_car_res(testnum).Elap, ...
        sm_car_res(testnum).xFin, ...
        sm_car_res(testnum).yFin, ...
        fig_hyperlink,...
        sm_car_res(testnum).result};
end

set_param([mdl '/Camera Frames'],'Commented','off');
set_param(mdl,'SimMechanicsOpenEditorOnUpdate','on');

sheetname = [version('-release') '_' now_string];
computername = getenv('COMPUTERNAME');
filename = which('MbodyTests_results.xlsx');
xlswrite(filename,res_out_titles,sheetname,'A1');
xlswrite(filename,res_out,sheetname,'A2');
xlswrite(filename,{['''' datestr(now)]},sheetname,'R1');
xlswrite(filename,{['''' computername]},sheetname,'R2');
xlswrite(filename,{['''' version]},sheetname,'R3');
xlswrite(filename,{['''' 'MF-Swift Version: ' sm_car_check_mfswiftversion]},sheetname,'R4');
xlswrite(filename,answer,sheetname,'R5');

delvars = who('-regexp','Vehicle_\d\d\d');
clear(delvars{:},'delvars');
load('Vehicle_000');
Vehicle = Vehicle_000;
clear Vehicle_000

bdclose(mdl)
