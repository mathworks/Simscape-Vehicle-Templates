function maneuver_data = sm_car_maneuverdata_skidpad

maneuver_type = 'Skidpad';

Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Trajectory_LoadFile.Value    = 'Skidpad_trajectory_default.mat';
    mdata.(Instance).Trajectory_LoadFile.Units    = '';
    mdata.(Instance).Trajectory_LoadFile.Comments = '';

    mdata.(Instance).xMaxLat.Value         = 5; % m
    mdata.(Instance).xMaxLat.Units         = 'm'; % m
    mdata.(Instance).xMaxLat.Comments      = ''; % m

    mdata.(Instance).vMinTarget.Value      = 5; % m
    mdata.(Instance).vMinTarget.Units      = 'm/s'; % m
    mdata.(Instance).vMinTarget.Comments   = ''; % m

    mdata.(Instance).vGain.Value           = 1; % m
    mdata.(Instance).vGain.Units           = ''; % m
    mdata.(Instance).vGain.Comments        = 'Scales target speed Trajectory vx'; % m

    mdata.(Instance).xPreview.x.Value      = [2.5 3 21]; % m
    mdata.(Instance).xPreview.x.Units      = 'm'; % m
    mdata.(Instance).xPreview.x.Comments   = ''; % m

    mdata.(Instance).xPreview.v.Value      = [0 5 20]; % m
    mdata.(Instance).xPreview.v.Units      = 'm/s'; % m
    mdata.(Instance).xPreview.v.Comments   = ''; % m

    mdata.(Instance).xMax.Value            = 290; % m
    mdata.(Instance).xMax.Units            = 'm'; % m
    mdata.(Instance).xMax.Comments         = 'Stop test when vehicle has reached this distance'; % m

    mdata.(Instance).nPreviewPoints.Value      = 5; % m
    mdata.(Instance).nPreviewPoints.Units      = ''; % m
    mdata.(Instance).nPreviewPoints.Comments   = 'For Pure Pursuit Driver'; % m    
end

% Unique trajectory settings (smaller vehicles)
mdata.Sedan_Hamba.xPreview.x.Value      = [2.5 3 10]; % m
mdata.FSAE_Achilles.xPreview.x.Value    = [2.5 3 10]; % m


% Unique trajectory settings (counterclockwise)
% none

% Fill in trajectory data
for i = 1:length(fieldnames(mdata))
    Instance = Instance_List{i};
    mdata.(Instance).Trajectory = load(mdata.(Instance).Trajectory_LoadFile.Value);
end

maneuver_data.(maneuver_type) = mdata;
