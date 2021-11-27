%% Minimize Lap Time Using Optimization, Kyalami (No Elevation Change)
% 
% This example shows how to minimize lap times using optimization
% algorithms using the Kyalami Grand Prix Circuit. This optimization
% assumes no elevation to shorten the optimization process.
% 
% Copyright 2020-2021 The MathWorks, Inc.

%% 
% <html><h2>Results of Optimization</h2></html>

Overview_Dir = pwd;
cd(Overview_Dir)
close all
clear OptRes_*
clear opt_iter

mdl = 'sm_car';
open_system(mdl);
set_param(mdl,'FastRestart','off');
if(verLessThan('matlab','9.11'))
    sm_car_load_vehicle_data(mdl,'164'); % (Hamba 15DOF, MFeval)
    load GGV_Hamba_0to40      % GGV_data for sedan
else
    sm_car_load_vehicle_data(mdl,'193'); % (Hamba 15DOF, Multibody tire)
    load GGV_Hamba_0to40      % GGV_data for sedan

    % Alternate: FSAE Vehicle
    %sm_car_load_vehicle_data(mdl,'198'); % (FSAE, Mbody)
    %load GGV_Achilles_0to40   % GGV_data for FSAE

end

Vehicle = sm_car_vehcfg_checkConfig(Vehicle);

sm_car_optim_traj_vx(mdl,'CRG_Kyalami_f',25);
sm_car_optim_vx_plot(OptRes_CRG_Kyalami_f)

sm_car_optim_vx_plot_GGV(OptRes_CRG_Kyalami_f,'bestworst',GGV_data)

cd(Overview_Dir)
close(3)
close(4)
close(5)
close(6)
close(7)

%%
%clear all
close all
%bdclose all