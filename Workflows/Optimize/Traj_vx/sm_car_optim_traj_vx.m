function sm_car_optim_traj_vx(mdl, trackname, maxIter)
% Use optimization algorithms to find velocity trajectory along track
% that minimizes lap time and keeps car on the track
%
% Options for trackname: 
%   Flat track: 'CRG_Mallory_Park', 'CRG_Kyalami_f';
%               'CRG_Nurburgring_N_f', 'CRG_Suzuka_f';
% 
%   3D surface: 'CRG_Kyalami' 
%
% Copyright 2020-2021 The MathWorks, Inc.


% Select vehicle configuration (basic, flat roads only)
open_system(mdl);
warning off physmod:common:gl:sli:rtp:InvalidNonValueReferenceMask

% Get time at start of optimization for results file
datestringfile = datestr(now,'yymmddHHMM');

% Set up model for optimization
traj_coeff = setup_optim_traj_vx(mdl,trackname);
assignin('base','traj_coeff',traj_coeff);

% Store initial value of max and min speed
x0 = [traj_coeff.vmin traj_coeff.vmax traj_coeff.diff_exp];


%% Create plots
% Create figure for target velocity along path
if ~exist('h1_sm_car_optim', 'var') || ...
        ~isgraphics(h1_sm_car_optim, 'figure')
    h1_sm_car_optim = figure('Name', 'sm_car_optim_vx');
end
figure(h1_sm_car_optim)
clf(h1_sm_car_optim)
legend
title('Velocity Along Path');
hold on;
box on;

% Create figure for target path
if ~exist('h2_sm_car_optim', 'var') || ...
        ~isgraphics(h2_sm_car_optim, 'figure')
    h2_sm_car_optim = figure('Name', 'sm_car_optim_xy');
end
figure(h2_sm_car_optim)
clf(h2_sm_car_optim)

% Plot target path
Maneuver = evalin('base','Maneuver');
plot(Maneuver.Trajectory.x.Value,Maneuver.Trajectory.y.Value,'k--');
title('Target Path');
legend({'Target'});
axis equal
hold on;

%% Run optimization
% Clear structure in workspace that saves results
evalin('base',['OptRes_' trackname ' = [];']);

% Record start time for optimization
tOptStart = tic;

% Run optimization
%[x,~,~,~] = ...
%    fminunc(@obj_traj_vx,x0, ...
%    optimset('Tolx',1e-3,'Display','iter','MaxIter',maxIter,'DiffMinChange',1e-3,'TypicalX',[5 20 1.8]),...
%    mdl,trackname,h1_sm_car_optim,h2_sm_car_optim);

%[x,~,~,~] = ...
%    fminsearch(@obj_traj_vx,x0, ...
%    optimset('Tolx',1e-3,'Display','iter','MaxIter',maxIter),...
%    mdl,trackname,h1_sm_car_optim,h2_sm_car_optim);

options = optimoptions('patternsearch','PollMethod','GSSPositiveBasis2N', ...
    'Display','iter','PlotFcn', @psplotbestf,'MaxIterations',40, ...
    'MeshTolerance',0.01,'UseCompletePoll',true,'InitialMeshSize',mean(x0), ...
    'MeshContractionFactor',0.25);

LB = [4 5 1];  % Condition 1
UB = [15 40 2];   % Condition 2
% Constraints are defined in the form of Ax <= b
Am=[1 -1 0];
bm=[0.5];

[x,~,~,~] = ...
    patternsearch(@(x)obj_traj_vx(x, mdl,trackname,h1_sm_car_optim,h2_sm_car_optim),...
    x0,Am,bm,[],[],LB,UB,[],options);

% Record duration of optimization
tOptDuration = toc(tOptStart);
disp(['Elapsed time for optimization = ' num2str(tOptDuration)]);

% Return to folder where optimization scripts are to save results
cd(fileparts(which(mfilename)));

% -- Save results from optimization run to a file
% Get from workspace results written during each iteration
OptRes = evalin('base',['OptRes_' trackname ]);

% Add some results to final entry
OptRes(end).final = x;
OptRes(end).xref  = Maneuver.Trajectory.x.Value;
OptRes(end).yref  = Maneuver.Trajectory.y.Value;
OptRes(end).Vehicle  = evalin('base','Vehicle');

% Write final results back to workspace for plotting
assignin('base',['OptRes_' trackname],OptRes)

% Save final results to a file
eval(['OptRes_' trackname '  = OptRes;'])
[status, msg] = mkdir(['OptRes_' trackname]); %#ok<ASGLU>
savestr = ['save(''' pwd filesep 'OptRes_' trackname filesep 'OptRes_' trackname '_' datestringfile '.mat'', ''OptRes_' trackname ''');']; 
%disp(savestr);
eval(savestr);

% Reset model (remove settings only necessary for optimization)
reset_optim_traj_vx


