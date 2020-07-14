function Vehicle = sm_car_vehcfg_setSusp(Vehicle,susp_opt,frontRear)
% Copy data from VDatabase to Vehicle data structure
%
% susp_opt contains string indicating configuration of springs.
%      <suspension type>_<platform>
%
%   <suspension type>   Type of suspension (double wishbone, etc.)
%   <platform>          Abbreviation for Sedan Hamba "SH", etc.
%
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

if(strcmpi(frontRear,'front'))
    switch susp_opt
        case 'dwa_SHL',      instance =         'DoubleWishboneA_Sedan_HambaLG_f';
        case 'dwb_SHL',      instance =          'DoubleWishbone_Sedan_HambaLG_f';
        case 'S2LAF_SHL',    instance = 'SplitLowerArmShockFront_Sedan_HambaLG_f';
        case 'S2LAR_SHL',    instance =  'SplitLowerArmShockRear_Sedan_HambaLG_f';
        case '5S2LAF_SHL',   instance =      'FiveLinkShockFront_Sedan_HambaLG_f';
        case '5S2LAR_SHL',   instance =       'FiveLinkShockRear_Sedan_HambaLG_f';
        case '5CS2LAF_SHL',  instance =      'FiveLinkShockFront_Sedan_HambaLG_f';
        case '15DOF_SHL',    instance =             'Simple15DOF_Sedan_HambaLG_f';
        case '15DOF_SH',     instance =               'Simple15DOF_Sedan_Hamba_f';
        case 'dwb_SH',       instance =            'DoubleWishbone_Sedan_Hamba_f';
        case 'dwb_BM',       instance =            'DoubleWishbone_Bus_Makhulu_f';
        case '15DOF_TrElu',  instance =                'Simple15DOF_TrailerElula';
        case '15DOF_TrThw',  instance =               'Simple15DOF_TrailerThwala';
    end
    suspfield = 'SuspF';
elseif(strcmpi(frontRear,'rear'))
    
    % If 15DOF used in the front, force 15DOF to be used in the rear
    if(strcmpi(Vehicle.Chassis.SuspF.class.Value,'Simple'))
        if(endsWith(susp_opt,'_SH'))
            susp_opt = '15DOF_SH';
        else
            susp_opt = '15DOF_SHL';
        end
    end
    
    switch susp_opt
        case 'dwa_SHL',      instance =         'DoubleWishboneA_Sedan_HambaLG_r';
        case 'dwb_SHL',      instance =          'DoubleWishbone_Sedan_HambaLG_r';
        case 'S2LAF_SHL',    instance = 'SplitLowerArmShockFront_Sedan_HambaLG_r';
        case 'S2LAR_SHL',    instance =  'SplitLowerArmShockRear_Sedan_HambaLG_r';
        case '5S2LAF_SHL',   instance =      'FiveLinkShockFront_Sedan_HambaLG_r';
        case '5CS2LAF_SHL',  instance =      'FiveLinkShockFront_Sedan_HambaLG_r';
        case '5S2LAR_SHL',   instance =       'FiveLinkShockRear_Sedan_HambaLG_r';
        case '15DOF_SHL',    instance =             'Simple15DOF_Sedan_HambaLG_r';
        case '15DOF_SH',     instance =               'Simple15DOF_Sedan_Hamba_r';           
        case 'dwa_SH',       instance =           'DoubleWishboneA_Sedan_Hamba_r';
        case 'dwa_BM',       instance =           'DoubleWishboneA_Bus_Makhulu_r';
    end
    suspfield = 'SuspR';
end

% Map database data to correct level in Vehicle data structure
if(~contains(susp_opt,'15DOF'))
    Vehicle.Chassis.(suspfield).Linkage = VDatabase.Linkage.(instance);
    Vehicle.Chassis.(suspfield).class.Value = 'Linkage';
else
    Vehicle.Chassis.(suspfield) = VDatabase.Susp.(instance);
    Vehicle.Chassis.(suspfield).class.Value = 'Simple';
end

% Alter class only to select variant with constraints instead of joints
if(contains(susp_opt,'5CS2LAF'))
    Vehicle.Chassis.(suspfield).Linkage.class.Value = 'FiveLinkConstraintShockFront';
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end