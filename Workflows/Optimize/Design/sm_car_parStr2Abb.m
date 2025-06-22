function parAbb = sm_car_parStr2Abb(parStr0)

% Convert parameter structure string to abbreviation
parStr0a = strrep(parStr0 ,'Vehicle.Chassis.SuspA1.Linkage.','A1');
parStr0b = strrep(parStr0a,'Vehicle.Chassis.SuspA2.Linkage.','A2');
parStr0c = strrep(parStr0b,'Vehicle.Chassis.SuspA1.Simple.','A1');
parStr0d = strrep(parStr0c,'Vehicle.Chassis.SuspA2.Simple.','A2');
parStr0e = strrep(parStr0d,'Vehicle.Chassis.SuspA1.LiveAxle.','A1');
parStr0f = strrep(parStr0e,'Vehicle.Chassis.SuspA2.LiveAxle.','A2');
parStr0g = strrep(parStr0f,'Vehicle.Chassis.SuspA1.TwistBeam.','A1');
parStr1  = strrep(parStr0g,'Vehicle.Chassis.SuspA2.TwistBeam.','A2');
parStr2 = strrep(parStr1,'.Value(','');
parStr3 = strrep(parStr2,')','');
parStr4 = strrep(parStr3,'UpperWishbone.','UW');
parStr5 = strrep(parStr4,'LowerWishbone.','LW');
parStr6 = strrep(parStr5,'InboardF','F');
parStr7 = strrep(parStr6,'InboardR','R');
parStr8 = strrep(parStr7,'LowerArm','LA');
parStr9 = strrep(parStr8,'UpperArm','UA');
parStr10 = strrep(parStr9,'.s','');
parStr11 = strrep(parStr10,'board','');
parStr12 = strrep(parStr11,'(','');
parStr13 = strrep(parStr12,')','');
parStr14 = strrep(parStr13,'.','');

parAbb = parStr14;