function Vehicle = sm_car_vehcfg_setTireContact(Vehicle,tirecontact_opt,tireFieldName)
% Copy data from VDatabase to Vehicle data structure
%
% tirecontact_opt   Select contact model, options varies by tire
%
% tireFieldName     Field name in Vehicle data structure where tire data is stored
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
        case 'moving',        contact_class = '(xx3xx) moving road';
        case 'enveloping',    contact_class = '(xx5xx) enveloping';
        otherwise
            contact_class = 'no contact model';
            warning('sm_car:Vehicle_Config:TireContact',...
                ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
    end
elseif(strcmpi(tireType,'Testrig_Post'))
    % No message - contact type is not relevant
    contact_class = 'no contact model';
elseif(strcmpi(tireType,'MFEval'))
    % No contact model options for MFeval tire
    warning('sm_car:Vehicle_Config:TireContact',...
        ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
    contact_class = 'no contact model';
elseif(strcmpi(tireType,'MFMbody'))
    switch tirecontact_opt
        case 'smooth',              contact_class = 'smooth';
        otherwise
            warning('sm_car:Vehicle_Config:TireContact',...
                ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
            contact_class = 'no contact model';
    end
else
    % No contact model options for other tires, such as CFL tire
    warning('sm_car:Vehicle_Config:TireContact',...
        ['Tire type ' tireType ' does not support contact option ' tirecontact_opt '.']);
    contact_class = 'no contact model';
end

% Set field for contact setting
if(~strcmp(contact_class,'no contact model'))
    if(sum(strcmp(Vehicle.Chassis.(tireFieldName).class.Value,{'Tire2x'})))
        % Axle with multiple tires - switch for various classes
        switch Vehicle.Chassis.(tireFieldName).class.Value
            case 'Tire2x'
                % Assumes inner and outer tires have same setting
                Vehicle.Chassis.(tireFieldName).TireInner.Contact.Value = contact_class;
                Vehicle.Chassis.(tireFieldName).TireOuter.Contact.Value = contact_class;
        end
    else
        % Case with single tire
        Vehicle.Chassis.(tireFieldName).Contact.Value = contact_class;
    end

    % Modify config string to indicate configuration has been modified
    veh_config_set = strsplit(Vehicle.config,'_');
    veh_body =  veh_config_set{1};
    Vehicle.config = [veh_body '_custom'];
end
end