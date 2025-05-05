function sm_car_gen_init_database
% Define vehicle-level initial conditions for maneuvers
% Vehicle position, orientation, initial speed, initial wheel speed
%
% Copyright 2019-2024 The MathWorks, Inc.

%% Vehicle-level data
%   Vehicle Name         #Axles  Wheel Radius (m)    Init Z-Offset (m)

disp(['Generating IDatabase from ' mfilename]);

vehicle_data = {...
    'Sedan_Hamba',       2       0.35                0.025;
    'Sedan_HambaLG',     2       0.4225              0.06;
    'FSAE_Achilles',     2       0.23323             0;
    'Bus_Makhulu',       2       0.4640              0;
    'Bus_Makhulu_Axle3', 3       0.4640              0;
    'Truck_Amandla',     3       0.6731              0;
    'Truck_Rhuqa',       3       0.5275              0;
    'Trailer_Kumanzi',   2       0.6731              0;
    'Trailer_Thwala',    1       0.2660              0;
    'Trailer_Elula',     1       0.3500              0
    };

% Adjustments due to Unreal scene change in R2022b
if(verLessThan('matlab','9.13'))
    roadCtrOffset     = -1.2;  % m
else
    roadCtrOffset     = -1.2-2.5;  % m
end

%% Scene Flat Surface, Slow Start
InitSet.Flat.Type      = 'Flat';
InitSet.Flat.Instance  = '';
InitSet.Flat.Data      = {...
    'aChassis','rad', 0, 0,       0;
    'vChassis','m/s', 1, 0,       0;
    'sChassis','m',   5, 0,       0};

%% Scene Mallory Park, Forwards Lap, Slow Start
InitSet.Mallory_Park.Type = 'Mallory_Park';
InitSet.Mallory_Park.Instance     = '';
InitSet.Mallory_Park.Data         = {...
    'aChassis','rad', 0,  0,       0;
    'vChassis','m/s', 10, 0,       0;
    'sChassis','m',   0.1,  0,       0};

%% Scene Mallory Park, Counter-clockwise Lap, Slow Start
InitSet.Mallory_Park_CCW.Type = 'Mallory_Park';
InitSet.Mallory_Park_CCW.Instance     = 'CCW';
InitSet.Mallory_Park_CCW.Data         = {...
    'aChassis','rad', 0, 0,       3.1416;
    'vChassis','m/s', 1, 0,       0;
    'sChassis','m',   -10, 0,       0};

%% Scene MCity, Standard Lap, Slow Start
InitSet.MCity.Type      = 'MCity';
InitSet.MCity.Instance  = '';
InitSet.MCity.Data      = {...
    'aChassis','rad', 0,         0,      4.7124;
    'vChassis','m/s', 1,         0,      0;
    'sChassis','m',   76.3631, 167.1242, 0};

%% Scene CRG Hockenheim, Standard Lap, Slow Start
InitSet.CRG_Hockenheim.Type   = 'CRG_Hockenheim';
InitSet.CRG_Hockenheim.Instance     = '';
InitSet.CRG_Hockenheim.Data         = {...
    'aChassis','rad', 0,  0.025*3-0.01,  0;
    'vChassis','m/s', 10,   0,      0;
    'sChassis','m',   6,   0,      -0.35};

%% Scene CRG Kyalami No Elevation, Standard Lap, Slow Start
InitSet.CRG_Hockenheim_F.Type   = 'CRG_Hockenheim_F';
InitSet.CRG_Hockenheim_F.Instance     = '';
InitSet.CRG_Hockenheim_F.Data         = {...
    'aChassis','rad', 0,    0,      0;
    'vChassis','m/s', 10,   0,      0;
    'sChassis','m',   6,    0,      0.17};    % INCORRECT

%% Scene CRG Kyalami, Standard Lap, Slow Start
InitSet.CRG_Kyalami.Type   = 'CRG_Kyalami';
InitSet.CRG_Kyalami.Instance     = '';
InitSet.CRG_Kyalami.Data         = {...
    'aChassis','rad', 0,  -0.025,  0;
    'vChassis','m/s', 10,   0,      0;
    'sChassis','m',   6,   0,      0.17};

