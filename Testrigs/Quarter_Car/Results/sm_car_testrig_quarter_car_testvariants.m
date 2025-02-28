% Script to test many configurations of vehicle model
% Copyright 2019-2024 The MathWorks, Inc.

cd(fileparts(which('testrig_quarter_car.slx')));
cd('Results')
mdl = 'testrig_quarter_car';

open_system(mdl);

testnum = 0;
now_string = datestr(now,'yymmdd_HHMM');

veh_config = {...
    '000',... % dwb
    '016',... % dwa
    '032',... % Split LA, StoLAF
    '048',... % Split LA, StoLAR
    '064',... % 5Link, S to LAF
    '080',... % 5Link, S to LAF constraint
    '096',... % 5Link, S to LAR
    };

for veh_i = 1:length(veh_config)
    sm_car_load_vehicle_data(mdl,veh_config{veh_i});
    sm_car_config_variants(mdl);
    testnum = testnum+1;
    %suffix_str = ['Ca' veh_config{veh_i}];
    suffix_str = get_param([bdroot '/Linkage'],'ActiveVariant');
    filenamefignow = [mdl '_' now_string '_' suffix_str '.png'];
    filenamefig    = [mdl '_'                suffix_str '.png'];
    filenameTbl    = [mdl '_'                suffix_str 'Table.mat'];
    disp_str = suffix_str;
    
    disp(['Run ' num2str(testnum) ' ' disp_str]);
    
    out=sim(mdl);
    TSuspMetrics = sm_car_testrig_quarter_car_plot1toecamber(out,true);
    
    saveas(gcf,filenamefignow);
    saveas(gcf,filenamefig);
    if(veh_i~=2)
        save(filenameTbl,"TSuspMetrics")
    end
end

Linkage = VDatabase.Linkage.DoubleWishbonePullrod_FSAE_Achilles_f;
AntiRollBar = VDatabase.AntiRollBar.DroplinkRod_FSAE_Achilles_f;
InitLinkage = Init.Axle1;
Visual = sm_car_param_visual('fsae');

mdl = 'testrig_quarter_car_pullrod';
open_system(mdl);
suffix_str = 'DoubleWishbone_Pullrod';
filenamefignow = [mdl '_' now_string '_' suffix_str '.png'];
filenamefig    = [mdl '_'                suffix_str '.png'];
filenameTbl    = [mdl '_'                suffix_str 'Table.mat'];
disp_str = suffix_str;
   
disp(['Run ' num2str(testnum+1) ' ' disp_str]);
out = sim(mdl);
TSuspMetrics = sm_car_testrig_quarter_car_plot1toecamber(out,true);
saveas(gcf,filenamefignow);
saveas(gcf,filenamefig);
save(filenameTbl,"TSuspMetrics")

mdl = 'testrig_quarter_car_pullrod_noSteer';
open_system(mdl);
suffix_str = 'DoubleWishbone_Pullrod_noSteer';
filenamefignow = [mdl '_' now_string '_' suffix_str '.png'];
filenamefig    = [mdl '_'                suffix_str '.png'];
filenameTbl    = [mdl '_'                suffix_str 'Table.mat'];
disp_str = suffix_str;

Linkage = VDatabase.Linkage.DoubleWishbonePullrodNoSteer_FSAE_Achilles_r;
AntiRollBar = VDatabase.AntiRollBar.DroplinkRod_FSAE_Achilles_r;
InitLinkage = Init.Axle2;
Visual = sm_car_param_visual('fsae');

disp(['Run ' num2str(testnum+2) ' ' disp_str]);
out = sim(mdl);
TSuspMetrics = sm_car_testrig_quarter_car_plot1toecamber(out,true);
saveas(gcf,filenamefignow);
saveas(gcf,filenamefig);

