function Vehicle = sm_car_vehcfg_assemble_vehicle(config_set)
% Function to assemble vehicle based on configuration set
% Cell array config_set:
%   1. Each row is a configuration option (such as suspension type)
%   2. First column indicates type of option (such as 'Susp')
%   3. Second column is the option string (such as DoubleWishbone_default_f)
%   4. Third column is 'front' or 'rear

Vehicle = [];

% Load data from Excel into database structure
% if VDatabase does not already exist in the base Workspace
W = evalin('base','whos'); %or 'base'
doesExist = ismember('VDatabase',{W(:).name});
if(~doesExist)
   VDatabase = sm_car_import_vehicle_data('sm_car_database_Vehicle.xlsx',{'Structure','NameConvention'},0);
   assignin('base','VDatabase',VDatabase)
end

% Set Body, Suspension, Steering, and AntiRollBar first
BOi = find(strcmp(config_set(:,1),'Body'));
SFi = intersect(find(strcmp(config_set(:,1),'Susp')),find(strcmp(config_set(:,3),'front')));
SRi = intersect(find(strcmp(config_set(:,1),'Susp')),find(strcmp(config_set(:,3),'rear')));
EFi = intersect(find(strcmp(config_set(:,1),'Steer')),find(strcmp(config_set(:,3),'front')));
ERi = intersect(find(strcmp(config_set(:,1),'Steer')),find(strcmp(config_set(:,3),'rear')));
AFi = intersect(find(strcmp(config_set(:,1),'AntiRollBar')),find(strcmp(config_set(:,3),'front')));
ARi = intersect(find(strcmp(config_set(:,1),'AntiRollBar')),find(strcmp(config_set(:,3),'rear')));

other_inds = setdiff(1:size(config_set,1),[BOi SFi SRi EFi ERi AFi ARi]);
config_order = [BOi SFi SRi EFi ERi AFi ARi other_inds];

% Loop through all supplied options
for cfg_i = 1:length(config_order)
    config_type   = config_set{config_order(cfg_i),1};
    config_option = config_set{config_order(cfg_i),2};
    config_lr     = config_set{config_order(cfg_i),3};
    %disp([config_type ' ' config_option ' ' config_lr]);
    switch config_type
        case 'Aero',        Vehicle = sm_car_vehcfg_setAero(Vehicle,config_option);
        case 'Body',        Vehicle = sm_car_vehcfg_setBody(Vehicle,config_option);
        case 'BodyGeometry',Vehicle = sm_car_vehcfg_setBodyGeometry(Vehicle,config_option);
        case 'Passenger',   Vehicle = sm_car_vehcfg_setPassenger(Vehicle,config_option);
        case 'Power',       Vehicle = sm_car_vehcfg_setPower(Vehicle,config_option);
        case 'Brakes',      Vehicle = sm_car_vehcfg_setBrakes(Vehicle,config_option);
        case 'Springs',     Vehicle = sm_car_vehcfg_setSpring(Vehicle,config_option);
        case 'Dampers',     Vehicle = sm_car_vehcfg_setDamper(Vehicle,config_option);
        case 'Susp',        Vehicle = sm_car_vehcfg_setSusp(Vehicle,config_option,config_lr);
        case 'Steer',       Vehicle = sm_car_vehcfg_setSteer(Vehicle,config_option,config_lr);
        case 'DriverHuman', Vehicle = sm_car_vehcfg_setDriverHuman(Vehicle,config_option,config_lr);
        case 'AntiRollBar', Vehicle = sm_car_vehcfg_setAntiRollBar(Vehicle,config_option,config_lr);
        case 'Tire',        Vehicle = sm_car_vehcfg_setTire(Vehicle,config_option,config_lr);
        case 'TireDyn',     Vehicle = sm_car_vehcfg_setTireDyn(Vehicle,config_option,config_lr);
        case 'Driveline',   Vehicle = sm_car_vehcfg_setDrv(Vehicle,config_option);
    end
end

% Modify config string to indicate configuration has been modified
veh_config_set = strsplit(Vehicle.config,'_');
veh_body =  veh_config_set{1};
Vehicle.config = [veh_body '_custom'];
