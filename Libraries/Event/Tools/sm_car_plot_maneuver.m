function sm_car_plot_maneuver(Maneuver,varargin)
% Function to plot key parameters of predefined maneuver
% Copyright 2018-2024 The MathWorks, Inc.

if(nargin==1)
    plotInds = 0;
else
    plotInds = varargin{1};
end

fig_handle_name = 'h1_sm_car_maneuver';

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))

%temp_colororder = get(gca,'defaultAxesColorOrder');

fieldlist = fieldnames(Maneuver);

hasTrajectory = find(strcmp(fieldlist,'Trajectory'), 1);
hasDriveCycle = find(strcmp(fieldlist,'DriveCycle'), 1);

if(~isempty(hasTrajectory))
	% Plot Maneuver with Trajectory
    plot(Maneuver.Trajectory.x.Value,Maneuver.Trajectory.y.Value,'-o')
    axis equal
    xlabel('Global X (m)')
    ylabel('Global Y (m)')
    maneuver_name = strrep([Maneuver.Type  ', ' Maneuver.Instance],'_',' ');
    title('Trajectory (Global X, Y)');
    
    label_str = sprintf('Maneuver: %s\nData: %s',...
        strrep(Maneuver.Type,'_',' '),...
        strrep(Maneuver.Instance,'_',' '));
    text(0.05,0.9,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
    
    if(plotInds>0)
        inds = 1:plotInds:length(Maneuver.Trajectory.xTrajectory.Value);
        
        ptlabel = string(inds) + " " + string(round(Maneuver.Trajectory.xTrajectory.Value(inds))) + "m";
        
        text(Maneuver.Trajectory.x.Value(inds),Maneuver.Trajectory.y.Value(inds),ptlabel);       
    end
    
    fig_handle_name = 'h2_sm_car_maneuver';
    
    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    
    ah(1) = subplot(211);
    plot(Maneuver.Trajectory.xTrajectory.Value,Maneuver.Trajectory.vx.Value,'-o')
    title('Target Speed Along Trajectory');
    xlabel('Distance Traveled (m)');
    ylabel('Target Speed (m/s)');
    
    text(0.05,0.7,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
    
    if(plotInds>0)
        inds = 1:plotInds:length(Maneuver.Trajectory.xTrajectory.Value);
        text(Maneuver.Trajectory.xTrajectory.Value(inds),Maneuver.Trajectory.vx.Value(inds),string(inds));
    end
    
    ah(2) = subplot(212);
    plot(Maneuver.Trajectory.xTrajectory.Value,Maneuver.Trajectory.aYaw.Value,'-o')
    xlabel('Distance Traveled (m)');
    ylabel('Target Yaw Angle (rad)');
    title('Target Yaw Angle Along Trajectory');
    linkaxes(ah, 'x')
    
    if(plotInds>0)
        inds = 1:plotInds:length(Maneuver.Trajectory.xTrajectory.Value);
        text(Maneuver.Trajectory.xTrajectory.Value(inds),Maneuver.Trajectory.aYaw.Value(inds),string(inds));
    end
elseif(~isempty(hasDriveCycle))
	% Plot Maneuver with Drive Cycle
    plot(Maneuver.DriveCycle.cycle_t.Value,Maneuver.DriveCycle.cycle_spd.Value,'-o')
    xlabel('Time (sec)')
    ylabel(['Speed ' Maneuver.DriveCycle.cycle_spd.Units]);
    maneuver_name = strrep([Maneuver.Type  ', ' Maneuver.Instance],'_',' ');
    title(['Drive Cycle ' Maneuver.Instance]);
    
    label_str = sprintf('Maneuver: %s\nData: %s',...
        strrep(Maneuver.Type,'_',' '),...
        strrep(Maneuver.Instance,'_',' '));
    text(0.05,0.9,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);

else
	% Plot Maneuver with Open-Loop Driver Commands
    ah(1) = subplot(311);
    plot(Maneuver.Accel.t.Value,Maneuver.Accel.rPedal.Value,'-o');
    ylabel('Travel (0-1)');
    title('Accelerator Pedal Travel');
    set(gca,'YLim',[0 1]);
    ah(2) = subplot(312);
    plot(Maneuver.Brake.t.Value,Maneuver.Brake.rPedal.Value,'-o');
    ylabel('Travel (0-1)');
    title('Brake Pedal Travel');
    set(gca,'YLim',[0 1]);
    ah(3) = subplot(313);
    plot(Maneuver.Steer.t.Value,Maneuver.Steer.aWheel.Value*180/pi,'-o');
    ylabel('Angle (deg)')
    title('Steering Wheel Angle');
    xlabel('Time (s)');
    subplot(311)
    linkaxes(ah, 'x')
    label_str = sprintf('Maneuver: %s\nData: %s',...
        strrep(Maneuver.Type,'_',' '),...
        strrep(Maneuver.Instance,'_',' '));
    text(0.05,0.2,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
end
