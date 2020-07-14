function Vehicle = sm_car_vehcfg_setSpring(Vehicle,spr_opt)
% Copy data from VDatabase to Vehicle data structure
% 
% spr_opt contains string indicating configuration of springs.
%      <indep/connected>_<front option>F<rear option>R_<platform>
%
%   <indep/connected>   Independent, connected by axle, 
%                           or single set of springs for vehicle
%   <front option>      Linear, nonlinear 
%   <rear option>       Linear, nonlinear 
%   <platform>          Abbreviation for Sedan Hamba "SH", etc.
%
% Copyright 2019-2020 The MathWorks, Inc.

% Load database of vehicle data into local workspace
VDatabase = evalin('base','VDatabase');

% Switch to select instances for 
%  How springs are connected              "Springs"
%  Spring model itself for front and rear "F", "R"
switch spr_opt
    case 'in_linFlinR_SHL'
        instanceSprings = 'Independent_default';
        instanceF = 'Linear_Sedan_HambaLG_f';
        instanceR = 'Linear_Sedan_HambaLG_r';
    case 'in_linStiffFlinStiffR_SHL'
        instanceSprings = 'Independent_default';
        instanceF = 'Linear_Sedan_HambaLG_stiff_f';
        instanceR = 'Linear_Sedan_HambaLG_stiff_r';
    case 'in_nlFlinR_SHL'
        instanceSprings = 'Independent_default';
        instanceF = 'Nonlinear_Sedan_HambaLG_f';
        instanceR = 'Linear_Sedan_HambaLG_r';
    case 'con_linFnlR_SHL'
        instanceSprings = 'Interconnected_default';
        instanceF = 'Linear_Sedan_HambaLG_f';
        instanceR = 'Nonlinear_Sedan_HambaLG_r';
    case 'lin_linFlinR_SHL'
        instanceSprings = 'Linear_default';
    case 'in_linFlinR_SH'
        instanceSprings = 'Independent_default';
        instanceF = 'Linear_Sedan_Hamba_f';
        instanceR = 'Linear_Sedan_Hamba_r';
    case 'in_linFlinR_BM'
        instanceSprings = 'Independent_default';
        instanceF = 'Linear_Bus_Makhulu_f';
        instanceR = 'Linear_Bus_Makhulu_r';
    case 'in_linF_TrElu'
        instanceSprings = 'Independent_1Axle';
        instanceF = 'Linear_Trailer_Elula_f';
    case 'in_linF_TrThw'
        instanceSprings = 'Independent_1Axle';
        instanceF = 'Linear_Trailer_Thwala_f';
end

% Copy data from database into Vehicle data structure
Vehicle.Chassis.Spring = VDatabase.Springs.(instanceSprings);
if(exist('instanceF','var'))
    % Not all connection options require variants at front and rear
    Vehicle.Chassis.Spring.Front = VDatabase.Spring.(instanceF);
end
if(exist('instanceR','var'))
    % Not all connection options require variants rear
    Vehicle.Chassis.Spring.Rear  = VDatabase.Spring.(instanceR);
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];

end
