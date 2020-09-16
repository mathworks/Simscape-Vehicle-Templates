% Script to test many configurations under many events
% Not a complete sweep of all combinations, but every variant is activated
% Copyright 2019-2020 The MathWorks, Inc.

maneuver_list = {...
    'CRG Mallory Park',      'CMP';
    'CRG Mallory Park F',    'CMF';
    'CRG Kyalami',           'CKY';
    'CRG Kyalami F',         'CKF';
    'CRG Nurburgring N',     'CNN';
    'CRG Nurburgring N F',   'CNF';
    'CRG Suzuka',            'CSZ';
    'CRG Suzuka F',          'CSF';
    'CRG Pikes Peak',        'CPU';
    'CRG Pikes Peak Down',   'CPD';
    'CRG Plateau',           'CPL';
    'Mallory Park Obstacle', 'MPO';
    'Mallory Park',          'MPK';
    'Mallory Park CCW'       'MPC';
    'MCity',                 'MCI';
    'Double Lane Change',    'DLC';
    'Ice Patch',             'IPA';
    'CRG Slope',             'CSL';
    'WOT Braking',           'WOT';
    'Low Speed Steer',       'LSS';
    'Turn',                  'TUR';
    'Trailer Disturbance',   'TRD';
    'Testrig 4 Post'         'PST';
    'Skidpad',               'SKD';
    'RDF Plateau',           'RDP';
    'RDF Rough Road',        'RDR';
    'Plateau Z Only',        'ZPL';
    'Rough Road Z Only',     'ZRR';
    'Drive Cycle FTP75',     'DCA';
    };


% Script to test many configurations of vehicle model
prompt = {'Enter comment for test'};
dlgtitle = 'Comment for test sweep';
dims = [1 35];
definput = {''};
answer = inputdlg(prompt,dlgtitle,dims,definput);

% Generate and load all vehicle presets
sm_car_vehicle_data_assemble_set

cd(fileparts(which('Vehicle_000.mat')));
veh_data_sets = dir('Vehicle*.mat');
for vds_i=1:length(veh_data_sets)
    load(veh_data_sets(vds_i).name)
end
clear veh_data_sets vds_i

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
mkdir(results_foldername)

%% Test Set 1 - Main tests in Fast Restart, no MF-Swift
manv_set = {'WOT Braking','Low Speed Steer'};
solver_typ = {'variable step'};
%veh_set1 = [0:1:15 16:16:112 113:1:127 128:1:147 161 163];
veh_set1 = [0:1:7 16:16:112 113:1:119 128:1:139 141 143 144 147];
trailer_set = {'none'};

