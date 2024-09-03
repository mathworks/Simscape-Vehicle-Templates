function sm_car_config_control_brake(mdl,ctrl_opt)
%sm_car_config_control_brake  Set option for brake controller
%
% ctrl_opt      0   ABS control disabled
%               1   ABS control enabled
%
% Copyright 2018-2024 The MathWorks, Inc.

blk = find_system(mdl,'regexp','on','SearchDepth',1,'popup_brake_control','.*');

if(~isempty(blk))
    if(ctrl_opt)
        set_param(blk{1},'popup_brake_control','ABS');
    else
        set_param(blk{1},'popup_brake_control','Pedal');
    end
else
    warning('Brake Control system not found');
end
