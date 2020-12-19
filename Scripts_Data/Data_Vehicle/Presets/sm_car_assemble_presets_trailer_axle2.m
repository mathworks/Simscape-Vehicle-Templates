function sm_car_assemble_presets_trailer_axle2
% Code to create presets for 2-axle trailer
% Copyright 2019-2020 The MathWorks, Inc.

%% Change to directory for vehicle data
cd(fileparts(which(mfilename)));

trl_2Axle_ind = 0;
vehNamePref   = 'Trailer_Axle2_';

%%  MFeval 15DOF
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'CAD_Trailer_Kumanzi',               '';...
    'BodyLoad',     'None',                              '';...
    'Passenger',    'None',                              '';...
    'Power',        'None',                              '';...
    'Brakes',       'Axle2_None',                        '';...
    'Springs',      'Axle2_None',                        'None_None';...
    'Dampers',      'Axle2_None',                        'None_None';...
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A1',    'SuspA1';
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A2',    'SuspA2';
    'Steer',        'None_default',                      'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'DriverHuman',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'Tire',         'MFEval_2x_CAD_430_50R38',           'TireA1';
    'Tire',         'MFEval_2x_CAD_430_50R38',           'TireA2';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'Driveline',    'Axle2_None',                         ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFEval_steady';

veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% MFSwift 15DOF 
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%%  MFEval 15DOF Slosh
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'CAD_Trailer_Kumanzi',               '';...
    'BodyLoad',     'Trailer_Kumanzi_Slosh_3_Pendulum',  '';...
    'Passenger',    'None',                              '';...
    'Power',        'None',                              '';...
    'Brakes',       'Axle2_None',                        '';...
    'Springs',      'Axle2_None',                        'None_None';...
    'Dampers',      'Axle2_None',                        'None_None';...
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A1',    'SuspA1';
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A2',    'SuspA2';
    'Steer',        'None_default',                      'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'DriverHuman',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'Tire',         'MFEval_2x_CAD_430_50R38',           'TireA1';
    'Tire',         'MFEval_2x_CAD_430_50R38',           'TireA2';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'Driveline',    'Axle2_None',                         ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_Slosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% MFSwift 15DOF Slosh
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_Slosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%%  MFeval 15DOF Generic Tanker
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'Tank_Trailer_Kumanzi',             '';...
    'BodyLoad',     'None',                              '';...
    'Passenger',    'None',                              '';...
    'Power',        'None',                              '';...
    'Brakes',       'Axle2_None',                        '';...
    'Springs',      'Axle2_None',                        'None_None';...
    'Dampers',      'Axle2_None',                        'None_None';...
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A1',    'SuspA1';
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A2',    'SuspA2';
    'Steer',        'None_default',                      'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'DriverHuman',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA1';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA2';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'Driveline',    'Axle2_None',                         ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_Generic';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% MFSwift 15DOF Generic Tanker
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_Generic';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%%  MFeval 15DOF Generic Tanker Slosh
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'Tank_Trailer_Kumanzi',              '';...
    'BodyLoad',     'Trailer_Tank_Slosh_3_Pendulum',     '';...
    'Passenger',    'None',                              '';...
    'Power',        'None',                              '';...
    'Brakes',       'Axle2_None',                        '';...
    'Springs',      'Axle2_None',                        'None_None';...
    'Dampers',      'Axle2_None',                        'None_None';...
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A1',    'SuspA1';
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A2',    'SuspA2';
    'Steer',        'None_default',                      'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'DriverHuman',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA1';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA2';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'Driveline',    'Axle2_None',                         ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_GenericSlosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% MFSwift 15DOF Generic Tanker Slosh
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_GenericSlosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);


%%  MFeval 15DOF Box Trailer
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'Box_Trailer_Kumanzi',              '';...
    'BodyLoad',     'None',                              '';...
    'Passenger',    'None',                              '';...
    'Power',        'None',                              '';...
    'Brakes',       'Axle2_None',                        '';...
    'Springs',      'Axle2_None',                        'None_None';...
    'Dampers',      'Axle2_None',                        'None_None';...
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A1',    'SuspA1';
    'Susp',         'Simple15DOF_Trailer_Kumanzi_A2',    'SuspA2';
    'Steer',        'None_default',                      'SuspA1';...
    'Steer',        'None_default',                      'SuspA2';...
    'DriverHuman',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA1';...
    'AntiRollBar',  'None',                              'SuspA2';...
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA1';
    'Tire',         'MFEval_2x_Generic_430_50R38',       'TireA2';
    'TireDyn',      'steady',                            'TireA1';
    'TireDyn',      'steady',                            'TireA2';
    'Driveline',    'Axle2_None',                         ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_Box';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% MFSwift 15DOF Box Trailer
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_Box';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);


