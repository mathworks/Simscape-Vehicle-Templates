function maneuver_data = sm_car_maneuverdata_accel_nobrake

maneuver_type = 'Accel_NoBrake';

Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Brake.t.Value          = [0.00	11.00	11.20	190.00	191.00	200.00];
    mdata.(Instance).Brake.t.Units          = 'sec';
    mdata.(Instance).Brake.t.Comments       = '';

    mdata.(Instance).Brake.rPedal.Value     = [0.00	0.00	0.00	0.00	0.00	0.00];
    mdata.(Instance).Brake.rPedal.Units     = '0-1';
    mdata.(Instance).Brake.rPedal.Comments  = '';

    mdata.(Instance).Steer.t.Value         = [0.00	11.00	11.20	100.00	150.00	200.00];
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = [0.00	0.00	0.00	0.00	0.00	0.00];
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).Accel.t.Value         = [0.00	1.00	1.20	5.00	5.20	200.00];
    mdata.(Instance).Accel.t.Units         = 'sec';
    mdata.(Instance).Accel.t.Comments      = '';

    mdata.(Instance).Accel.rPedal.Value    = [0.00	0.00	0.80	0.80	0.00	0.00];
    mdata.(Instance).Accel.rPedal.Units    = '0-1';
    mdata.(Instance).Accel.rPedal.Comments = '';
end

% Unique settings (values)
mdata.Sedan_HambaLG.Accel.t.Value      = [0.00	1.00	1.20	6.00	6.20	200.00]; 
mdata.Sedan_HambaLG.Accel.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00]; 

mdata.Bus_Makhulu.Accel.t.Value        = [0.00	1.00	1.20	7.00	7.20	200.00]; 
mdata.Bus_Makhulu.Accel.rPedal.Value   = [0.00	0.00	1.00	1.00	0.00	0.00]; 

mdata.Truck_Amandla.Accel.t.Value      = [0.00	1.00	1.20	7.00	7.20	200.00]; 
mdata.Truck_Amandla.Accel.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00]; 

maneuver_data.(maneuver_type) = mdata;
