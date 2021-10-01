Simulink.sdi.clear
cd(fileparts(which('sm_car_ex01_damping_wot.m')))
publish('sm_car_ex01_damping_wot.m','showCode',true)
bdclose('sm_car');
Simulink.sdi.clear

cd(fileparts(which('sm_car_ex02_stepsteer.m')))
publish('sm_car_ex02_stepsteer.m','showCode',true)
bdclose('sm_car');
Simulink.sdi.clear

cd(fileparts(which('sm_car_ex03_dlc_arb.m')))
publish('sm_car_ex03_dlc_arb.m','showCode',true)
Simulink.sdi.clear

% Requires results of previous exercise
cd(fileparts(which('sm_car_vehicle_metrics_soln.mlx')))
sm_car_vehicle_metrics_soln

cd(fileparts(which('sm_car_05_sweep_arb.mlx')))
sm_car_05_sweep_arb
Simulink.sdi.clear

bdclose('sm_car');

cd(fileparts(which('sm_car_ex06_regen_2motor.m')))
publish('sm_car_ex06_regen_2motor.m','showCode',true)
bdclose('sm_car');
Simulink.sdi.clear

cd(fileparts(which('sm_car_ex07_tankerslosh.m')))
publish('sm_car_ex07_tankerslosh.m','showCode',true)

