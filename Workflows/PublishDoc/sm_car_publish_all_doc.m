%% Publish Main Model
bdclose all

cd(fileparts(which('sm_car.slx')))
cd('Overview')

warning('off','Simulink:Engine:MdlFileShadowedByFile');
warning('off','Simulink:Harness:WarnABoutNameShadowingOnActivation');

publish('sm_car.m','showCode',false)

%% Publish KnC Quarter Car Testrig
cd(fileparts(which('sm_car.slx')))
cd(['Testrigs'  filesep 'Quarter_Car'])
publish('testrig_quarter_car_results.m','showCode',false)
publish('testrig_quarter_car_pullrod_results.m','showCode',false)
publish('testrig_quarter_car_doublewishbone_results.m','showCode',false)

%% Publish KnC Susp Linkage Testrig
cd(fileparts(which('sm_car.slx')))
cd(['Testrigs'  filesep 'Half_Car'])

publish('testrig_susp_knc_results.m','showCode',false)

%% Publish Quarter Car Optimization Doc
bdclose('testrig_quarter_car')
close all
cd(fileparts(which('testrig_quarter_car_sweep_optim_test.m')))
publish('testrig_quarter_car_sweep_optim_test.m')

%% Publish Full Vehicle Optimization Doc
bdclose('sm_car')
close all
cd(fileparts(which('sm_car_sweep_optim_test.m')))
publish('sm_car_sweep_optim_test.m')

%% Republish Main Script
cd(fileparts(which('Simscape_Vehicle_Library_Demo_Script.m')))
sscRepublishDemoScript('Simscape_Vehicle_Library_Demo_Script.m')

%% Republish Plotter Doc
cd(fileparts(which('sm_car_plot3d_overview.m')))
publish('sm_car_plot3d_overview.m')

%% Republish Exercises
cd(fileparts(which('Simscape_Vehicle_Templates_Exercises_test_all.m')))
Simscape_Vehicle_Templates_Exercises_test_all

cd(fileparts(which('Simscape_Vehicle_Templates_Exercises.m')))
sscRepublishDemoScript('Simscape_Vehicle_Templates_Exercises.m');

%% Republish Testing Examples
cd(fileparts(which('sm_car_test_torque_vectoring.m')))
testFileList = {...
    'sm_car_test_batt2mot_regen1',...
    'sm_car_test_torque_vectoring',...
    'sm_car_test_four_wheel_steering',...
    'sm_car_test_steerbywire',...
    'sm_car_test_abs',...
    'sm_car_test_parking',...
    'sm_car_test_dlc_reverse',...
    'sm_car_test_hydropneu_susp',...
    'sm_car_test_gen_data_lut_susp'
    };

for test_i = 1:length(testFileList)
    disp(['Test ' num2str(test_i) ' of ' num2str(length(testFileList)) ': ' testFileList{test_i}])
    evalin('base',['run(''' testFileList{test_i} '.m'')']);
    saveas(gcf,['' testFileList{test_i} '.png' '']);
    close(gcf)
end

%% Republish Powertrain Configurations
cd(fileparts(which('sm_car_testing_powertrain_configs.m')))
publish('sm_car_testing_powertrain_configs.m','showCode',true)

%% Republish Lookup Table Data Gen Workflow
%  --  Set Generate data to true inside file --
cd(fileparts(which('sm_car_test_gen_data_lut_susp.m')))
publish('sm_car_test_gen_data_lut_susp.m','showCode',false)

