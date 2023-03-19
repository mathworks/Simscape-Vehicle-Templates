function Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,tiresolver_opt)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2023 The MathWorks, Inc.

% Load database of vehicle data into local workspace
%VDatabase = evalin('base','VDatabase');

% Find fieldnames for tires
chassis_fnames = fieldnames(Vehicle.Chassis);
fname_inds_tire = startsWith(chassis_fnames,'Tire');
tireFields = chassis_fnames(fname_inds_tire);
tireFields = sort(tireFields);

for axle_i = 1:length(tireFields)
    tireField = tireFields{axle_i};
    
    % Find field that has tire model type
    if(sum(strcmp(Vehicle.Chassis.(tireField).class.Value,{'Tire2x'})))
        % Axle with multiple tires - switch for various classes
        switch Vehicle.Chassis.(tireField).class.Value
            case 'Tire2x'
                % Assumes inner and outer tires have same setting
                tireType = Vehicle.Chassis.(tireField).TireInner.class.Value;
        end
    else
        % Case with single tire
        tireType = Vehicle.Chassis.(tireField).class.Value;
    end
    
    % Set contact setting based on tire model type
    % Tire models use different names for same option
    if(strcmpi(tireType,'MFSwift'))
        switch lower(tiresolver_opt)
            case 'fixed',       solver_class = 'on';
            case 'variable',    solver_class = 'off';
            otherwise
                solver_class = 'no solver setting';
        end
    else
        % No solver model options tires other than MF-Swift
        solver_class = 'no solver setting';
    end
    
    % Set field for contact setting
    if(~strcmp(solver_class,'no solver setting'))
        if(sum(strcmp(Vehicle.Chassis.(tireField).class.Value,{'Tire2x'})))
            % Axle with multiple tires - switch for various classes
            switch Vehicle.Chassis.(tireField).class.Value
                case 'Tire2x'
                    % Assumes inner and outer tires have same setting
                    Vehicle.Chassis.(tireField).TireInner.InternalSolver.Value = solver_class;
                    Vehicle.Chassis.(tireField).TireOuter.InternalSolver.Value = solver_class;
            end
        else
            % Case with single tire
            Vehicle.Chassis.(tireField).InternalSolver.Value = solver_class;
        end
        
        % Do not modify config string -- simulation option, not model option
        %Vehicle.config = [veh_body '_custom'];
    end
end