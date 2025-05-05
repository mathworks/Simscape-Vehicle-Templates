function maneuver_data = sm_car_maneuverdata_straight_constant_speed_12_50

maneuver_type = 'Straight_Constant_Speed_12_50';

Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Trajectory_LoadFile.Value    = 'Straight_Constant_Speed_trajectory_12_50.mat';
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

    % Adjustments due to Unreal scene change in R2022b
    if(verLessThan('matlab','9.13'))
        maneuver_lateral_offset    = 0; % m
    else
        maneuver_lateral_offset    = 0-2.5; % m
    end
    mdata.(Instance).Trajectory.y.Value = mdata.(Instance).Trajectory.y.Value-maneuver_lateral_offset;
end


maneuver_data.(maneuver_type) = mdata;
