function sm_car_config_control_brake(mdl,ctrl_opt)
%sm_car_config_control_brake  Set option for brake controller
%
% ctrl_opt      0   ABS control disabled
%               1   ABS control enabled
%
% Copyright 2018-2022 The MathWorks, Inc.

% NOTE - Set find options carefully.
%        DO NOT let it search for AllVariants without compiling 
f    = Simulink.FindOptions('FollowLinks',1,'LookUnderMasks','All','Variants','ActiveVariants');
bc_h = Simulink.findBlocks(mdl,'Name','Brake Control',f);

if(~isempty(bc_h))
    if(ctrl_opt)
        set_param(bc_h,'popup_brake_control','ABS');
    else
        set_param(bc_h,'popup_brake_control','Pedal');
    end
else
    warning('Brake Control system not found');
end