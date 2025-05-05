function maneuver_data = sm_car_maneuverdata_turn

maneuver_type = 'Turn';

Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).Brake.t.Value          = [0.00	11.00	11.20	190.00	191.00	200.00];
    mdata.(Instance).Brake.t.Units          = 'sec';
    mdata.(Instance).Brake.t.Comments       = '';

    mdata.(Instance).Brake.rPedal.Value     = [0.00	0.00	0.50	0.50	0.00	0.00];
    mdata.(Instance).Brake.rPedal.Units     = '0-1';
    mdata.(Instance).Brake.rPedal.Comments  = '';

    mdata.(Instance).Steer.t.Value         = [0.00	5.00	5.20	180.00	181.00	200.00];
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = [0.0000	0.0000	-0.087266	-0.087266	0.0000	0.00000];
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).Accel.t.Value         = [0.00	1.00	1.10	10.00	10.10	200.00];
    mdata.(Instance).Accel.t.Units         = 'sec';
    mdata.(Instance).Accel.t.Comments      = '';

    mdata.(Instance).Accel.rPedal.Value    = [0.00	0.00	0.25	0.25	0.00	0.00];
    mdata.(Instance).Accel.rPedal.Units    = '0-1';
    mdata.(Instance).Accel.rPedal.Comments = '';
end

% Unique settings (values)
mdata.Sedan_HambaLG.Brake.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00]; 
mdata.Bus_Makhulu.Brake.rPedal.Value   = [0.00	0.00	1.00	1.00	0.00	0.00]; 

mdata.Truck_Amandla.Brake.t.Value      = [0.00	31.00	31.20	190.00	191.00	200.00]; 
mdata.Truck_Amandla.Brake.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00]; 
mdata.Truck_Amandla.Steer.t.Value      = [0.00	25.00	25.20	180.00	181.00	200.00]; 
mdata.Truck_Amandla.Accel.t.Value      = [0.00	1.00	1.10	20.00	20.10	200.00];
mdata.Truck_Amandla.Accel.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00];

mdata.Truck_Rhuqa.Brake.t.Value      = [0.00	31.00	31.20	190.00	191.00	200.00]; 
mdata.Truck_Rhuqa.Brake.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00]; 
mdata.Truck_Rhuqa.Steer.t.Value      = [0.00	25.00	25.20	180.00	181.00	200.00]; 
mdata.Truck_Rhuqa.Accel.t.Value      = [0.00	1.00	1.10	20.00	20.10	200.00];
mdata.Truck_Rhuqa.Accel.rPedal.Value = [0.00	0.00	1.00	1.00	0.00	0.00];



maneuver_data.(maneuver_type) = mdata;