%% Scene CRG Kyalami No Elevation, Standard Lap, Slow Start
InitSet.CRG_Kyalami_F.Type   = 'CRG_Kyalami_F';
InitSet.CRG_Kyalami_F.Instance     = '';
InitSet.CRG_Kyalami_F.Data         = {...
    'aChassis','rad', 0,    0,      0;
    'vChassis','m/s', 10,   0,      0;
    'sChassis','m',   6,    0,      0.17};    % INCORRECT

%% Scene CRG Mallory Park, Standard Lap, Slow Start
InitSet.CRG_Mallory_Park.Type   = 'CRG_Mallory_Park';
InitSet.CRG_Mallory_Park.Instance     = '';
InitSet.CRG_Mallory_Park.Data         = {...
    'aChassis','rad', 0,   0.0368,  0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   6,   0,      -0.18};

%% Scene CRG Mallory Park No Elevation, Standard Lap, Slow Start
InitSet.CRG_Mallory_Park_F.Type   = 'CRG_Mallory_Park_F';
InitSet.CRG_Mallory_Park_F.Instance     = '';
InitSet.CRG_Mallory_Park_F.Data         = {...
    'aChassis','rad', 0,    0,       0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   6,    0,       0};

%% Scene CRG Customizable Event, Standard Lap, Slow Start
InitSet.CRG_Custom.Type   = 'CRG_Custom';
InitSet.CRG_Custom.Instance     = '';
InitSet.CRG_Custom.Data         = {...
    'aChassis','rad', 0,   0.0368,  0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   6,   0,      -0.18};

%% Scene CRG Customizable Event No Elevation, Standard Lap, Slow Start
InitSet.CRG_Custom_F.Type   = 'CRG_Custom_F';
InitSet.CRG_Custom_F.Instance     = '';
InitSet.CRG_Custom_F.Data         = {...
    'aChassis','rad', 0,    0,       0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   6,    0,       0};

%% Scene CRG Nurburgring Nordschleife, Standard Lap, Slow Start
InitSet.CRG_Nurburgring_N.Type   = 'CRG_Nurburgring_N';
InitSet.CRG_Nurburgring_N.Instance     = '';
InitSet.CRG_Nurburgring_N.Data         = {...
    'aChassis','rad', 0,  -0.0468,  0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   13,   0,       0.6};

%% Scene CRG Nurburgring Nordschleife No Elevation, Standard Lap, Slow Start
InitSet.CRG_Nurburgring_N_F.Type   = 'CRG_Nurburgring_N_F';
InitSet.CRG_Nurburgring_N_F.Instance     = '';
InitSet.CRG_Nurburgring_N_F.Data         = {...
    'aChassis','rad', 0,    0,       0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   9,    0,       0};

%% Scene CRG Suzuka Circuit, Standard Lap, Slow Start
InitSet.CRG_Suzuka.Type   = 'CRG_Suzuka';
InitSet.CRG_Suzuka.Instance     = '';
InitSet.CRG_Suzuka.Data         = {...
    'aChassis','rad', 0,   0.0400,  0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   9,   0,        -0.35};

%% Scene CRG Suzuka Circuit No Elevation, Standard Lap, Slow Start
InitSet.CRG_Suzuka_F.Type   = 'CRG_Suzuka_F';
InitSet.CRG_Suzuka_F.Instance     = '';
InitSet.CRG_Suzuka_F.Data         = {...
    'aChassis','rad', 0,    0,       0;
    'vChassis','m/s', 10,   0,       0;
    'sChassis','m',   9,    0,       0};   % INCORRECT

%% Scene CRG Pikes Peak Uphill, Slow Start
InitSet.CRG_Pikes_Peak.Type   = 'CRG_Pikes_Peak';
InitSet.CRG_Pikes_Peak.Instance     = '';
InitSet.CRG_Pikes_Peak.Data         = {...
    'aChassis','rad', 0,   0.036,   0;
    'vChassis','m/s', 1,   0,       0;
    'sChassis','m',   9,   0,       -0.37};

