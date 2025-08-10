function sWctr = sm_car_get_sWheelCentre(Vehicle)
% Copy data from VDatabase to Vehicle data structure
%
% Copyright 2019-2024 The MathWorks, Inc.

% Find fieldnames for tires
cha_fnames = sort(fieldnames(Vehicle.Chassis));
susp_field_inds = find(startsWith(cha_fnames,'Susp'));

% If any suspensions are found
if(~isempty(susp_field_inds))
    % Loop over suspensions
    for sus_i=1:length(susp_field_inds)

        % Extract suspension names
        suspName = cha_fnames{susp_field_inds(sus_i)};

        % Extract from Simple
        if(strcmp(Vehicle.Chassis.(suspName).class.Value,'Simple'))
            sWctr(sus_i,:) = Vehicle.Chassis.(suspName).Simple.sWheelCentre.Value;
        elseif(any(strcmp(Vehicle.Chassis.(suspName).class.Value,{'Linkage','Decoupled'})))
            sWctr(sus_i,:) = Vehicle.Chassis.(suspName).Linkage.Upright.sWheelCentre.Value;
        elseif(strcmp(Vehicle.Chassis.(suspName).class.Value,'LiveAxle'))
            sWctr(sus_i,:) = Vehicle.Chassis.(suspName).LiveAxle.sWheelCentre.Value;
        elseif(strcmp(Vehicle.Chassis.(suspName).class.Value,'TwistBeam'))
            sWctr(sus_i,:) = Vehicle.Chassis.(suspName).TwistBeam.TrailingArm.sWheelCentre.Value;
        elseif(strcmp(Vehicle.Chassis.(suspName).class.Value,'AxleTA2PR'))
            sWctr(sus_i,:) = Vehicle.Chassis.(suspName).AxleTA2PR.Upright.sWheelCentre.Value;
        end
    end
end
