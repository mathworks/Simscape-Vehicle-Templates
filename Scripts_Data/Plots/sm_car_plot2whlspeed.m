% Code to plot simulation results from sm_car
%% Plot Description:
%
% Plot results of vehicle test: position, x and y velocity components,
% vehicle speed, and steering input.
%
% Copyright 2018-2020 The MathWorks, Inc.

% Check for simulation results
if ~exist('logsout_sm_car', 'var')
    error('logsout_sm_car data not available.')
end

% Reuse figure if it exists, else create new figure
if ~exist('h2_sm_car', 'var') || ...
        ~isgraphics(h2_sm_car, 'figure')
    h2_sm_car = figure('Name', 'sm_car');
end
figure(h2_sm_car)
clf(h2_sm_car)

temp_colororder = get(gca,'defaultAxesColorOrder');

% Get simulation results
logsout_VehBus = logsout_sm_car.get('VehBus');

logsout_vxVeh = logsout_VehBus.Values.World.vx;
logsout_vyVeh = logsout_VehBus.Values.World.vy;
logsout_sVeh = sqrt(logsout_vxVeh.Data.^2+logsout_vyVeh.Data.^2);
logsout_xCar = logsout_VehBus.Values.World.x;
logsout_yCar = logsout_VehBus.Values.World.y;

logsout_nWhlFL = logsout_VehBus.Values.Chassis.WhlFL.n;
logsout_nWhlFR = logsout_VehBus.Values.Chassis.WhlFR.n;
logsout_nWhlRL = logsout_VehBus.Values.Chassis.WhlRL.n;
logsout_nWhlRR = logsout_VehBus.Values.Chassis.WhlRR.n;

%simlog_sveh = logsout_sm_car.get('sVeh');
%simlog_wwhl = logsout_sm_car.get('wWhl');
%simlog_vwhl = logsout_sm_car.get('vWhl');
%simlog_pveh = logsout_sm_car.get('pVeh');

logsout_px0 = logsout_xCar.Data(1);
logsout_py0 = logsout_yCar.Data(1);

if(isfield(Vehicle.Chassis.TireF,'tirFile'))
    tir_fileF = Vehicle.Chassis.TireF.tirFile.Value;
elseif(isfield(Vehicle.Chassis.TireF,'TireInner'))
    tir_fileF = Vehicle.Chassis.TireF.TireInner.tirFile.Value;
elseif(isfield(Vehicle.Chassis.TireF,'tire_radius'))
    tir_fileF = 'none';
else
    error('tirFile field not found in Vehicle data structure');
end

if(isfield(Vehicle.Chassis.TireR,'tirFile'))
    tir_fileR = Vehicle.Chassis.TireR.tirFile.Value;
elseif(isfield(Vehicle.Chassis.TireR,'TireInner'))
    tir_fileR = Vehicle.Chassis.TireR.TireInner.tirFile.Value;
elseif(isfield(Vehicle.Chassis.TireR,'tire_radius'))
    tir_fileR = 'none';
else
    error('tirFile field not found in Vehicle data structure');
end

if(~strcmp(tir_fileF,'none'))
    tir_fileF = strrep(tir_fileF,'which(''','');
    tir_fileF = strrep(tir_fileF,''')','');
    temptirparams = mfeval.readTIR(which(tir_fileF));
    tire_radiusF = temptirparams.UNLOADED_RADIUS;
else
    tire_radiusF = Vehicle.Chassis.TireF.tire_radius.Value;
end

if(~strcmp(tir_fileR,'none'))
    tir_fileR = strrep(tir_fileR,'which(''','');
    tir_fileR = strrep(tir_fileR,''')','');
    temptirparams = mfeval.readTIR(which(tir_fileR));
    tire_radiusR = temptirparams.UNLOADED_RADIUS;
else
    tire_radiusR = Vehicle.Chassis.TireR.tire_radius.Value;
end

% Plot results
plot(logsout_vxVeh.Time, logsout_sVeh*3.6, 'k--', 'LineWidth', 1)
hold on
plot(...
    logsout_nWhlFL.Time, logsout_nWhlFL.Data*3.6*tire_radiusF,...
    logsout_nWhlFR.Time, logsout_nWhlFR.Data*3.6*tire_radiusF,...
    logsout_nWhlRL.Time, logsout_nWhlRL.Data*3.6*tire_radiusR,...
    logsout_nWhlRR.Time, logsout_nWhlRR.Data*3.6*tire_radiusR,...
    'LineWidth', 1)
hold off
grid on
title('Wheel Speed')
ylabel('Speed (km/hr)')
xlabel('Time (s)')
legend({'Vehicle','FL','FR','RL','RR'},'Location','Best');

temp_tire_sys = find_system(bdroot,'LookUnderMasks','on','FollowLinks','on','Name','Tire FL');
temp_tire_sys_vehi = find(contains(temp_tire_sys,'/Vehicle/Chassis/'));
tire_variant_name = char(get_param(temp_tire_sys(temp_tire_sys_vehi),'ActiveVariant'));
text(0.1,0.8,sprintf('Tire %s\nSteps: %d',tire_variant_name,length(logsout_vxVeh.Time)),'Units','Normalized','Color',[1 1 1]*0.5);
text(0.1,0.65,sprintf('xFinal: %0.2f m\nyFinal: %0.2f m',...
    logsout_xCar.Data(end)-logsout_px0,logsout_yCar.Data(end)-logsout_py0),'Units','Normalized','Color',[1 1 1]*0.5);

if(isfield(Vehicle,'config'))
    config_string = Vehicle.config;
else
    config_string = 'custom';
end

text(0.05,0.1,sprintf('%s\n%s',strrep(config_string,'_','\_'),get_param(bdroot,'Solver')),...
    'Color',[1 1 1]*0.5,'Units','Normalized')

clear tire_variant_name temp_tire_sys

delvars = setdiff(who('logsout_*'),'logsout_sm_car');
clear(delvars{:},'delvars');

clear temp_colororder