%% Scene CRG Pikes Peak Downhill, Slow Start
InitSet.CRG_Pikes_Peak_Down.Type   = 'CRG_Pikes_Peak_Down';
InitSet.CRG_Pikes_Peak_Down.Instance     = '';
InitSet.CRG_Pikes_Peak_Down.Data         = {...
    'aChassis','rad', 0,       0.01,     3.48-3.14159265;
    'vChassis','m/s', 1,       0,        0;
    'sChassis','m',   1205, 9007,     1437.12};

%% Scene RDF Rough Road, Slow Start
InitSet.RDF_Rough_Road.Type   = 'RDF_Rough_Road';
InitSet.RDF_Rough_Road.Instance     = '';
InitSet.RDF_Rough_Road.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 1,   0,     0;
    'sChassis','m',   0,   0,     0};

%% Scene RDF Plateau, Slow Start
InitSet.RDF_Plateau.Type   = 'RDF_Plateau';
InitSet.RDF_Plateau.Instance     = '';
InitSet.RDF_Plateau.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 1,   0,     0;
    'sChassis','m',   0,   0,     0};

%% Scene GS Uneven Road
InitSet.GS_Uneven_Road.Type   = 'GS_Uneven_Road';
InitSet.GS_Uneven_Road.Instance     = '';
InitSet.GS_Uneven_Road.Data         = {...
    'aChassis','rad', 0,   0,     -1.65*pi/180;
    'vChassis','m/s', 1,   0,     0;
    'sChassis','m',   242.2 -4.85 0.5};

%% Scene Double Lane Change, Slow Start
InitSet.Double_Lane_Change.Type   = 'Double_Lane_Change';
InitSet.Double_Lane_Change.Instance     = '';

% Adjustments due to Unreal scene change in R2022b
if(verLessThan('matlab','9.13'))
    sChassisY = -3.35;
else
    sChassisY = -3.35-2.5;
end

InitSet.Double_Lane_Change.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 2.5, 0,     0;
    'sChassis','m',   5,  sChassisY,  0};

%% Scene Double Lane Change, Slow Start
InitSet.Double_Lane_Change_ISO3888.Type   = 'Double_Lane_Change_ISO3888';
InitSet.Double_Lane_Change_ISO3888.Instance     = '';
InitSet.Double_Lane_Change_ISO3888.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 2.5, 0,     0;
    'sChassis','m',   5,  -3.35,  0};

%% Scene Slalom, Slow Start
InitSet.Slalom.Type   = 'Slalom';
InitSet.Slalom.Instance     = '';
InitSet.Slalom.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 2.5, 0,     0;
    'sChassis','m',   5,   0,  0};


%% Scene Skidpad, Slow Start
InitSet.Skidpad.Type   = 'Skidpad';
InitSet.Skidpad.Instance     = '';
InitSet.Skidpad.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 1,   0,     0;
    'sChassis','m', -25,   0,     0};

%% Scene Constant Radius, Slow Start
InitSet.Constant_Radius_CL.Type   = 'Constant_Radius_CL';
InitSet.Constant_Radius_CL.Instance     = '';
InitSet.Constant_Radius_CL.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 1,   0,     0;
    'sChassis','m', -25,   0,     0};

%% Scene Drive Cycle FTP75
InitSet.DriveCycle_FTP75.Type   = 'DriveCycle_FTP75';
InitSet.DriveCycle_FTP75.Instance     = '';
InitSet.DriveCycle_FTP75.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 0,   0,     0;
    'sChassis','m',   0,   0,     0};

%% Scene Drive Cycle, Urban Cycle 1
InitSet.DriveCycle_UrbanCycle1.Type   = 'DriveCycle_UrbanCycle1';
InitSet.DriveCycle_UrbanCycle1.Instance     = '';
InitSet.DriveCycle_UrbanCycle1.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 0,   0,     0;
    'sChassis','m',   0,   0,     0};

%% Scene Drive Cycle, Testrig Post
InitSet.Testrig_Post.Type   = 'Testrig_Post';
InitSet.Testrig_Post.Instance     = 'Default';
InitSet.Testrig_Post.Data         = {...
    'aChassis','rad', 0,   0,     0;
    'vChassis','m/s', 0,   0,     0;
    'sChassis','m',   0,   0,     0};

