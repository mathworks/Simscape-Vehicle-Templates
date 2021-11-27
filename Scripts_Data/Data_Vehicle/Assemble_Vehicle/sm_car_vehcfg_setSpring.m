function Vehicle = sm_car_vehcfg_setSpring(Vehicle,instanceSprings,spr_opt)
% Copy data from VDatabase to Vehicle data structure
%
% instanceSprings       Name of spring configuration 
%    Examples: 
%      Axle1_Independent    - single axle, no connection between springs
%      Axle2_Interconnected - double axle, connection between left and right springs
%
% spr_opt           <Axle 1 option>_<Axle 2 option>_<Axle 3 option>
%     See code below to map options to VDatabase structure
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

if(~strcmpi(instanceSprings,'noConfig'))
    if(isfield(VDatabase.Springs,instanceSprings))
        % Copy data from database into Vehicle data structure
        Vehicle.Chassis.Spring = VDatabase.Springs.(instanceSprings);
    else
        warning(['Spring set configuration ' instanceSprings ' not found']);
    end
end

sprAxleData = strsplit(spr_opt,'_');
numAxles    = length(sprAxleData);

for axle_i = 1:numAxles
    switch sprAxleData{axle_i}
        case 'SHLlinA1',      Instance = 'Sedan_HambaLG_Linear_A1';
        case 'SHLlinA2',      Instance = 'Sedan_HambaLG_Linear_A2';
        case 'SHLlinStiffA1', Instance = 'Sedan_HambaLG_Linear_stiff_A1';
        case 'SHLlinStiffA2', Instance = 'Sedan_HambaLG_Linear_stiff_A2';
        case 'SHLnonlinA1',   Instance = 'Sedan_HambaLG_Nonlinear_A1';
        case 'SHLnonlinA2',   Instance = 'Sedan_HambaLG_Nonlinear_A2';
        case 'BMlinA1',       Instance = 'Bus_Makhulu_Linear_A1';
        case 'BMlinA2',       Instance = 'Bus_Makhulu_Linear_A2';
        case 'BM3linA2',      Instance = 'Bus_Makhulu_Axle3_Linear_A2';
        case 'BM3linA3',      Instance = 'Bus_Makhulu_Axle3_Linear_A3';
        case 'SHlinA1',       Instance = 'Sedan_Hamba_Linear_A1';
        case 'SHlinA2',       Instance = 'Sedan_Hamba_Linear_A2';
        case 'AClinA1',       Instance = 'FSAE_Achilles_Linear_A1';
        case 'AClinA2',       Instance = 'FSAE_Achilles_Linear_A2';
        case 'ACdecLinA1',    Instance = 'FSAE_Achilles_DWDec_Linear_A1';
        case 'ACdecLinA2',    Instance = 'FSAE_Achilles_DWDec_Linear_A2';
        case 'SHliveA2',      Instance = 'Sedan_Hamba_LiveAxle_A2';
        case 'ELUlinA1',      Instance = 'Trailer_Elula_Linear_A1';
        case 'THWlinA1',      Instance = 'Trailer_Thwala_Linear_A1';
        case 'NoSpringA1',    Instance = 'No_Spring';
        case 'NoSpringA2',    Instance = 'No_Spring';
        case 'None',          Instance = 'None';
        otherwise,            Instance = 'notfound';
    end
    
    if(strcmpi(Instance,'notfound'))
        warning(['Spring data ' sprAxleData{axle_i} ' not found.']);
    elseif(~strcmpi(Instance,'none'))
        instanceName = ['Axle' num2str(axle_i)];
        Vehicle.Chassis.Spring.(instanceName) = VDatabase.Spring.(Instance);
    end
    
end


% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end
