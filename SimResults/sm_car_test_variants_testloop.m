% Script to run set of tests for full variant testing of sm_car
% Following variables must exist in workspace (shown with example values)
%  manv_set = {'WOT Braking','Low Speed Steer','Turn'};
%  solver_typ = {'fixed step'};
%  veh_set = [4 116 124 141 143];
%  trailer_set = {'none'};
%  plotstr = {'sm_car_plot1speed'};
%
% Copyright 2019-2021 The MathWorks, Inc.

% Loop over set of vehicles
for veh_i = 1:length(veh_set)

    % Loop over set of trailers
    for trl_i = 1:length(trailer_set)

        % Load Vehicle and trailer data
        if(isnumeric(veh_set(veh_i)))
            veh_suffix = pad(num2str(veh_set(veh_i)),3,'left','0');
        else
            veh_suffix = veh_set{veh_i};
        end
        % Load vehicle data, do not trigger variant selection
        sm_car_load_vehicle_data('none',veh_suffix);
        
        % Load trailer data, enable/disable trailer, trigger variant
        % selection if trailer not 'none'
        sm_car_load_trailer_data(mdl,trailer_set{trl_i});

        % Loop over all solver types to be tested
        for slv_i = 1:length(solver_typ)
            sm_car_config_solver(mdl,solver_typ{slv_i});
            
            % Loop over set of maneuvers
            for m_i = 1:length(manv_set) 
                testnum = testnum+1;  % Increment index of tests run
                sm_car_res(testnum).Mane = manv_set{m_i};
                sm_car_config_maneuver(mdl,manv_set{m_i});
                
                % Some maneuvers change vehicle type (CRG)
                sm_car_config_vehicle(mdl); 
                
                % If necessary, change controller
                if(~strcmp(control_chg,'none'))
                    set_param([mdl '/Controller'],'popup_control',control_chg)
                end
                
                % Assemble suffix for results image
                trailer_type = sm_car_vehcfg_getTrailerType(bdroot);
                if(contains(lower(Trailer.config),'unstable') && ~strcmpi(trailer_type,'none'))
                    trailer_type = 'U';
                end
                Maneuver_suffix = char(maneuver_list(strcmp(maneuver_list(:,1),manv_set{m_i}),2));
                suffix_str = ['Ca' veh_suffix 'Tr' trailer_type(1) '_Ma' Maneuver_suffix '_' get_param(bdroot,'Solver')];
                test_suffix     = pad(num2str(testnum),3,'left','0');
                filenamefig = [mdl '_' now_string '_' test_suffix '_' suffix_str];
                disp_str = suffix_str;
                
                disp(['Run ' num2str(testnum) ' ' disp_str '****']);
                
                % Save portion of test configuration to results variable
                sm_car_res(testnum).Cars = Vehicle.config;
                sm_car_res(testnum).Solv = get_param(bdroot,'Solver');
                
                %set_param(mdl,'FastRestart','on')
                %  Simulation for 1e-3 to eliminate initialization time'
                %  --- Removed to save compile time, check sim duration
                %temp_init_run = sim(mdl,'StopTime','1e-3'); % Eliminate init time
                
                out = [];
                try
                    out = sim(mdl);  % Unique for ABS Test
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
                    
                    for plot_i=1:length(plotstr)
                    eval(plotstr{plot_i}) % Plots are unique
                    
                    saveas(gcf,['.\' results_foldername '\' filenamefig '_' num2str(plot_i) '.png']);
                    end                    
                    figname = [filenamefig '_1.png'];
                    
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
                sm_car_res(testnum).trailer_type = sm_car_vehcfg_getTrailerType(mdl);
            end
        end
    end
end

sm_car_load_trailer_data(mdl,'none');