function sm_car_config_solver(mdl,simtype)
%sm_car_config_solver  Set solver for Simscape Vehicle model
%   sm_car_config_solver(mdl,simtype)
%   This function configures the solvers.
%   simtype is "variable step", "fixed step", or "fixed step slrt"
%
% Copyright 2018-2024 The MathWorks, Inc.

desktop_solver = 'ode23t';

realtime_nonlinIter = '2';
realtime_stepSize = '0.002';
realtime_localSolver = 'Backward Euler';
realtime_globalSolver = 'ode1';


f=Simulink.FindOptions('FollowLinks',0,'RegExp',1,'SearchDepth',1);
solverBlock_pth=Simulink.findBlocks(mdl,'UseLocalSolver','.*',f);

Vehicle = evalin('base','Vehicle');

% Defaults
set_param(mdl, 'SimscapeLogType', 'all');
%set_param(mdl,'SimMechanicsOpenEditorOnUpdate','on')

if strcmpi(simtype,'variable step')
    set_param(mdl,'Solver',desktop_solver);    
    for svb_i=1:size(solverBlock_pth,1)
        set_param(solverBlock_pth(svb_i), 'UseLocalSolver','off','DoFixedCost','off');
    end
    
	cs = getActiveConfigSet(mdl);
    switchTarget(cs,'grt.tlc',[]);

    %Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,'variable');
    
else
    % If local solver is enabled, disable warning concerning 
    % Simscape Multibody support of local solver
    warning('off','sm:sli:setup:compile:LocalSolverNotSupported');
    set_param(mdl,'Solver',realtime_globalSolver,'FixedStep','auto');
    for svb_i=1:size(solverBlock_pth,1)
        set_param(solverBlock_pth(svb_i),...
            'UseLocalSolver','on',...
            'DoFixedCost','on',...
            'MaxNonlinIter',realtime_nonlinIter,...
            'LocalSolverChoice',realtime_localSolver,...
            'LocalSolverSampleTime',realtime_stepSize);
    end
    %Vehicle = sm_car_vehcfg_setTireSolver(Vehicle,'fixed');
    
    if(endsWith(simtype,'slrt'))
        % For use with Simulink Real-Time, turn warnings off
        warning('off','coder_xcp:host:SignalNotAvailable');
        warning('off','coder_xcp:host:VirtualBusSignalNotAvailable');
        warning('off','SimulinkRealTime:slrt:SignalListCannotBeStreamed');
        % For external mode, disable logging and Mechanics Explorer
        set_param(mdl,'SimscapeLogType', 'none');
        set_param(mdl,'SimMechanicsOpenEditorOnUpdate','off')

        cs = getActiveConfigSet(mdl);
        if(verLessThan('matlab','9.9'))
            slrtTargetFile = 'slrt.tlc';
        else
            % R2020b and higher
            slrtTargetFile = 'slrealtime.tlc';
        end
        switchTarget(cs,slrtTargetFile,[]);
        
    else
        cs = getActiveConfigSet(mdl);
        switchTarget(cs,'grt.tlc',[]);
    end
end

assignin('base','Vehicle',Vehicle);