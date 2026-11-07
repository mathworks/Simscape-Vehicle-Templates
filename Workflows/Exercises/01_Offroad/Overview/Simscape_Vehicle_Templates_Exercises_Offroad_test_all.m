bdclose all
close all

cd(fileparts(which('offroad_ex01_msd.m')))
publish('offroad_ex01_msd.m','showCode',true)
bdclose('quarter_car_msd_2x');
close all

cd(fileparts(which('offroad_ex02_airOilSpring.m')))
publish('offroad_ex02_airOilSpring.m','showCode',true)
bdclose('testrig_AirOilPiston_multibody');
close all

cd(fileparts(which('offroad_ex03_car_bump.m')))
publish('offroad_ex03_car_bump.m','showCode',true)
bdclose('sm_car');
close all

cd(fileparts(which('offroad_ex04_car_steer.m')))
publish('offroad_ex04_car_steer.m','showCode',true)
bdclose('sm_car');
close all


