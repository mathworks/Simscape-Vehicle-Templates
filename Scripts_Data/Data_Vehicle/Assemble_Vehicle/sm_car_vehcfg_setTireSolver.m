function Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,tiresolver_opt,frontRear)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
%VDatabase = evalin('base','VDatabase');

% Select fieldname for front/rear
if(strcmpi(frontRear,'front'))
    tirefield = 'TireF';
elseif(strcmpi(frontRear,'rear'))
    tirefield = 'TireR';
end

% Find field that has tire model type
if(sum(strcmp(Vehicle.Chassis.(tirefield).class.Value,{'Tire2x'})))
    % Axle with multiple tires - switch for various classes
    switch Vehicle.Chassis.(tirefield).class.Value
        case 'Tire2x'
            % Assumes inner and outer tires have same setting
            tireType = Vehicle.Chassis.(tirefield).TireInner.class.Value;
    end
else
    % Case with single tire
    tireType = Vehicle.Chassis.(tirefield).class.Value;
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
    if(sum(strcmp(Vehicle.Chassis.(tirefield).class.Value,{'Tire2x'})))
        % Axle with multiple tires - switch for various classes
        switch Vehicle.Chassis.(tirefield).class.Value
            case 'Tire2x'
                % Assumes inner and outer tires have same setting
                Vehicle.Chassis.(tirefield).TireInner.InternalSolver.Value = solver_class;
                Vehicle.Chassis.(tirefield).TireOuter.InternalSolver.Value = solver_class;
        end
    else
        % Case with single tire
        Vehicle.Chassis.(tirefield).InternalSolver.Value = solver_class;
    end
    
    % Do not modify config string -- simulation option, not model option
    %Vehicle.config = [veh_body '_custom'];
end
end