for veh_i = 1:length(veh_set1)
    for trl_i = 1:length(trailer_set)
        veh_suffix = pad(num2str(veh_set1(veh_i)),3,'left','0');
        eval(['Vehicle = Vehicle_' veh_suffix ';']);
        sm_car_load_trailer_data('sm_car',trailer_set{trl_i});        
        sm_car_config_vehicle(mdl);
        
        % Loop over all solver types to be tested
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            
            sm_car_config_vehicle(mdl);
            
            set_param(mdl,'FastRestart','on')
            
            %  Simulation for 1e-3 to eliminate initialization time'
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %  Loop over set of maneuvers
            for m_i = 1:length(manv_set)
                testnum = testnum+1;
                
                sm_car_config_maneuver(mdl,manv_set{m_i});
                sm_car_res(testnum).Mane = manv_set{m_i};
                
                % Assemble suffix for results image
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                Maneuver_suffix = char(maneuver_list(strcmp(maneuver_list(:,1),manv_set{m_i}),2));
                suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' Maneuver_suffix '_' get_param(bdroot,'Solver')];
                filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
                disp_str = suffix_str;
                
                disp(['Run ' num2str(testnum) ' ' disp_str '****']);
                
                % Save portion of test configuration to results variable
                sm_car_res(testnum).Cars = Vehicle.config;
                sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
                
                out = [];
                try
                    out = sim(mdl);
                    test_success = 'Pass';
                catch ME
                    disp(['Error: ' ME.message ', ' ME.identifier]);
                    Elapsed_Sim_Time = toc;
                    test_success = 'Fail';
                end
                
                if(~isempty(out))
                    % Simulation succeeded
                    logsout_sm_car = out.logsout_sm_car;
                    logsout_VehBus = logsout_sm_car.get('VehBus');
                    logsout_xCar = logsout_VehBus.Values.World.x;
                    logsout_yCar = logsout_VehBus.Values.World.y;
                    px0 = logsout_xCar.Data(1);
                    py0 = logsout_yCar.Data(1);
                    nStp = length(logsout_xCar.Time);
                    xFin = logsout_xCar.Data(end)-px0;
                    yFin = logsout_yCar.Data(end)-py0;
                    
                    sm_car_plot1speed
                    
                    saveas(gcf,['.\' results_foldername '\' filenamefig]);
                    
                    figname = filenamefig;
                    
                else
                    % Simulation failed
                    nStp = -1;
                    xFin = 0;
                    yFin = 0;
                    figname = 'failed';
                end
                
                sm_car_res(testnum).Elap = Elapsed_Sim_Time;
                sm_car_res(testnum).nStp = nStp;
                sm_car_res(testnum).xFin = xFin;
                sm_car_res(testnum).yFin = yFin;
                sm_car_res(testnum).figname = figname;
                sm_car_res(testnum).result = test_success;
                sm_car_res(testnum).preset = veh_suffix;
                sm_car_res(testnum).trailer_type = sm_car_vehcfg_getTrailerType('sm_car');
            end
            set_param(mdl,'FastRestart','off') % Change test config
        end
    end
end

set_param(mdl,'FastRestart','off') % Change test config

sm_car_load_trailer_data('sm_car','none');

%% Test Set 1a - Main tests NO Fast Restart
manv_set = {'WOT Braking','Low Speed Steer'};
solver_typ = {'variable step'};
veh_set = [8:1:15 120:1:127 140 142 145 146 146 161 163];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 2: Short Maneuvers
manv_set = {'Double Lane Change','Ice Patch'};
solver_typ = {'variable step'};
veh_set = [12 142 145];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 3 -- Long Maneuvers
manv_set = {'Mallory Park','Mallory Park CCW'};
solver_typ = {'variable step'};
veh_set = [12 142 116 143 166 169];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 4 -- Steering
manv_set = {'Low Speed Steer'};
solver_typ = {'variable step'};
veh_set = [151:155];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 5 -- Fixed Step Simple Suspension
manv_set = {'WOT Braking','Low Speed Steer','Turn'};
solver_typ = {'fixed step'};
veh_set = [4 116 124 141 143];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 6 -- Trailers
manv_set = {'Double Lane Change'};
solver_typ = {'variable step'};
veh_set = [139 002 143];
trailer_set = {'none','01','02'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 7 -- Trailer Disturbance
manv_set = {'Trailer Disturbance'};
solver_typ = {'variable step'};
veh_set = [139];
trailer_set = {'01','05'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 8 -- Testrig
manv_set = {'Testrig 4 Post'};
solver_typ = {'variable step'};
veh_set = [149];
trailer_set = {'none'};
plotstr = 'sm_car_plot5bodymeas';
sm_car_test_variants_testloop

%% Test Set 9 -- Skidpad
manv_set = {'Skidpad'};
solver_typ = {'variable step'};
veh_set = [139];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 10 -- ABS Test
% TEST SETUP IS UNIQUE
manv_set = {'Ice Patch'};
solver_typ = {'variable step'};

veh_set9 = {'hamba' 'hambalg'};
veh_suffix_set = [156 130];
trailer_set = {'none'};

for veh_i = 1:length(veh_set9)
    for m_i = 1:length(manv_set)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            veh_suffix = pad(num2str(veh_suffix_set(veh_i)),3,'left','0');
            
            sm_car_res(testnum).Mane = manv_set{m_i};
            sm_car_config_maneuver(mdl,manv_set{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            Maneuver_suffix = char(maneuver_list(strcmp(maneuver_list(:,1),manv_set{m_i}),2));
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' Maneuver_suffix '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            try
                out = sm_car_abs_test(veh_set9{veh_i});
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                logsout_sm_car = out.logsout_sm_car;
                logsout_VehBus = logsout_sm_car.get('VehBus');
                logsout_xCar = logsout_VehBus.Values.World.x;
                logsout_yCar = logsout_VehBus.Values.World.y;
                px0 = logsout_xCar.Data(1);
                py0 = logsout_yCar.Data(1);
                nStp = length(logsout_xCar.Time);
                xFin = logsout_xCar.Data(end)-px0;
                yFin = logsout_yCar.Data(end)-py0;
                
                sm_car_plot2whlspeed
                %subplot(2,2,3);
                
                saveas(gcf,['.\' results_foldername '\' filenamefig]);
                
                figname = filenamefig;
                
            else
                % Simulation failed
                nStp = -1;
                xFin = 0;
                yFin = 0;
                figname = 'failed';
            end
            
            sm_car_res(testnum).Elap = Elapsed_Sim_Time;
            sm_car_res(testnum).nStp = nStp;
            sm_car_res(testnum).xFin = xFin;
            sm_car_res(testnum).yFin = yFin;
            sm_car_res(testnum).figname = figname;
            sm_car_res(testnum).result = test_success;
            sm_car_res(testnum).preset = veh_suffix;
            sm_car_res(testnum).trailer_type = sm_car_vehcfg_getTrailerType('sm_car');
        end
    end
end

sm_car_load_trailer_data('sm_car','none');

%% Test Set 11 -- RDF Plateau, Delft Tyre only
manv_set = {'RDF Plateau'};
solver_typ = {'variable step'};
veh_set = [171 172];
trailer_set = {'none'};
plotstr = 'sm_car_plot2whlspeed';
sm_car_test_variants_testloop

%% Test Set 11a -- Plateau Z Only, MFeval, MF-Swift, Delft
manv_set = {'Plateau Z Only'};
solver_typ = {'variable step'};
veh_set = [139 165 171];
trailer_set = {'none'};
plotstr = 'sm_car_plot2whlspeed';
sm_car_test_variants_testloop

%% Test Set 11b -- CRG Plateau, MF-Swift, Delft
manv_set = {'CRG Plateau'};
solver_typ = {'variable step'};
veh_set = [165 171];
trailer_set = {'none'};
plotstr = 'sm_car_plot2whlspeed';
sm_car_test_variants_testloop

%% Test Set 12 -- RDF Rough Road, Delft Tyre only
manv_set = {'RDF Rough Road'};
solver_typ = {'variable step'};
veh_set = [171 172];
trailer_set = {'none'};
plotstr = 'sm_car_plot5bodymeas';
sm_car_test_variants_testloop

%% Test Set 12a -- Rough Road Z Only, MFeval tires only
manv_set = {'Rough Road Z Only'};
solver_typ = {'variable step'};
veh_set = [139 165 171];
trailer_set = {'none'};
plotstr = 'sm_car_plot5bodymeas';
sm_car_test_variants_testloop

%% Test Set 12 -- CRG Tests
manv_set = {'CRG Mallory Park','CRG Mallory Park F', 'Mallory Park Obstacle', 'MCity', 'CRG Kyalami','CRG Kyalami F','CRG Nurburgring N','CRG Nurburgring N F','CRG Suzuka','CRG Suzuka F','CRG Pikes Peak','CRG Pikes Peak Down'};
solver_typ = {'variable step'};
veh_set = [170];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 13 -- Drive Cycle FTP75
manv_set = {'Drive Cycle FTP75'};
solver_typ = {'variable step'};
veh_set = [173 165];
trailer_set = {'none'};
plotstr = 'sm_car_plot1speed';
sm_car_test_variants_testloop

%% Test Set 14 -- CRG Plateau Fuel Cell
manv_set = {'CRG Plateau'};
solver_typ = {'variable step'};
veh_set = [173];
trailer_set = {'none'};
plotstr = 'sm_car_plot2whlspeed';
sm_car_test_variants_testloop


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
filename = which('sm_car_results.xlsx');
xlswrite(filename,res_out_titles,sheetname,'A1');
xlswrite(filename,res_out,sheetname,'A2');
xlswrite(filename,{['''' datestr(now)]},sheetname,'R1');
xlswrite(filename,{['''' computername]},sheetname,'R2');
xlswrite(filename,{['''' version]},sheetname,'R3');
xlswrite(filename,answer,sheetname,'R4');

delvars = who('-regexp','Vehicle_\d\d\d');
clear(delvars{:},'delvars');
load('Vehicle_000');
Vehicle = Vehicle_000;
clear Vehicle_000

bdclose(mdl)
