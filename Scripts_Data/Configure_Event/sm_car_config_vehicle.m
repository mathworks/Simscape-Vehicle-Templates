function sm_car_config_vehicle(mdl)
%sm_car_config_vehicle  Select variants for Simscape Vehicle model
%   sm_car_config_vehicle(block)
%   This function triggers mask initialization code to select variants
%   within model based on mask parameters.
%
% Copyright 2018-2020 The MathWorks, Inc.

f=Simulink.FindOptions('FollowLinks',0,'LookUnderMasks','none','RegExp',1);
h=Simulink.findBlocks(mdl,'InitTriggerDropdown','.*',f);

for i=1:length(h)
    set_param(h(i),'InitTriggerDropdown','0');
    set_param(h(i),'InitTriggerDropdown','1');
end
