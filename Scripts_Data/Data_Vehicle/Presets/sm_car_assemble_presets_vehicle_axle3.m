function sm_car_assemble_presets_vehicle_axle3
% Code to create presets for 3-axle vehicle
% Copyright 2019-2021 The MathWorks, Inc.

%% Change to directory for vehicle data
cd(fileparts(which(mfilename)));

veh_3Axle_ind = 0;
vehNamePref   = 'Vehicle_Axle3_';

%% Bus_Makhulu_3Axle 15DOF MFeval 6x2 
vehcfg_set = {
    'Aero',         'Bus_Makhulu',        '';...
    'Body',         'Bus_Makhulu_3Axle',      '';...
    'BodyGeometry', 'CAD_Bus_Makhulu',      '';...
    'Passenger',    'Bus_Makhulu_1111',      '';...
    'Power',        'Ideal_A2_default',     '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Bus_Makhulu_Axle3',    '';...
    'Springs',      'Axle3_None',                        'None_None_None';...
    'Dampers',      'Axle3_None',                        'None_None_None';...
    'Susp',         'Simple15DOF_Bus_Makhulu_f',         'SuspA1';
    'Susp',         'Simple15DOF_Bus_Makhulu_Axle3_A2',  'SuspA2';
    'Susp',         'Simple15DOF_Bus_Makhulu_Axle3_A3',  'SuspA3';
    'Steer',        'Ackermann_Makhulu_f',               'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Bus_Makhulu',                       'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'AntiRollBar',  'None',                              'SuspA3';...
    'Tire',         'MFEval_CAD_270_70R22',              'TireA1';
    'Tire',         'MFEval_2x_CAD_270_70R22',           'TireA2';
    'Tire',         'MFEval_2x_CAD_270_70R22',           'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_BM3',        ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_15DOF_MFEval_steady_6x2';
%Init = IDatabase.Flat.Bus_Makhulu_Axle3;

veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%%  Bus Makhulu 3Axle 15DOF MFeval 6x4 
drv_ind = strcmp(vehcfg_set(:,1),'Driveline');
vehcfg_set{drv_ind,2} = 'A11D_A21D3_A31D3_BM3';
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_15DOF_MFEval_steady_6x4';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%%  Bus Makhulu 3Axle 15DOF MFSwift 6x2
vehcfg_set = {
    'Aero',         'Bus_Makhulu',        '';...
    'Body',         'Bus_Makhulu_3Axle',      '';...
    'BodyGeometry', 'CAD_Bus_Makhulu',      '';...
    'Passenger',    'Bus_Makhulu_1111',      '';...
    'Power',        'Ideal_A2_default',     '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Bus_Makhulu_Axle3',    '';...
    'Springs',      'Axle3_None',                        'None_None_None';...
    'Dampers',      'Axle3_None',                        'None_None_None';...
    'Susp',         'Simple15DOF_Bus_Makhulu_f',         'SuspA1';
    'Susp',         'Simple15DOF_Bus_Makhulu_Axle3_A2',  'SuspA2';
    'Susp',         'Simple15DOF_Bus_Makhulu_Axle3_A3',  'SuspA3';
    'Steer',        'Ackermann_Makhulu_f',               'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Bus_Makhulu',                       'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'AntiRollBar',  'None',                              'SuspA3';...
    'Tire',         'MFSwift_CAD_270_70R22',             'TireA1';
    'Tire',         'MFSwift_2x_CAD_270_70R22',          'TireA2';
    'Tire',         'MFSwift_2x_CAD_270_70R22',          'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_BM3',        ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_15DOF_MFSwift_steady_6x2';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle MFSwift 15DOF 6x4
drv_ind = strcmp(vehcfg_set(:,1),'Driveline');
vehcfg_set{drv_ind,2} = 'A11D_A21D3_A31D3_BM3';
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_15DOF_MFSwift_steady_6x4';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);


%% Bus Makhulu 3Axle MFEval dwb 6x2
vehcfg_set = {
    'Aero',         'Bus_Makhulu',        '';...
    'Body',         'Bus_Makhulu_3Axle',      '';...
    'BodyGeometry', 'CAD_Bus_Makhulu',      '';...
    'Passenger',    'Bus_Makhulu_1111',      '';...
    'Power',        'Ideal_A2_default',     '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Bus_Makhulu_Axle3',    '';...
    'Springs',      'Axle3_Independent',  'BMlinA1_BM3linA2_BM3linA3';...
    'Dampers',      'Axle3_Independent',  'BMlinA1_BM3linA2_BM3linA3';...
    'Susp',         'DoubleWishbone_Bus_Makhulu_f',      'SuspA1';
    'Susp',         'DoubleWishboneA_Bus_Makhulu_r',     'SuspA2';
    'Susp',         'DoubleWishboneA_Bus_Makhulu_r',     'SuspA3';
    'Steer',        'RackWheel_Bus_Makhulu_f',           'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Bus_Makhulu',                       'SuspA1';...
    'AntiRollBar',  'Droplink_Bus_Makhulu_f',            'SuspA1';...
    'AntiRollBar',  'Droplink_Bus_Makhulu_r',            'SuspA2';...
    'AntiRollBar',  'Droplink_Bus_Makhulu_r',            'SuspA3';...
    'Tire',         'MFEval_CAD_270_70R22',              'TireA1';
    'Tire',         'MFEval_2x_CAD_270_70R22',           'TireA2';
    'Tire',         'MFEval_2x_CAD_270_70R22',           'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_BM3',        ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_dwb_MFEval_steady_6x2';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle MFEval dwb 6x4 
drv_ind = strcmp(vehcfg_set(:,1),'Driveline');
vehcfg_set{drv_ind,2} = 'A11D_A21D3_A31D3_BM3';
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_dwb_MFEval_steady_6x4';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle MFSwift dwb 6x2
vehcfg_set = {
    'Aero',         'Bus_Makhulu',        '';...
    'Body',         'Bus_Makhulu_3Axle',      '';...
    'BodyGeometry', 'CAD_Bus_Makhulu',      '';...
    'Passenger',    'Bus_Makhulu_1111',      '';...
    'Power',        'Ideal_A2_default',     '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Bus_Makhulu_Axle3',    '';...
    'Springs',      'Axle3_Independent',  'BMlinA1_BM3linA2_BM3linA3';...
    'Dampers',      'Axle3_Independent',  'BMlinA1_BM3linA2_BM3linA3';...
    'Susp',         'DoubleWishbone_Bus_Makhulu_f',      'SuspA1';
    'Susp',         'DoubleWishboneA_Bus_Makhulu_r',     'SuspA2';
    'Susp',         'DoubleWishboneA_Bus_Makhulu_r',     'SuspA3';
    'Steer',        'RackWheel_Bus_Makhulu_f',           'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Bus_Makhulu',                       'SuspA1';...
    'AntiRollBar',  'Droplink_Bus_Makhulu_f',            'SuspA1';...
    'AntiRollBar',  'Droplink_Bus_Makhulu_r',            'SuspA2';...
    'AntiRollBar',  'Droplink_Bus_Makhulu_r',            'SuspA3';...
    'Tire',         'MFSwift_CAD_270_70R22',             'TireA1';
    'Tire',         'MFSwift_2x_CAD_270_70R22',          'TireA2';
    'Tire',         'MFSwift_2x_CAD_270_70R22',          'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_BM3',        ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_dwb_MFSwift_steady_6x2';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle MFSwift dwb 6x4
drv_ind = strcmp(vehcfg_set(:,1),'Driveline');
vehcfg_set{drv_ind,2} = 'A11D_A21D3_A31D3_BM3';
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Makhulu3Axle_dwb_MFSwift_steady_6x4';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%%  Truck Amandla MFeval 15DOF 6x2
vehcfg_set = {
    'Aero',         'Truck_Amandla',                     '';...
    'Body',         'Truck_Amandla_3Axle',               '';...
    'BodyGeometry', 'CAD_Truck_Amandla',                 '';...
    'Passenger',    'None',                              '';...
    'Power',        'Ideal_A2_default',                  '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Truck_Amandla_Axle3',    '';...
    'Springs',      'Axle3_None',                        'None_None_None';...
    'Dampers',      'Axle3_None',                        'None_None_None';...
    'Susp',         'Simple15DOF_Truck_Amandla_A1',      'SuspA1';
    'Susp',         'Simple15DOF_Truck_Amandla_A2',      'SuspA2';
    'Susp',         'Simple15DOF_Truck_Amandla_A3',      'SuspA3';
    'Steer',        'Ackermann_Amandla_A1',              'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Truck_Amandla',                     'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'AntiRollBar',  'None',                              'SuspA3';...
    'Tire',         'MFEval_CAD_430_50R38',              'TireA1';
    'Tire',         'MFEval_2x_CAD_430_50R38',           'TireA2';
    'Tire',         'MFEval_2x_CAD_430_50R38',           'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_TA3',               ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFEval_steady_6x2';
%Init = IDatabase.Flat.Bus_Makhulu_Axle3;

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Truck Amandla MFeval 6x4
drv_ind = strcmp(vehcfg_set(:,1),'Driveline');
vehcfg_set{drv_ind,2} = 'A11D_A21D3_A31D3_TA3';
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFEval_steady_6x4';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Truck Amandla MFSwift 6x2
vehcfg_set = {
    'Aero',         'Truck_Amandla',                     '';...
    'Body',         'Truck_Amandla_3Axle',               '';...
    'BodyGeometry', 'CAD_Truck_Amandla',                 '';...
    'Passenger',    'None',                              '';...
    'Power',        'Ideal_A2_default',                  '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Truck_Amandla_Axle3',    '';...
    'Springs',      'Axle3_None',                        'None_None_None';...
    'Dampers',      'Axle3_None',                        'None_None_None';...
    'Susp',         'Simple15DOF_Truck_Amandla_A1',      'SuspA1';
    'Susp',         'Simple15DOF_Truck_Amandla_A2',      'SuspA2';
    'Susp',         'Simple15DOF_Truck_Amandla_A3',      'SuspA3';
    'Steer',        'Ackermann_Amandla_A1',              'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Truck_Amandla',                     'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'AntiRollBar',  'None',                              'SuspA3';...
    'Tire',         'MFSwift_CAD_430_50R38',               'TireA1';
    'Tire',         'MFSwift_2x_CAD_430_50R38',            'TireA2';
    'Tire',         'MFSwift_2x_CAD_430_50R38',            'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_TA3',               ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFSwift_steady_6x2';
%Init = IDatabase.Flat.Bus_Makhulu_Axle3;

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Truck Amandla MFSwift 6x4
drv_ind = strcmp(vehcfg_set(:,1),'Driveline');
vehcfg_set{drv_ind,2} = 'A11D_A21D3_A31D3_TA3';
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFSwift_steady_6x4';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%%  Semi Truck 15DOF MFeval 6x2
vehcfg_set = {
    'Aero',         'Truck_Amandla',                     '';...
    'Body',         'Truck_Amandla_3Axle',               '';...
    'BodyGeometry', 'Semi_Truck_Amandla',               '';...
    'Passenger',    'None',                              '';...
    'Power',        'Ideal_A2_default',                  '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Truck_Amandla_Axle3',    '';...
    'Springs',      'Axle3_None',                        'None_None_None';...
    'Dampers',      'Axle3_None',                        'None_None_None';...
    'Susp',         'Simple15DOF_Truck_Amandla_A1',      'SuspA1';
    'Susp',         'Simple15DOF_Truck_Amandla_A2',      'SuspA2';
    'Susp',         'Simple15DOF_Truck_Amandla_A3',      'SuspA3';
    'Steer',        'Ackermann_Amandla_A1',              'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Truck_Amandla',                     'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'AntiRollBar',  'None',                              'SuspA3';...
    'Tire',         'MFEval_Generic_430_50R38',          'TireA1';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA2';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D_TA3',               ''};
                      
assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFEval_steady_6x2Gen';
%Init = IDatabase.Flat.Bus_Makhulu_Axle3;

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Semi Truck 15DOF MFSwift 6x2
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFEval_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFEval_2x_Generic_430_50R38';
tirA3_ind = find(strcmp(vehcfg_set(:,3),'TireA3'));
vehcfg_set{intersect(tire_ind,tirA3_ind),2} = 'MFEval_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFSwift_steady_6x2Gen';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%%  Semi Truck 15DOF MFSwift 6x2
vehcfg_set = {
    'Aero',         'Truck_Amandla',                     '';...
    'Body',         'Truck_Amandla_3Axle',               '';...
    'BodyGeometry', 'Semi_Truck_Amandla',               '';...
    'Passenger',    'None',                              '';...
    'Power',        'Ideal_A2_default',                  '';...
    'Brakes',       'Axle3_PedalAbstract_DiscDiscDisc_Truck_Amandla_Axle3',    '';...
    'Springs',      'Axle3_None',                        'None_None_None';...
    'Dampers',      'Axle3_None',                        'None_None_None';...
    'Susp',         'Simple15DOF_Truck_Amandla_A1',      'SuspA1';
    'Susp',         'Simple15DOF_Truck_Amandla_A2',      'SuspA2';
    'Susp',         'Simple15DOF_Truck_Amandla_A3',      'SuspA3';
    'Steer',        'Ackermann_Amandla_A1',              'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'Steer',        'None_default',                      'SuspA3';...
    'DriverHuman',  'Truck_Amandla',                     'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'AntiRollBar',  'None',                              'SuspA3';...
    'Tire',         'MFEval_Generic_430_50R38',          'TireA1';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA2';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA3';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'TireDyn',      'steady',                            'TireA3';
    'Driveline',    'A11D_A21D3_A31D3_TA3',               ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFEval_steady_6x4Gen';
%Init = IDatabase.Flat.Bus_Makhulu_Axle3;

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Semi Truck 15DOF MFSwift 6x4
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA3_ind = find(strcmp(vehcfg_set(:,3),'TireA3'));
vehcfg_set{intersect(tire_ind,tirA3_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Vehicle = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Vehicle.config = 'Amandla3Axle_15DOF_MFSwift_steady_6x4Gen';

veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle 15DOF MFMbody 6x2 
load_veh = [vehNamePref '002'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle 15DOF MFMbody 6x4 
load_veh = [vehNamePref '003'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Bus Makhulu 3Axle Double Wishbone MFMbody 6x2 
load_veh = [vehNamePref '006'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_270_70R22','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_270_70R22','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Truck Amandla 3Axle 15DOF MFMbody 6x2 
load_veh = [vehNamePref '010'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_430_50R38','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_430_50R38','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_430_50R38','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Truck Amandla 3Axle 15DOF MFMbody 6x4 
load_veh = [vehNamePref '011'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_CAD_430_50R38','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_430_50R38','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_CAD_430_50R38','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Semi Truck 3Axle 15DOF MFMbody 6x2 
load_veh = [vehNamePref '013'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_430_50R38','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_Generic_430_50R38','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_Generic_430_50R38','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);

%% Semi Truck 3Axle 15DOF MFMbody 6x4 
load_veh = [vehNamePref '015'];
eval(['Vehicle = ' load_veh ';'])
vehcfg = Vehicle.config;
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_Generic_430_50R38','TireA1');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_Generic_430_50R38','TireA2');
Vehicle = sm_car_vehcfg_setTire(Vehicle,'MFMbody_2x_Generic_430_50R38','TireA3');

% Assemble configuration description in string
Vehicle.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
veh_3Axle_ind = veh_3Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(veh_3Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Vehicle;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Vehicle.config]);
