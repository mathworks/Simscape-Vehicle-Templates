function sm_car_assemble_presets_trailer_axle2
% Code to create presets for 2-axle trailer
% Copyright 2019-2021 The MathWorks, Inc.

%% Change to directory for vehicle data
cd(fileparts(which(mfilename)));

trl_2Axle_ind = 0;
vehNamePref   = 'Trailer_Axle2_';

%%  Kumanzi 15DOF No Load MFeval 
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_noLoad';

veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF No Load MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_CAD_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_CAD_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_noLoad';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF CylLoad No Slosh MFEval
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'CAD_Trailer_Kumanzi',               '';...
    'BodyLoad',     'Trailer_Kumanzi_Tank_Cylindrical',  '';...
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_CylNoSlosh';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.dLoad.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF CylLoad No Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_CAD_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_CAD_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_CylNoSlosh';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.dLoad.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF CylLoad With Slosh MFEval
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'CAD_Trailer_Kumanzi',               '';...
    'BodyLoad',     'Trailer_Kumanzi_Tank_Cylindrical',  '';...
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_CylSlosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF CylLoad With Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_CAD_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_CAD_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_CylSlosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF 3Pend No Slosh MFEval
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_3PNoSlosh';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.Pendulum.dLateral.Value = 1000;
Trailer.Chassis.Body.BodyLoad.Pendulum.dLongitudinal.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF 3Pend No Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_CAD_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_CAD_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_3PNoSlosh';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.Pendulum.dLateral.Value = 1000;
Trailer.Chassis.Body.BodyLoad.Pendulum.dLongitudinal.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF 3Pend With Slosh MFEval
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_3PSlosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF 3Pend With Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_CAD_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_CAD_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_3PSlosh';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF No Load MFeval 
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_noLoadGen';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF No Load MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_noLoadGen';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF CylLoad No Slosh MFeval
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'Tank_Trailer_Kumanzi',              '';...
    'BodyLoad',     'Trailer_Tank_Tank_Cylindrical',     '';...
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_CylNoSloshGen';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.dLoad.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF CylLoad No Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_CylNoSloshGen';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.dLoad.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF CylLoad Slosh MFeval
vehcfg_set = {
    'Aero',         'Trailer_Kumanzi',                   '';...
    'Body',         'Trailer_Kumanzi',                   '';...
    'BodyGeometry', 'Tank_Trailer_Kumanzi',              '';...
    'BodyLoad',     'Trailer_Tank_Tank_Cylindrical',     '';...
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_CylSloshGen';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF CylLoad Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_CylSloshGen';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF 3Pend No Slosh MFeval
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_3PNoSloshGen';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.Pendulum.dLateral.Value = 1000;
Trailer.Chassis.Body.BodyLoad.Pendulum.dLongitudinal.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF 3Pend No Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_3PNoSloshGen';

% Inhibit Slosh
Trailer.Chassis.Body.BodyLoad.Pendulum.dLateral.Value = 1000;
Trailer.Chassis.Body.BodyLoad.Pendulum.dLongitudinal.Value = 1000;

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF 3Pend Slosh MFeval
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
Trailer.config = 'Kumanzi_15DOF_MFEval_steady_3PSloshGen';

trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF 3Pend Slosh MFSwift
tire_ind = find(strcmp(vehcfg_set(:,1),'Tire'));
tirA1_ind = find(strcmp(vehcfg_set(:,3),'TireA1'));
vehcfg_set{intersect(tire_ind,tirA1_ind),2} = 'MFSwift_2x_Generic_430_50R38';
tirA2_ind = find(strcmp(vehcfg_set(:,3),'TireA2'));
vehcfg_set{intersect(tire_ind,tirA2_ind),2} = 'MFSwift_2x_Generic_430_50R38';
assignin('base','vehcfg_set',vehcfg_set);

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Kumanzi_15DOF_MFSwift_steady_3PSloshGen';

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

%% Kumanzi 15DOF NoLoad MFMbody
load_veh = [vehNamePref '001'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF NoSlosh MFMbody
load_veh = [vehNamePref '003'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF CylSlosh MFMbody
load_veh = [vehNamePref '005'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF PendNoSlosh MFMbody
load_veh = [vehNamePref '007'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Kumanzi 15DOF PendSlosh MFMbody
load_veh = [vehNamePref '009'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_CAD_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF NoLoad MFMbody
load_veh = [vehNamePref '011'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF CylNoSlosh MFMbody
load_veh = [vehNamePref '013'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF CylSlosh MFMbody
load_veh = [vehNamePref '015'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF PendNoSlosh MFMbody
load_veh = [vehNamePref '017'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Tanker 15DOF PendSlosh MFMbody
load_veh = [vehNamePref '019'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Generic Box 15DOF MFMbody
load_veh = [vehNamePref '021'];
eval(['Trailer = ' load_veh ';'])
vehcfg = Trailer.config;
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA1');
Trailer = sm_car_vehcfg_setTire(Trailer,'MFMbody_2x_Generic_430_50R38','TireA2');

% Assemble configuration description in string
Trailer.config = strrep(vehcfg,'MFSwift','MFMbody');

% Save under Vehicle_###
trl_2Axle_ind = trl_2Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_2Axle_ind),3,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

