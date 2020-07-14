function Vehicle = sm_car_vehcfg_setTireContact(Vehicle,tirecontact_opt,frontRear)
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
if(strcmpi(tireType,'Delft'))
    switch tirecontact_opt
        case 'smooth',              contact_class = '(x1xx) smooth road';
        case 'smooth motorcycle',   contact_class = '(x2xx) smooth road (motorcycle: circular cross section)';
        case 'moving',              contact_class = '(x3xx) moving road';
        case 'short wave 2D',       contact_class = '(x4xx) 2D short wavelength road contact';
        case 'short wave 3D',       contact_class = '(x5xx) 3D short wavelength road contact';
        otherwise
            warning('sm_car:Vehicle_Config:TireContact',...
                ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
            contact_class = 'no contact model';
    end
elseif(strcmpi(tireType,'MFSwift'))
    switch tirecontact_opt
        case 'smooth',        contact_class = '(xx1xx) smooth road';
        case 'enveloping',    contact_class = '(xx5xx) enveloping';
        otherwise
            contact_class = 'no contact model';
            warning('sm_car:Vehicle_Config:TireContact',...
                ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
    end
else
    % No contact model options for MFeval
    warning('sm_car:Vehicle_Config:TireContact',...
        ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
    contact_class = 'no contact model';
end

% Set field for contact setting
if(~strcmp(contact_class,'no contact model'))
    if(sum(strcmp(Vehicle.Chassis.(tirefield).class.Value,{'Tire2x'})))
        % Axle with multiple tires - switch for various classes
        switch Vehicle.Chassis.(tirefield).class.Value
            case 'Tire2x'
                % Assumes inner and outer tires have same setting
                Vehicle.Chassis.(tirefield).TireInner.Contact.Value = contact_class;
                Vehicle.Chassis.(tirefield).TireOuter.Contact.Value = contact_class;
        end
    else
        % Case with single tire
        Vehicle.Chassis.(tirefield).Contact.Value = contact_class;
    end
    
    % Modify config string to indicate configuration has been modified
    veh_config_set = strsplit(Vehicle.config,'_');
    veh_body =  veh_config_set{1};
    Vehicle.config = [veh_body '_custom'];
end
end