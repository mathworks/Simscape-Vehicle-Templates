%% 1. Spring-Indep, Damper-Indep
sm_car_load_vehicle_data('sm_car','189');

%% 2. Spring-Indep None, Damper-Indep None
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Independent','None_SHlinA2_None');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Independent','None_SHlinA2_None');

%% 3. Spring-Inter None, Damper-Inter None
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Interconnected','None_SHlinA2_None');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Interconnected','None_SHlinA2_None');

%% 4. Spring-None None, Damper-None None
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_None','NoSpringA1_NoSpringA2_None');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_None','None_None_None');

%% 5. Spring-Inter Linear, Damper-Inter Linear
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Interconnected','SHlinA1_SHlinA2_None');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Interconnected','SHlinA1_SHlinA2_None');

%% 6. Spring Linear, Damper Linear
Vehicle = sm_car_vehcfg_setSpring(Vehicle,'Axle2_Linear_Sedan_HambaLG','SHlinA1_SHlinA2_None');
Vehicle = sm_car_vehcfg_setDamper(Vehicle,'Axle2_Interconnected','SHlinA1_SHlinA2_None');
