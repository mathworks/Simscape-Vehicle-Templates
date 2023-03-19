%% Vehicle 2 axle
for i = 0:212
    hp_i = pad(num2str(i),3,'left','0');
    load(['Vehicle_' hp_i '.mat'])
    eval(['hp_check_sum = sm_car_vehcfg_checkHPs(Vehicle_' hp_i ',false);']);
    if(hp_check_sum.total>0)
        disp(['HP checksum fail on ' hp_i ': ' num2str(hp_check_sum.total)]);
    end
end


%% Vehicle 3 axle
for i = 0:22
    hp_i = pad(num2str(i),3,'left','0');
    load(['Vehicle_Axle3_' hp_i '.mat'])
    eval(['hp_check_sum = sm_car_vehcfg_checkHPs(Vehicle_Axle3_' hp_i ',false);']);
    if(hp_check_sum.total>0)
        disp(['HP checksum fail on ' hp_i ': ' num2str(hp_check_sum.total)]);
    end
end

%% Trailer 1 axle
for i = 01:11
    hp_i = pad(num2str(i),2,'left','0');
    load(['Trailer_' hp_i '.mat'])
    eval(['hp_check_sum = sm_car_vehcfg_checkHPs(Trailer_' hp_i ',false);']);
    if(hp_check_sum.total>0)
        disp(['HP checksum fail on ' hp_i ': ' num2str(hp_check_sum.total)]);
    end
end

%% Trailer 2 axle
for i = 0:32
    hp_i = pad(num2str(i),3,'left','0');
    load(['Trailer_Axle2_' hp_i '.mat'])
    eval(['hp_check_sum = sm_car_vehcfg_checkHPs(Trailer_Axle2_' hp_i ',false);']);
    if(hp_check_sum.total>0)
        disp(['HP checksum fail on ' hp_i ': ' num2str(hp_check_sum.total)]);
    end
end