% Script to compare bus definitions in sm_car_define_bus_defs.m
% to the busses created and referenced in sm_car_lib.slx

% List of test models and vehicle data sets to test
% Final fields are to change other settings in the model
test_list = {...
    'sm_car_testrig_bus_DrvBus','Vehicle_000','','','';
    'sm_car_testrig_bus_CtrlBus','Vehicle_000','Control','popup_brake_control','Pedal';
    'sm_car_testrig_bus_CtrlBus','Vehicle_130','Control','popup_brake_control','ABS';
    'sm_car_testrig_bus_VehBusBody','Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusBrakes','Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusBrakes','Vehicle_130','','','';
    'sm_car_testrig_bus_VehBusDriveline','Vehicle_001','','','';
    'sm_car_testrig_bus_VehBusDriveline','Vehicle_002','','','';
    'sm_car_testrig_bus_VehBusPower','Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusChassisAero','Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusChassisSpring','Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusChassisSpring','Vehicle_131','','','';
    'sm_car_testrig_bus_VehBusChassisSpring','Vehicle_132','','','';
    'sm_car_testrig_bus_VehBusChassisSpring','Vehicle_133','','','';
    'sm_car_testrig_bus_VehBusChassisDamper','Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusChassisDamper','Vehicle_134','','','';
    'sm_car_testrig_bus_VehBusChassisDamper','Vehicle_135','','','';
    'sm_car_testrig_bus_VehBusChassisWhlFL', 'Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusChassisWhlFL', 'Vehicle_008','','',''; % Delft
    'sm_car_testrig_bus_VehBusChassisSuspF', 'Vehicle_000','','','';
    'sm_car_testrig_bus_VehBusChassisSuspF', 'Vehicle_064','','',''; % 5S2LAF
    };


% Loop over list of tests
for mdl_i=1:size(test_list,1)
    
    % Load model, get bus name
    mdl_h=load_system(test_list{mdl_i,1});
    nameCheckBus = get_param([getfullname(mdl_h) '/Out1'],'OutDataTypeStr');

    % Load vehicle data into workspace variable "Vehicle"
    load([test_list{mdl_i,2} '.mat'])
    Vehicle = eval(test_list{mdl_i,2});
    clear(test_list{mdl_i,2})

    % Create bus definitions based on loaded vehicle configuration
    sm_car_create_bus_defs(Vehicle);

	% Trigger variant selection (try-catch in case load takes too long)
    try
        sm_car_config_vehicle(getfullname(mdl_h))
    catch
        pause(6)
        sm_car_config_vehicle(getfullname(mdl_h))
    end
    
	% Set other settings within test model
    if(~isempty(test_list{mdl_i,3}))
        try
            set_param([getfullname(mdl_h) '/' test_list{mdl_i,3}],test_list{mdl_i,4},test_list{mdl_i,5});
        catch
            pause(3)
            set_param([getfullname(mdl_h) '/' test_list{mdl_i,3}],test_list{mdl_i,4},test_list{mdl_i,5});
        end
    end
    
	% Clear diary
    sldiagviewer.diary('off')
    if (exist('diary.txt')), delete('diary.txt'), end
    
	% One last attempt to configure variants
    sm_car_config_vehicle(getfullname(mdl_h))

    % Record diagnostics from update diagram
    sldiagviewer.diary('on')
    set_param(getfullname(mdl_h),'SimulationCommand','Start')
    sldiagviewer.diary('off')
    
    % Read diagnostics and flag critical issues in command window
    fid_o = fopen('diary.txt');
    u=fscanf(fid_o,'%s');
    fclose(fid_o);
    
    % Read diagnostics and flag critical issues in command window
    if(isempty(u) ||(isempty(findstr(u,'Warning')) && isempty(findstr(u,'Error'))))
        disp([nameCheckBus ': No errors or warnings']);
        delete('diary.txt');
    else
        busDiagFileName = ['BusDiag_' strrep(nameCheckBus,'Bus: ','') '_' test_list{mdl_i,2} '.txt'];
        movefile('diary.txt',busDiagFileName)
        dispstr1 = ['<a href="matlab:open_system(''' getfullname(mdl_h) ''');">model</a>'];
        dispstr2 = ['<a href="matlab:edit(''' busDiagFileName ''');">diagnostics</a>'];
        disp([nameCheckBus ': Warnings or errors (open ' dispstr1 ', edit ' dispstr2 ')']);
    end
    
	% Close model if a new one is used in next test
    if(mdl_i<size(test_list,1))
        if(~strcmpi(test_list{mdl_i,1},test_list{mdl_i+1,1}))
            bdclose(mdl_h);
        end
    end
end

% Close model from final test
bdclose(mdl_h);

