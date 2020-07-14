%{
% LIST OF MANEUVERS AND LETTERS
maneuver_vnt = {'CRG Mallory Park','CRG Mallory Park F', 'Mallory Park Obstacle', 'MCity', 'CRG Kyalami','CRG Kyalami F','CRG Nurburgring N','CRG Nurburgring N F','CRG Suzuka','CRG Suzuka F','CRG Pikes Peak','CRG Pikes Peak Down'};
mane_vnt = {'Q' 'K' 'B' 'G' 'J' 'U' 'N' 'O' 'Y' 'Z' 'E' 'F'};

maneuver_vnt = {'Double Lane Change','Ice Patch','CRG Slope'};
mane_vnt = {'D','I','S'};

maneuver_vnt = {'Mallory Park','Mallory Park CCW'};
mane_vnt = {'M','C'};

maneuver_vnt = {'WOT Braking','Low Speed Steer','Turn'};
mane_vnt = {'W','L','T'};

maneuver_vnt = {'Trailer Disturbance'};
mane_vnt = {'X'};

maneuver_vnt = {'Testrig 4 Post'};
mane_vnt = {'P'};

maneuver_vnt = {'Skidpad'};
mane_vnt = {'K'};

maneuver_vnt = {'Ice Patch'};
mane_vnt = {'A'};

maneuver_vnt = {'RDF Plateau','RDF Rough Road'};
mane_vnt = {'H','R'};
%}

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

testnum = 0;
clear sm_car_res
now_string = datestr(now,'yymmdd_HHMM');

num_config = size(whos('-regexp','Vehicle_[0-9].*'),1);

results_foldername = [mdl '_' now_string];
mkdir(results_foldername)

% Set of tests
mane_vnt = {'WOT Braking','Low Speed Steer'};
%mane_vnt = {'Turn'};
%solver_typ = {'variable step','fixed step'};
solver_typ = {'variable step'};

%veh_cfg_set1 = [0:1:15 16:16:112 113:1:127];
veh_set1 = [0:1:15 16:16:112 113:1:127 128:1:147 161 163];
%veh_set1 = [136:1:140 143:146];

