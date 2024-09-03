function maneuver_data = sm_car_maneuverdata_track_mallory_park

maneuver_type = 'Mallory_Park';

Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','FSAE_Achilles',...
    'CCW_Sedan_Hamba','CCW_Sedan_HambaLG','CCW_Bus_Makhulu','CCW_Truck_Amandla','CCW_FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Trajectory_LoadFile.Value    = 'Mallory_Park_trajectory_default.mat';
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

    mdata.(Instance).xPreview.x.Value      = [5 5 30]; % m
    mdata.(Instance).xPreview.x.Units      = 'm'; % m
    mdata.(Instance).xPreview.x.Comments   = ''; % m

    mdata.(Instance).xPreview.v.Value      = [0 5 20]; % m
    mdata.(Instance).xPreview.v.Units      = 'm/s'; % m
    mdata.(Instance).xPreview.v.Comments   = ''; % m
end

% Unique trajectory settings (larger vehicles)
mdata.Bus_Makhulu.Trajectory_LoadFile.Value      = 'Mallory_Park_Makhulu_trajectory_default.mat';
mdata.Truck_Amandla.Trajectory_LoadFile.Value    = 'Mallory_Park_Amandla_trajectory_default.mat';

% Unique trajectory settings (counterclockwise)
mdata.CCW_Sedan_Hamba.Trajectory_LoadFile.Value   = 'Mallory_Park_trajectory_CCW.mat';
mdata.CCW_Sedan_HambaLG.Trajectory_LoadFile.Value = 'Mallory_Park_trajectory_CCW.mat';
mdata.CCW_FSAE_Achilles.Trajectory_LoadFile.Value = 'Mallory_Park_trajectory_CCW.mat';
mdata.CCW_Bus_Makhulu.Trajectory_LoadFile.Value   = 'Mallory_Park_Makhulu_trajectory_CCW.mat';
mdata.CCW_Truck_Amandla.Trajectory_LoadFile.Value = 'Mallory_Park_Makhulu_trajectory_CCW.mat';

% Fill in trajectory data
for i = 1:length(fieldnames(mdata))
    Instance = Instance_List{i};
    mdata.(Instance).Trajectory = load(mdata.(Instance).Trajectory_LoadFile.Value);
end

maneuver_data.(maneuver_type) = mdata;
