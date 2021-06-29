% Script to test battery display blocks
% Copyright 2018-2021 The MathWorks, Inc.

% Open project sm_car
% Move to folder with these files in it

%% Close main model
bdclose('sm_car');

cd(fileparts(which(mfilename)))

%% List of Files To Replace
filelist_ORIG = {'Cooling_Motor2_Liquid_Loop1.slx','Power_Components.slx'};
filelist_NEW  = {'Cooling_Motor2_Liquid_Loop1_4Battery.slx','Power_Components_4Battery.slx'};

%% Swap in battery files
for i = 1:length(filelist_ORIG)
    o=which(filelist_ORIG{i},'-all');
    [~,f,e] = fileparts(o{1});
    
    % Save copy of original file
    copyfile(o{1},[pwd filesep f '_ORIG' e]);
    
    % Replace source with new file
    copyfile([pwd filesep filelist_NEW{i}],o{1});
end

% Save copy of sm_car
o=which('sm_car','-all');
[p,f,e] = fileparts(o{1});
copyfile(o{1},[pwd filesep f '_ORIG' e]);

%%
% Open and configure model with dashboard
open_system('sm_car');

add_block(...
    'sm_car_display_battery/Battery Display',...
    'sm_car/Vehicle/Battery Display',...
    'MakeNameUnique','on',...
    'Position',[215   417   295   463]);

add_line('sm_car/Vehicle','Vehicle/1','Battery Display/1','autorouting','on')
add_line('sm_car/Vehicle','Vehicle/LConn3','Battery Display/RConn1','autorouting','on')

%% Configure model
CDatabase.Camera.Hamba.Top.s.Value = [-1.7 0 4];
CDatabase.Camera.Hamba.Top.a.Value = [0 90 0];
sm_car_load_vehicle_data('sm_car','167');
sm_car_config_maneuver('sm_car','CRG Kyalami');
sm_car_config_vehicle('sm_car');
set_param('sm_car','StopTime','9000')
Maneuver.vGain.Value = 1;  % 1.8

%% Simulate model
set_param('sm_car','StopTime','50');
sim('sm_car')
sm_car_plot7power(logsout_sm_car);

%% Undo changes to files
for i = 1:length(filelist_ORIG)
    o=which(filelist_ORIG{i},'-all');
    [p,f,e] = fileparts(o{1});
   
    % Save copy of original file
    copyfile([pwd filesep f '_ORIG' e],o{1});
end

%% Close model
bdclose('sm_car')