% Loop over all vehicle configuration presets
for veh_i = 1:length(veh_set1)
    
    % Trigger setting of variants
    veh_suffix = pad(num2str(veh_set1(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    
    % Disable warnings that come from Delft-Tyre
    warning('off','Simulink:blocks:AssumingDefaultSimStateForSFcn');
    warning('off','Simulink:blocks:AssumingDefaultSimStateForL2MSFcn');
    warning('off','physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask');
    
    % Loop over all solver types to be tested
    for slv_i = 1:length(solver_typ)
        sm_car_config_solver(mdl,solver_typ{slv_i});
        sm_car_config_vehicle(mdl);
        
        set_param(mdl,'FastRestart','on')
        
        %  Simulation for 1e-3 to eliminate initialization time'
        temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
        
        %  Loop over set of maneuvers
        for m_i = 1:length(mane_vnt)
            testnum = testnum+1;
            
            sm_car_config_maneuver(mdl,mane_vnt{m_i});
            sm_car_res(testnum).Mane = mane_vnt{m_i};
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
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
                
                subplot(221)
                text(0.05,0.85,sprintf('%s\n%s',strrep(Vehicle.config,'_','\_'),get_param(bdroot,'Solver')),...
                    'Color',[1 1 1]*0.5,'Units','Normalized')
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

set_param(mdl,'FastRestart','off') % Change test config

%% Short Maneuvers
maneuver_vnt = {'Double Lane Change','Ice Patch','CRG Slope'};
mane_vnt = {'D','I','S'};
solver_typ = {'variable step'};

%veh_suffix = pad(num2str(137),3,'left','0'); % Use stiff spring damper
veh_suffix = pad(num2str(140),3,'left','0'); % Use stiff spring damper

veh_set2 = [12 142 145];

for veh_i = 1:length(veh_set2)
    % Trigger setting of variants
    veh_suffix = pad(num2str(veh_set2(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            
            testnum = testnum+1;
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            sm_car_config_vehicle(mdl); % Some maneuvers change vehicle type (CRG)
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
                logsout_VehBus = logsout_sm_car.get('VehBus');
                logsout_xCar = logsout_VehBus.Values.World.x;
                logsout_yCar = logsout_VehBus.Values.World.y;
                px0 = logsout_xCar.Data(1);
                py0 = logsout_yCar.Data(1);
                nStp = length(logsout_xCar.Time);
                xFin = logsout_xCar.Data(end)-px0;
                yFin = logsout_yCar.Data(end)-py0;
                
                sm_car_plot1speed
                
                subplot(221)
                text(0.05,0.85,sprintf('%s\n%s',strrep(Vehicle.config,'_','\_'),get_param(bdroot,'Solver')),...
                    'Color',[1 1 1]*0.5,'Units','Normalized')
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

%% Long Maneuvers
maneuver_vnt = {'Mallory Park','Mallory Park CCW'};
mane_vnt = {'M','C'};
solver_typ = {'variable step'};

veh_set3 = [12 142 116 143 164 165];

for veh_i = 1:length(veh_set3)
    veh_suffix = pad(num2str(veh_set3(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    
    if(veh_set3(veh_i) == 164)
        Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric2Motor_default');
        Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');
        Vehicle.config = 'Hamba_E2shaCDOF_MFeval_steady_fCVpCVr1D';
    end
    if(veh_set3(veh_i) == 165)
        Vehicle = sm_car_vehcfg_setDrv(Vehicle,'fCVpCVr1D_3sh_SH');
        Vehicle = sm_car_vehcfg_setPower(Vehicle,'Electric3Motor_default');
        Vehicle = sm_car_vehcfg_setPowerCooling(Vehicle,'Active_1_Loop');
        Vehicle.config = 'Hamba_E3shaC15DOF_Delft_steady_fCVpCVr1D';
    end
        
    sm_car_config_vehicle(mdl);
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
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
    end
end

%% Steering
maneuver_vnt = {'Low Speed Steer'};
mane_vnt = {'L'};
solver_typ = {'variable step'};

veh_set4 = [151:155];

for veh_i = 1:length(veh_set4)
    veh_suffix = pad(num2str(veh_set4(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
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
    end
end

%% Fixed Step Simple Suspension
maneuver_vnt = {'WOT Braking','Low Speed Steer','Turn'};
mane_vnt = {'W','L','T'};
solver_typ = {'fixed step'};

veh_set5 = [4 116 124 141 143];

for veh_i = 1:length(veh_set5)
    veh_suffix = pad(num2str(veh_set5(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
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
    end
end


%% Trailers
maneuver_vnt = {'Double Lane Change'};
mane_vnt = {'D'};
solver_typ = {'variable step'};

veh_set6 = [139 002 143];
trailer_set = {'none','01','02'};

for veh_i = 1:length(veh_set6)
    for trl_i = 1:length(trailer_set)
        veh_suffix = pad(num2str(veh_set6(veh_i)),3,'left','0');
        eval(['Vehicle = Vehicle_' veh_suffix ';']);
        sm_car_load_trailer_data('sm_car',trailer_set{trl_i});
        sm_car_config_vehicle(mdl);
        
        for m_i = 1:length(maneuver_vnt)
            for slv_i = 1:length(solver_typ)
                sm_car_config_solver(mdl,solver_typ{slv_i});
                testnum = testnum+1;
                
                sm_car_res(testnum).Mane = maneuver_vnt{m_i};
                sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
                
                % Assemble suffix for results image
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
                filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
                disp_str = suffix_str;
                
                % disp(' ')
                disp(['Run ' num2str(testnum) ' ' disp_str '****']);
                
                % Save portion of test configuration to results variable
                sm_car_res(testnum).Cars = Vehicle.config;
                sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
                
                %set_param(mdl,'FastRestart','on')
                %  Simulation for 1e-3 to eliminate initialization time'
                sm_car_config_vehicle(mdl);
                
                temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
                
                %out = [];
                try
                    out = sim(mdl);
                    test_success = 'Pass';
                catch
                    Elapsed_Sim_Time = toc;
                    test_success = 'Fail';
                end
                
                %set_param(mdl,'FastRestart','off') % Change test config
                
                if(~isempty(out))
                    % Simulation succeeded
                    %logsout_sm_car = out.logsout_sm_car;
                    logsout_VehBus = logsout_sm_car.get('VehBus');
                    logsout_xCar = logsout_VehBus.Values.World.x;
                    logsout_yCar = logsout_VehBus.Values.World.y;
                    px0 = logsout_xCar.Data(1);
                    py0 = logsout_yCar.Data(1);
                    nStp = length(logsout_xCar.Time);
                    xFin = logsout_xCar.Data(end)-px0;
                    yFin = logsout_yCar.Data(end)-py0;
                    
                    sm_car_plot1speed
                    subplot(2,2,3);
                    
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
end

sm_car_load_trailer_data('sm_car','none');

%% Trailer Disturbance
maneuver_vnt = {'Trailer Disturbance'};
mane_vnt = {'X'};
solver_typ = {'variable step'};

veh_set7 = [139];
trailer_set = {'01','05'};

for veh_i = 1:length(veh_set7)
    for trl_i = 1:length(trailer_set)
        veh_suffix = pad(num2str(veh_set7(veh_i)),3,'left','0');
        eval(['Vehicle = Vehicle_' veh_suffix ';']);
        sm_car_load_trailer_data('sm_car',trailer_set{trl_i});
        sm_car_config_vehicle(mdl);
        
        for m_i = 1:length(maneuver_vnt)
            for slv_i = 1:length(solver_typ)
                sm_car_config_solver(mdl,solver_typ{slv_i});
                testnum = testnum+1;
                
                sm_car_res(testnum).Mane = maneuver_vnt{m_i};
                sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
                
                % Assemble suffix for results image
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                if(contains(lower(Trailer.config),'unstable'))
                    trailer_type = 'U';
                end
                
                suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
                filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
                disp_str = suffix_str;
                
                % disp(' ')
                disp(['Run ' num2str(testnum) ' ' disp_str '****']);
                
                % Save portion of test configuration to results variable
                sm_car_res(testnum).Cars = Vehicle.config;
                sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
                
                %set_param(mdl,'FastRestart','on')
                %  Simulation for 1e-3 to eliminate initialization time'
                sm_car_config_vehicle(mdl);
                
                temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
                
                %out = [];
                try
                    out = sim(mdl);
                    test_success = 'Pass';
                catch
                    Elapsed_Sim_Time = toc;
                    test_success = 'Fail';
                end
                
                %set_param(mdl,'FastRestart','off') % Change test config
                
                if(~isempty(out))
                    % Simulation succeeded
                    %logsout_sm_car = out.logsout_sm_car;
                    logsout_VehBus = logsout_sm_car.get('VehBus');
                    logsout_xCar = logsout_VehBus.Values.World.x;
                    logsout_yCar = logsout_VehBus.Values.World.y;
                    px0 = logsout_xCar.Data(1);
                    py0 = logsout_yCar.Data(1);
                    nStp = length(logsout_xCar.Time);
                    xFin = logsout_xCar.Data(end)-px0;
                    yFin = logsout_yCar.Data(end)-py0;
                    
                    sm_car_plot1speed
                    subplot(2,2,3);
                    
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
end

sm_car_load_trailer_data('sm_car','none');


%% Testrig
maneuver_vnt = {'Testrig 4 Post'};
mane_vnt = {'P'};
solver_typ = {'variable step'};

veh_set7 = [149];
load Vehicle_149
for veh_i = 1:length(veh_set7)
    veh_suffix = pad(num2str(veh_set7(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
                logsout_VehBus = logsout_sm_car.get('VehBus');
                logsout_xCar = logsout_VehBus.Values.World.x;
                logsout_yCar = logsout_VehBus.Values.World.y;
                px0 = logsout_xCar.Data(1);
                py0 = logsout_yCar.Data(1);
                nStp = length(logsout_xCar.Time);
                xFin = logsout_xCar.Data(end)-px0;
                yFin = logsout_yCar.Data(end)-py0;
                
                sm_car_plot5bodymeas
                
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

%% Skidpad
maneuver_vnt = {'Skidpad'};
mane_vnt = {'K'};
solver_typ = {'variable step'};

veh_set8 = [139];
load Vehicle_139
for veh_i = 1:length(veh_set8)
    veh_suffix = pad(num2str(veh_set8(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
                logsout_VehBus = logsout_sm_car.get('VehBus');
                logsout_xCar = logsout_VehBus.Values.World.x;
                logsout_yCar = logsout_VehBus.Values.World.y;
                px0 = logsout_xCar.Data(1);
                py0 = logsout_yCar.Data(1);
                nStp = length(logsout_xCar.Time);
                xFin = logsout_xCar.Data(end)-px0;
                yFin = logsout_yCar.Data(end)-py0;
                
                sm_car_plot1speed
                subplot(2,2,3);
                
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

%% ABS Test
maneuver_vnt = {'Ice Patch'};
mane_vnt = {'A'};
solver_typ = {'variable step'};

veh_set9 = {'hamba' 'hambalg'};
veh_suffix_set = [156 130];

for veh_i = 1:length(veh_set9)
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            veh_suffix = pad(num2str(veh_suffix_set(veh_i)),3,'left','0');
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
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

%% RDF Plateau
maneuver_vnt = {'RDF Plateau','RDF Rough Road'};
mane_vnt = {'H','R'};
solver_typ = {'variable step'};

veh_set10 = [140 146];

for veh_i = 1:length(veh_set10)
    veh_suffix = pad(num2str(veh_set10(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    
    if(veh_i == 1)
        hold_config = Vehicle.config;
        % Must use Delft Tire Software for RDF tests
        Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_213_40R21','front');
        Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
        Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','front');
        Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','front');
        Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_213_40R21','rear');
        Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');
        Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','rear');
        Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','rear');
        % Put original config string back in Vehicle.config
        Vehicle.config = hold_config;
        Vehicle.config = strrep(Vehicle.config,'MFSwift','Delft');
    end
    if(veh_i == 2)
        % Save configuration - needed for post-processing
        hold_config = Vehicle.config;
        
        % Take driver and people out of bus so it goes straight
        % Modifies Vehicle.config
        Vehicle = sm_car_vehcfg_setPeopleOnOff(Vehicle,[0 0 0 0 0]);

        % Must use Delft Tire Software for RDF tests
        Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_270_70R22','front');
        Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','front');
        Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','front');
        Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','front');
        Vehicle = sm_car_vehcfg_setTire(Vehicle,'Delft_CAD_270_70R22','rear');
        Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,'steady','rear');
        Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,'combined','rear');
        Vehicle = sm_car_vehcfg_setTireContact(Vehicle,'smooth','rear');
        
        % Put original config string back in Vehicle.config
        Vehicle.config = hold_config;
        Vehicle.config = strrep(Vehicle.config,'MFSwift','Delft');
    end
    
    sm_car_config_vehicle(mdl);
    
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
                logsout_VehBus = logsout_sm_car.get('VehBus');
                logsout_xCar = logsout_VehBus.Values.World.x;
                logsout_yCar = logsout_VehBus.Values.World.y;
                px0 = logsout_xCar.Data(1);
                py0 = logsout_yCar.Data(1);
                nStp = length(logsout_xCar.Time);
                xFin = logsout_xCar.Data(end)-px0;
                yFin = logsout_yCar.Data(end)-py0;
                
                sm_car_plot1speed
                subplot(2,2,3);
                
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

%% CRG Tests
maneuver_vnt = {'CRG Mallory Park','CRG Mallory Park F', 'Mallory Park Obstacle', 'MCity', 'CRG Kyalami','CRG Kyalami F','CRG Nurburgring N','CRG Nurburgring N F','CRG Suzuka','CRG Suzuka F','CRG Pikes Peak','CRG Pikes Peak Down'};
mane_vnt = {'Q' 'K' 'B' 'G' 'J' 'U' 'N' 'O' 'Y' 'Z' 'E' 'F'};
solver_typ = {'variable step'};

veh_set11 = [170];

for veh_i = 1:length(veh_set11)
    veh_suffix = pad(num2str(veh_set11(veh_i)),3,'left','0');
    eval(['Vehicle = Vehicle_' veh_suffix ';']);
    sm_car_config_vehicle(mdl);
    
    for m_i = 1:length(maneuver_vnt)
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            testnum = testnum+1;
            
            sm_car_res(testnum).Mane = maneuver_vnt{m_i};
            sm_car_config_maneuver(mdl,maneuver_vnt{m_i});
            
            % Assemble suffix for results image
            trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
            suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' mane_vnt{m_i}(1) '_' get_param(bdroot,'Solver')];
            filenamefig = [mdl '_' now_string '_' suffix_str '.png'];
            disp_str = suffix_str;
            
            % disp(' ')
            disp(['Run ' num2str(testnum) ' ' disp_str '****']);
            
            % Save portion of test configuration to results variable
            sm_car_res(testnum).Cars = Vehicle.config;
            sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
            
            %set_param(mdl,'FastRestart','on')
            %  Simulation for 1e-3 to eliminate initialization time'
            sm_car_config_vehicle(mdl);
            
            temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
            
            %out = [];
            try
                out = sim(mdl);
                test_success = 'Pass';
            catch
                Elapsed_Sim_Time = toc;
                test_success = 'Fail';
            end
            
            %set_param(mdl,'FastRestart','off') % Change test config
            
            if(~isempty(out))
                % Simulation succeeded
                %logsout_sm_car = out.logsout_sm_car;
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
    end
end

sm_car_load_trailer_data('sm_car','none');

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
