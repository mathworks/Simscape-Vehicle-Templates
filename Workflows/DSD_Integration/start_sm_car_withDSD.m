bdclose('sm_car')
mdl = 'sm_car_Axle3_withDSD';
open_system(mdl)
helperAEBSetUp_4smcar
set_param([mdl '/World'],'popup_scene','Road Two Lane');
