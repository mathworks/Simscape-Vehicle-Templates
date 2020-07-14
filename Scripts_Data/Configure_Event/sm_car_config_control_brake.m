function sm_car_config_control_brake(mdl,ctrl_opt)
%sm_car_config_control_brake  Set option for brake controller
%
% ctrl_opt      0   ABS control disabled
%               1   ABS control enabled
%
% Copyright 2018-2020 The MathWorks, Inc.

bc_h = find_system(mdl,'Name','Brake Control');
if(ctrl_opt)
    set_param(char(bc_h),'popup_brake_control','ABS');
else
    set_param(char(bc_h),'popup_brake_control','Pedal');
end