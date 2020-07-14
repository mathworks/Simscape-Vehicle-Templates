sm_car_config_solver(bdroot,'variable step')
Vehicle = Vehicle_002;
sm_car_config_vehicle(bdroot);
set_param(bdroot,'SimscapeUseOperatingPoints','off');
ssc_op_002 = sm_car_op_gen(bdroot,1);
%set_param(bdroot,'SimscapeUseOperatingPoints','on');


Vehicle = Vehicle_006;
sm_car_config_vehicle(bdroot);
set_param(bdroot,'SimscapeUseOperatingPoints','off');
ssc_op_006 = sm_car_op_gen(bdroot,1);
%set_param(bdroot,'SimscapeUseOperatingPoints','on');


Vehicle = Vehicle_007;
sm_car_config_vehicle(bdroot);
set_param(bdroot,'SimscapeUseOperatingPoints','off');
ssc_op_007 = sm_car_op_gen(bdroot,1);
%set_param(bdroot,'SimscapeUseOperatingPoints','on');