%% Assemble database of vehicle initial conditions

% Get list of (Scene+Maneuver) names
Mnames = fieldnames(InitSet);
num_M  = length(fieldnames(InitSet));

% Get list of vehicle names
VNames = vehicle_data(:,1);
num_V  = size(vehicle_data,1);

% Loop over list of maneuvers
for Mi = 1:num_M
    % Loop over list of vehicles
    for Vi = 1:num_V
        % Loop over list of vehicles
        ManvName      = InitSet.(Mnames{Mi}).Type;
        Instance_Name = InitSet.(Mnames{Mi}).Instance;
        
        % Assemble Instance
        if(strcmpi(Instance_Name,'Default'))
            % If type is "Default", no instance per vehicle
            Type_Instance = 'Default';
        elseif(isempty(Instance_Name))
            % If no instance, group by vehicle type
            Type_Instance = VNames{Vi};
        else
            % Group by vehicle type and instance
            % (such as CCW for counterclockwise)
            Type_Instance = [InitSet.(Mnames{Mi}).Instance '_' VNames{Vi}];
        end
        %disp([(ManvName) ' ' Type_Instance])
        
        IDatabase.(ManvName).(Type_Instance).Instance = Type_Instance;
        IDatabase.(ManvName).(Type_Instance).Type = InitSet.(Mnames{Mi}).Type;
        
        % Define Chassis angle, position, and initial speed
        aChassis.Units  = InitSet.(Mnames{Mi}).Data{1,2};
        aChassis.Value  = [InitSet.(Mnames{Mi}).Data{1,3:5}];
        
        % Unique comments for trailer - values not used if attached to a car
        if(contains(VNames{Vi},'Trailer')&& ~strcmp(Type_Instance,'Default'))
            aChassis.Comments = 'Roll-Pitch-Yaw. Not used in assembly with car.';
        else
            aChassis.Comments = 'Roll-Pitch-Yaw';
        end
        vChassis.Units  = InitSet.(Mnames{Mi}).Data{2,2};
        vChassis.Value  = [InitSet.(Mnames{Mi}).Data{2,3:5}];
        if(contains(VNames{Vi},'Trailer') && ~strcmp(Type_Instance,'Default'))
            vChassis.Comments = 'Not used in assembly with car.';
        else
            vChassis.Comments = '';
        end
        sChassis.Units  = InitSet.(Mnames{Mi}).Data{3,2};
        sChassis.Value  = [InitSet.(Mnames{Mi}).Data{3,3:5}];
        sChassis.Value(3) = sChassis.Value(3) + vehicle_data{Vi,4};
        if(contains(VNames{Vi},'Trailer') && ~strcmp(Type_Instance,'Default'))
            sChassis.Comments = 'Not used in assembly with car.';
        else
            sChassis.Comments = '';
        end
        IDatabase.(ManvName).(Type_Instance).Chassis.aChassis = aChassis;
        IDatabase.(ManvName).(Type_Instance).Chassis.vChassis = vChassis;
        IDatabase.(ManvName).(Type_Instance).Chassis.sChassis = sChassis;
        
        % Set initial wheel speeds using longitudinal speed and tire radius
        numAxles  = vehicle_data{Vi,2};
        wheel_rad = vehicle_data{Vi,3};
        
        % Set speeds for each axle
        for ax_i = 1:numAxles
            IDatabase.(ManvName).(Type_Instance).(['Axle' num2str(ax_i)]).nWheel.Units = 'rad/s';
            IDatabase.(ManvName).(Type_Instance).(['Axle' num2str(ax_i)]).nWheel.Comments = 'Values are [left right]';
            IDatabase.(ManvName).(Type_Instance).(['Axle' num2str(ax_i)]).nWheel.Value = round([[1 1]*vChassis.Value(1)/wheel_rad wheel_rad],4);
        end
    end
    
    % Add entry for when no trailer is active
	IDatabase.(ManvName).None = 'None';
end

assignin('base','IDatabase',IDatabase);