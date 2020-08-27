function startup_sm_car
% Startup file for sm_car.slx Example
% Copyright 2019-2020 The MathWorks, Inc.

curr_proj = simulinkproject;

% Add Delft-Tyre software to path if it can be found
TNOtbx6p2_pth=GetTNODelftTyrePath;
if exist(TNOtbx6p2_pth,'dir')
    addpath(TNOtbx6p2_pth)
    disp('TNO Delft-Tyre MATLAB Toolbox added to MATLAB path:');
    disp(TNOtbx6p2_pth);

    DelftTyrePathstr = sm_car_DelftTyrePath(TNOtbx6p2_pth);
    addpath(DelftTyrePathstr);
    addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'Delft' filesep 'Delft_6p2']);
else
    % Else, add a placeholder library so that links are all defined
    addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'Delft' filesep 'Delft_None']);
    disp('Delft-Tyre Software not found, placeholder library used instead.');
end

% Add MF-Swift software to path if it can be found
[~,MFSwifttbx_folders]=sm_car_startupMFSwift;
assignin('base','MFSwifttbx_folders',MFSwifttbx_folders);

%% Load visualization and other parameters in workspace
evalin('base','sm_car_param_visual');

%% Load/Create VDatabase
% if they do not exist already (first time project is run)
if(~exist('VDatabase','var'))
    if(exist('VDatabase_file.mat','file'))
        % Load from MAT file and check for updates
        [p,n,e] = fileparts(which('VDatabase_file.mat'));
        disp(['Loading VDatabase from ' n e ' (' p filesep n e ')' ]);
        load VDatabase_file.mat %#ok<LOAD>
        assignin('base','VDatabase',VDatabase)
        VDatabase = sm_car_import_vehicle_data('sm_car_database_Vehicle.xlsx',{'Structure','NameConvention'},1,1);
    else
        % Load from Excel
        VDatabase = sm_car_import_vehicle_data('sm_car_database_Vehicle.xlsx',{'Structure','NameConvention'},0,1);
    end
end
assignin('base','VDatabase',VDatabase);

%% Create .mat files with Vehicle structure presets
% if they do not exist already (first time project is run)
if(isempty(which('Vehicle_100.mat')))
    sm_car_vehicle_data_assemble_set
end
load('Vehicle_139'); %#ok<LOAD>
assignin('base','Vehicle',Vehicle_139);
load('Trailer_01'); %#ok<LOAD>
assignin('base','Trailer',Trailer_01);

%% Load Initial Vehicle state database
sm_car_gen_upd_database('Init',1);

%% Load Maneuver database
sm_car_gen_upd_database('Maneuver',1);

%% Load Driver database
sm_car_gen_upd_database('Driver',1);

%% Load Camera Frame Database
sm_car_gen_upd_database('Camera',1);

%% Load driving surface parameters
Scene = sm_car_import_scene_data;
assignin('base','Scene',Scene);

%% Load default maneuver - WOT Braking
% Need to load variables individually as sm_car may not be open
evalin('base','Init = IDatabase.Flat.Sedan_Hamba;');
evalin('base','Maneuver = MDatabase.WOT_Braking.Sedan_Hamba;');
evalin('base','Driver = DDatabase.Double_Lane_Change.Sedan_Hamba;');
evalin('base','Camera = CDatabase.Camera.Hamba;');
evalin('base','Init_Trailer = IDatabase.Flat.Trailer_Thwala;');

%% Create custom components for drag calculation
custom_code = dir('**/custom_abs.ssc');
cd(custom_code.folder)
ssc_build
cd(fileparts(which('sm_car.slx')))

%% Modify solver settings - patch from development
limitDerivativePerturbations()

%% If this is the top level project, open HTML script
% Do not open it if this is a referenced project.
this_project = simulinkproject;
if(this_project.Information.TopLevel == 1)
    web('Simscape_Vehicle_Library_Demo_Script.html');
end

%% Open app
evalin('base','sm_car_vehcfg_run');

%% Open model
sm_car

