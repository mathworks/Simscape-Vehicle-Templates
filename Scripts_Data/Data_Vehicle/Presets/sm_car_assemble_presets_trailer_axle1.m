function sm_car_assemble_presets_trailer_axle1
% Script to generate Vehicle data structures for various configurations
% Copyright 2019-2021 The MathWorks, Inc.

%% Change to directory for vehicle data
cd(fileparts(which(mfilename)));

trl_1Axle_ind = 1;
vehNamePref   = 'Trailer_';

% If VDatabase does not exist in base workspace, create it
W = evalin('base','whos'); %or 'base'
doesExist = ismember('VDatabase',{W(:).name});
if(~doesExist)
   VDatabase = sm_car_import_vehicle_data(0,1);
   assignin('base','VDatabase',VDatabase)
end

%% Trailer Elula MFEval
vehcfg_set = {
    'Aero',         'Trailer_Elula',            '';...
    'Body',         'Trailer_Elula',            '';...
    'BodyGeometry', 'Basic_Trailer_Elula',      '';...
    'Power',        'None',                     '';...
    'Brakes',       'Axle1_None',               '';...
    'Springs',      'Axle1_Independent',        'ELUlinA1';...
    'Dampers',      'Axle1_Independent',        'ELUlinA1';...
    'Susp',         'Simple15DOF_TrailerElula', 'SuspA1';
    'Steer',        'None_default',             'SuspA1';...
    'Tire',         'MFEval_Generic_213_40R21', 'TireA1';
    'TireDyn',      'steady',                   'TireA1';
    'Driveline',    'Axle1_None',               ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Elula_MFEval';

veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Thwala MFEval
vehcfg_set = {
    'Aero',         'Trailer_Thwala',      '';...
    'Body',         'Trailer_Thwala',      '';...
    'BodyGeometry', 'CAD_Trailer_Thwala',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','THWlinA1';...
    'Dampers',      'Axle1_Independent','THWlinA1';...
    'Susp',         'Simple15DOF_TrailerThwala',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFEval_CAD_145_70R13',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Thwala_MFEval';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Elula MFSwift
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula',      '';...
    'BodyGeometry', 'Basic_Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','ELUlinA1';...
    'Dampers',      'Axle1_Independent','ELUlinA1';...
    'Susp',         'Simple15DOF_TrailerElula',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFSwift_Generic_213_40R21',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Elula_MFSwift';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Thwala MFSwift
vehcfg_set = {
    'Aero',         'Trailer_Thwala',      '';...
    'Body',         'Trailer_Thwala',      '';...
    'BodyGeometry', 'CAD_Trailer_Thwala',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','THWlinA1';...
    'Dampers',      'Axle1_Independent','THWlinA1';...
    'Susp',         'Simple15DOF_TrailerThwala',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFSwift_CAD_145_70R13',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Thwala_MFSwift';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Elula MFEval Unstable
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula_Unstable',      '';...
    'BodyGeometry', 'Basic_Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','ELUlinA1';...
    'Dampers',      'Axle1_Independent','ELUlinA1';...
    'Susp',         'Simple15DOF_TrailerElula',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFEval_Generic_213_40R21',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Elula_MFEval_Unstable';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Elula Swift Unstable
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula_Unstable',      '';...
    'BodyGeometry', 'Basic_Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','ELUlinA1';...
    'Dampers',      'Axle1_Independent','ELUlinA1';...
    'Susp',         'Simple15DOF_TrailerElula',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFSwift_Generic_213_40R21',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Elula_Swift_Unstable';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Elula Mbody
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula',      '';...
    'BodyGeometry', 'Basic_Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','ELUlinA1';...
    'Dampers',      'Axle1_Independent','ELUlinA1';...
    'Susp',         'Simple15DOF_TrailerElula',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFMbody_Generic_213_40R21',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Elula_MFMbody';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Thwala Mbody
vehcfg_set = {
    'Aero',         'Trailer_Thwala',      '';...
    'Body',         'Trailer_Thwala',      '';...
    'BodyGeometry', 'CAD_Trailer_Thwala',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','THWlinA1';...
    'Dampers',      'Axle1_Independent','THWlinA1';...
    'Susp',         'Simple15DOF_TrailerThwala',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFMbody_CAD_145_70R13',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Thwala_MFMbody';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);

%% Trailer Elula Mbody Unstable
vehcfg_set = {
    'Aero',         'Trailer_Elula',      '';...
    'Body',         'Trailer_Elula_Unstable',      '';...
    'BodyGeometry', 'Basic_Trailer_Elula',      '';...
    'Power',        'None',     '';...
    'Brakes',       'Axle1_None',    '';...
    'Springs',      'Axle1_Independent','ELUlinA1';...
    'Dampers',      'Axle1_Independent','ELUlinA1';...
    'Susp',         'Simple15DOF_TrailerElula',     'SuspA1';
    'Steer',        'None_default',    'SuspA1';...
    'Tire',         'MFMbody_Generic_213_40R21',      'TireA1';
    'TireDyn',      'steady',  'TireA1';
    'Driveline',    'Axle1_None',       ''};

assignin('base','vehcfg_set',vehcfg_set); % For debugging

% Assemble vehicle
Trailer = sm_car_vehcfg_assemble_vehicle(vehcfg_set);
Trailer.config = 'Elula_MFMbody_Unstable';

trl_1Axle_ind = trl_1Axle_ind+1;
veh_var_name = [vehNamePref pad(num2str(trl_1Axle_ind),2,'left','0')]; 
eval([veh_var_name ' = Trailer;']);
save(veh_var_name,veh_var_name);
disp([pad(veh_var_name,12) ': ' Trailer.config]);





