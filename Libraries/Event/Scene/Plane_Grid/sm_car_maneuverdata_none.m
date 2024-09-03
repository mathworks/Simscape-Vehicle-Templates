function maneuver_data = sm_car_maneuverdata_none

maneuver_type = 'None';

Instance_List = {...
    'Default'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Brake.t.Value          = [0.00	100.00	125.00	150.00	175.00	200.00];
    mdata.(Instance).Brake.t.Units          = 'sec';
    mdata.(Instance).Brake.t.Comments       = '';

    mdata.(Instance).Brake.rPedal.Value     = [0.00	0.00	0.00	0.00	0.00	0.00];
    mdata.(Instance).Brake.rPedal.Units     = '0-1';
    mdata.(Instance).Brake.rPedal.Comments  = '';

    mdata.(Instance).Steer.t.Value         = [0.00	100.00	125.00	150.00	175.00	200.00];
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = [0.00	0.00	0.00	0.00	0.00	0.00];
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).Accel.t.Value         = [0.00	100.00	125.00	150.00	175.00	200.00];
    mdata.(Instance).Accel.t.Units         = 'sec';
    mdata.(Instance).Accel.t.Comments      = '';

    mdata.(Instance).Accel.rPedal.Value    = [0.00	0.00	0.00	0.00	0.00	0.00];
    mdata.(Instance).Accel.rPedal.Units    = '0-1';
    mdata.(Instance).Accel.rPedal.Comments = '';
end

% Unique settings (values)
% none; 

maneuver_data.(maneuver_type) = mdata;
