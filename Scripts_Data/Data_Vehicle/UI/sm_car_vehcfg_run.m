% Script to run (instead of edit) vehicle configuration app
% and ensure only one copy of the UI is opened.

% Copyright 2019-2021 The MathWorks, Inc.

if(exist('sm_car_vehcfg_uifigure','var'))
    if(length(sm_car_vehcfg_uifigure.findprop('UIFigure'))==1)
        % Figure is already open, bring it to the front
        figure(sm_car_vehcfg_uifigure.UIFigure);
    else
        % Open UI again and store figure handle
        sm_car_vehcfg_uifigure = sm_car_vehcfg;
    end
else
    % Open UI again and store figure handle
    sm_car_vehcfg_uifigure = sm_car_vehcfg;
end
