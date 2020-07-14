function sm_car_config_solver(mdl,simtype)
%sm_car_config_solver  Set solver for Simscape Vehicle model
%   sm_car_config_solver(mdl,simtype)
%   This function configures the solvers.
%   simtype is "variable step" or "fixed step"
%
% Copyright 2018-2020 The MathWorks, Inc.

desktop_solver = 'ode23t';

realtime_nonlinIter = '3';
realtime_stepSize = '0.005';
realtime_localSolver = 'Backward Euler';
realtime_globalSolver = 'ode3';


f=Simulink.FindOptions('FollowLinks',0,'RegExp',1);
solverBlock_pth=Simulink.findBlocks(mdl,'ReferenceBlock','sm_car_lib/Environment/CarWorldConfig');

Vehicle = evalin('base','Vehicle');

if strcmpi(simtype,'variable step')
    set_param(mdl,'Solver',desktop_solver);    
    for svb_i=1:size(solverBlock_pth,1)
        set_param(solverBlock_pth(svb_i), 'UseLocalSolver','off','DoFixedCost','off');
    end
    Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,'variable','front');
    Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,'variable','rear');
else
    set_param(mdl,'Solver',realtime_globalSolver,'FixedStep','auto');
    for svb_i=1:size(solverBlock_pth,1)
        set_param(solverBlock_pth(svb_i),...
            'UseLocalSolver','on',...
            'DoFixedCost','on',...
            'MaxNonlinIter',realtime_nonlinIter,...
            'LocalSolverChoice',realtime_localSolver,...
            'LocalSolverSampleTime',realtime_stepSize);
    end
    Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,'fixed','front');
    Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,'fixed','rear');
end

assignin('base','Vehicle',Vehicle);