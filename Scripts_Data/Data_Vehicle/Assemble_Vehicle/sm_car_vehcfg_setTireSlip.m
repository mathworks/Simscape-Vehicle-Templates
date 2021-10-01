function Vehicle = sm_car_vehcfg_setTireSlip(Vehicle,tireslip_opt,tireFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% tireslip_opt     Select slip model, options varies by tire
%
% tireFieldName    Field name in Vehicle data structure where tire data is stored
%
% Copyright 2019-2021 The MathWorks, Inc.


% Find field that has tire model type
if(sum(strcmp(Vehicle.Chassis.(tireFieldName).class.Value,{'Tire2x'})))
    % Axle with multiple tires - switch for various classes
    switch Vehicle.Chassis.(tireFieldName).class.Value
        case 'Tire2x'
            % Assumes inner and outer tires have same setting
            tireType = Vehicle.Chassis.(tireFieldName).TireInner.class.Value;
    end
else
    % Case with single tire
    tireType = Vehicle.Chassis.(tireFieldName).class.Value;
end

% Set slip setting based on tire model type
% Tire models use different names for same option
if (strcmpi(tireType,'MFEval'))
    switch tireslip_opt
        case 'combined',          slip_class = '1 combined';
        case 'combined+turnslip', slip_class = '2 combined+turnslip';
        otherwise
            slip_class = '1 combined'; 
            warning('sm_car:Vehicle_Config:TireSlip',...
                ['Tire type ' tireType ' does not support slip option ' tireslip_opt '.']);
    end
elseif(strcmpi(tireType,'Delft'))
    switch tireslip_opt
        case 'none',              slip_class = '(xxx0) none';
        case 'longitudinal',      slip_class = '(xxx1) longitudinal';
        case 'lateral',           slip_class = '(xxx2) lateral';
        case 'uncombined',        slip_class = '(xxx3) uncombined';
        case 'combined',          slip_class = '(xxx4) combined';
        case 'combined+turnslip', slip_class = '(xxx5) combined+turnslip';
    end
elseif(strcmpi(tireType,'MFSwift'))
    switch tireslip_opt
        case 'none',              slip_class = '(xxxx0) none';
        case 'longitudinal',      slip_class = '(xxxx1) longitudinal';
        case 'lateral',           slip_class = '(xxxx2) lateral';
        case 'uncombined',        slip_class = '(xxxx3) uncombined';
        case 'combined',          slip_class = '(xxxx4) combined';
        case 'combined+turnslip', slip_class = '(xxxx5) combined+turnslip';
    end
elseif(strcmpi(tireType,'MFMbody'))
    switch tireslip_opt
        case 'combined',          slip_class = 'combined';
        otherwise
            slip_class = 'steady-state';
            warning('sm_car:Vehicle_Config:TireSlip',...
                ['Tire type ' tireType ' does not support dynamics option ' tireslip_opt '.']);
    end
end

% Set field for slips setting
if(sum(strcmp(Vehicle.Chassis.(tireFieldName).class.Value,{'Tire2x'})))
    % Axle with multiple tires - switch for various classes
    switch Vehicle.Chassis.(tireFieldName).class.Value
        case 'Tire2x'
            % Assumes inner and outer tires have same setting
            Vehicle.Chassis.(tireFieldName).TireInner.Slip.Value = slip_class;
            Vehicle.Chassis.(tireFieldName).TireOuter.Slip.Value = slip_class;
    end
else
    % Case with single tire
    Vehicle.Chassis.(tireFieldName).Slip.Value = slip_class;
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end