function sm_car_sim_res_plot(strX,strY,varargin)
% sm_car_plot_res  Plot simulation results from Simscape Vehicle Templates
%    sm_car_plot_res(strX,strY,<axis handle>,<logsout>,<simlog>,<Vehicle>)
%
%    Provide two strings that are abbreviations for simulation results to
%    be plotted.  Optionally provide axis handle, simulation results, and
%    Vehicle data structure, otherwise standard values will be taken from
%    workspace.
%
% Copyright 2018-2025 The MathWorks, Inc.

if(nargin<=3)
    fig_h = [];
    logsout = evalin('base','logsout_sm_car');
    simlog  = evalin('base','simlog_sm_car');
    Vehicle = evalin('base','Vehicle');
end
if(nargin>=3)
    fig_h = varargin{1};
end
if(nargin>3)
    logsout = varargin{2};
    simlog  = varargin{3};
    Vehicle = varargin{4};
end

% Get simulation results based on input strings
sim_resX  = sm_car_sim_res_get(logsout,simlog,Vehicle,strX);
sim_resY  = sm_car_sim_res_get(logsout,simlog,Vehicle,strY);

% Create figure handle if no handle has been provided
if(isempty(fig_h))
    fig_handle_name =   'h1_sm_car_plot_res';

    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    temp_colororder = get(gca,'defaultAxesColorOrder');
    ax_h = gca;
else
    ax_h = fig_h;
end

% Plot results
plot(ax_h,sim_resX.data,sim_resY.data,'LineWidth',1)
xlabel(ax_h,[sim_resX.name ' (' sim_resX.units ')'])
ylabel(ax_h,[sim_resY.name ' (' sim_resY.units ')'])

if (strcmp(sim_resX.units,'s'))
    title(ax_h,sim_resY.name)
else
    title(ax_h,[sim_resY.name ' vs. ' sim_resX.name]);
end

if(isfield(sim_resY,'labels'))
    legend(ax_h,sim_resY.labels,'Location','Best');
else
    legend(ax_h,'off')
end

if(isfield(sim_resY,'note'))
    text(ax_h,0.05,0.05,sim_resY.note,'Color',[0.6 0.6 0.6],...
        'Units','Normalized');
end


grid(ax_h,'on');


