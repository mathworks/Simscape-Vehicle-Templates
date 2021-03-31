function sm_car_config_vehicle(mdl)
%sm_car_config_vehicle  Select variants for Simscape Vehicle model
%   sm_car_config_vehicle(block)
%   This function triggers mask initialization code to select variants
%   within model based on mask parameters.
%
%   It also sets some other settings and variant subsystem settings
%   associated with the vehicle type.
%
% Copyright 2018-2020 The MathWorks, Inc.

% Only if the model is open should it be configured
if(bdIsLoaded(mdl))
    
    f=Simulink.FindOptions('FollowLinks',0,'LookUnderMasks','none','RegExp',1);
    h=Simulink.findBlocks(mdl,'InitTriggerDropdown','.*',f);
    
    for i=1:length(h)
        set_param(h(i),'InitTriggerDropdown','0');
        set_param(h(i),'InitTriggerDropdown','1');
    end
    
    % Other config settings based on Vehicle type
    
    solverType = get_param(mdl,'SolverType');
    Vehicle = evalin('base','Vehicle');
    powertrain_class = Vehicle.Powertrain.Power.class.Value;
    brakes_class     = Vehicle.Brakes.class.Value;
    
    if(contains(lower(powertrain_class),'fuelcell'))
        % Fuel cell: adjust controller and use daessc for variable step
        set_param([mdl '/Controller'],'popup_control','Fuel Cell 1 Motor');
        if(strcmpi(solverType,'variable-step'))
            set_param(mdl,'Solver','daessc');
        end
    elseif(strcmpi(brakes_class,'pressureabstract_discdisc') && ...
            strcmpi(powertrain_class,'electric_a1_a2'))
        set_param([mdl '/Controller'],'popup_control','Battery 2 Motor');
        if(strcmpi(solverType,'variable-step'))
            set_param(mdl,'Solver','ode23t');
        end
    else
        % Others: adjust controller and use ode23t for variable step
        % If controller present
        f=Simulink.FindOptions('FollowLinks',0,'LookUnderMasks','none');
        h=Simulink.findBlocks(mdl,'Name','Controller',f);
        if(~isempty(h))
            set_param([mdl '/Controller'],'popup_control','Default');
        end
        if(strcmpi(solverType,'variable-step'))
            set_param(mdl,'Solver','ode23t');
        end
    end
end