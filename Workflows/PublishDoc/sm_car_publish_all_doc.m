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

publish('testrig_susp_linkage_results.m','showCode',false)
publish('testrig_susp_linkage_decoupled_results.m','showCode',false)

%% Publish Optimization doc
publish('testrig_quarter_car_sweep_optim_test.m')

%% Republish Main Script
cd(fileparts(which('Simscape_Vehicle_Library_Demo_Script.m')))
sscRepublishDemoScript('Simscape_Vehicle_Library_Demo_Script.m')

%% Republish Exercises
cd(fileparts(which('Simscape_Vehicle_Templates_Exercises_test_all.m')))
Simscape_Vehicle_Templates_Exercises_test_all

cd(fileparts(which('Simscape_Vehicle_Templates_Exercises.m')))
sscRepublishDemoScript('Simscape_Vehicle_Templates_Exercises.m');

