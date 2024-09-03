function maneuver_data = sm_car_maneuverdata_drivecycle

Instance_List = {...
    'FTP75','UrbanCycle1'};

for i=1:length(Instance_List)
    maneuver_type = 'DriveCycle';
    Instance      = Instance_List{i};
    mdata.DriveCycle.(Instance).Type                  = maneuver_type;
    mdata.DriveCycle.(Instance).Instance              = Instance;
    mdata.DriveCycle.(Instance).DriveCycle_LoadFile.Value    = ['DriveCycle_' Instance '.mat'];
    mdata.DriveCycle.(Instance).DriveCycle_LoadFile.Units    = '';
    mdata.DriveCycle.(Instance).DriveCycle_LoadFile.Comments = '';
    mdata.DriveCycle.(Instance).DriveCycle = ...
        load(mdata.DriveCycle.(Instance).DriveCycle_LoadFile.Value);
end

maneuver_data = mdata;
