function startup_sm_car
% Startup file for sm_car.slx Example
% Copyright 2019-2021 The MathWorks, Inc.

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

% Add folders with Simscape Multibody tire subsystem to path
% if MATLAB version R2021b or higher
if verLessThan('matlab', '9.11')
    addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody_None']);
else
    addpath([curr_proj.RootFolder filesep 'Libraries' filesep 'Vehicle' filesep 'Tire' filesep 'MFMbody' filesep 'MFMbody']);
end

%% Load visualization and other parameters in workspace
Visual = sm_car_param_visual('default');
assignin('base','Visual',Visual);

%% Load/Create VDatabase
% if they do not exist already (first time project is run)
if(~exist('VDatabase','var'))
    if(exist('VDatabase_file.mat','file'))
        % Load from MAT file and check for updates
        [p,n,e] = fileparts(which('VDatabase_file.mat'));
        disp(['Loading VDatabase from ' n e ' (' p filesep n e ')' ]);
        load VDatabase_file.mat %#ok<LOAD>
        assignin('base','VDatabase',VDatabase)
        VDatabase = sm_car_import_vehicle_data(1,1);
    else
        % Load from Excel
        msg = {...
            'The first time you open this project data must be loaded from Excel.';...
            'This can take up to 10 minutes.';
            'Next time the data is loaded from .mat files which is much faster,';
            'and only Excel files that have been changed will be loaded.'
            };
        msgbox(msg,'First Time Load','help')
        VDatabase = sm_car_import_vehicle_data(0,1);
    end
end
assignin('base','VDatabase',VDatabase);

%% Create .mat files with Vehicle structure presets
% if they do not exist already (first time project is run)
if(isempty(which('Vehicle_100.mat')))
    sm_car_assemble_presets
end
if verLessThan('matlab', '9.11')
    load('Vehicle_139'); %#ok<LOAD>
    assignin('base','Vehicle',Vehicle_139);
    load('Trailer_01'); %#ok<LOAD>
    assignin('base','Trailer',Trailer_01);
else
    load('Vehicle_189'); %#ok<LOAD>
    assignin('base','Vehicle',Vehicle_189);
    load('Trailer_07'); %#ok<LOAD>
    assignin('base','Trailer',Trailer_07);
end

%% Load Initial Vehicle state database
%sm_car_gen_upd_database('Init',1);
sm_car_gen_init_database;

%% Load Maneuver database
sm_car_gen_upd_database('Maneuver',1);

%% Load Driver database
%sm_car_gen_upd_database('Driver',1);
sm_car_gen_driver_database;

%% Load Camera Frame Database
CDatabase.Camera = sm_car_gen_camera_database;
assignin('base','CDatabase',CDatabase)

%% Load driving surface parameters
Scene = sm_car_import_scene_data;
assignin('base','Scene',Scene);

%% Load control parameters
Control = sm_car_import_control_param;
assignin('base','Control',Control);

%% Load default maneuver - WOT Braking (basic)
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

%% Create custom components for fuel cell
custom_code_fc = dir('**/unidir_dcdc_converter.sscp');
cd([custom_code_fc.folder '/..'])
ssc_build('GasN');
ssc_build('gn_supplement');
ssc_build('custom_dcdc_uni');
ssc_build('customMath');
cd(fileparts(which('sm_car.slx')))

%% Modify solver settings - patch from development
limitDerivativePerturbations()
daesscSetMultibody()

% If running in a parallel pool
% do not open model or demo script
open_start_content = 1;
if(~isempty(ver('parallel')))
    if(~isempty(getCurrentTask()))
        open_start_content = 0;
    end
end

if(open_start_content)
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
end
