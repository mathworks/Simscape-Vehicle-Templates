function sm_car_plot3maneuver(Maneuver,sim_results)
% Function to plot key parameters of predefined maneuver
% Copyright 2018-2024 The MathWorks, Inc.


% Prepare first figure and handle
fig_handle_name =   'h1_sm_car_maneuver';

Init_type = evalin('base','Init.Type');

handle_var = evalin('base',['who(''' fig_handle_name ''')']);
if(isempty(handle_var))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
elseif ~isgraphics(evalin('base',handle_var{:}))
    evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
end
figure(evalin('base',fig_handle_name))
clf(evalin('base',fig_handle_name))
temp_colororder = get(gca,'defaultAxesColorOrder');

% Handle single simulation output or logsout directly
fieldnames_res = sim_results.getElementNames;
if(find(contains(fieldnames_res,'logsout_sm_car')))
    logsout_sm_car = sim_results.get('logsout_sm_car');
else
    logsout_sm_car = sim_results;
end

% Check type of maneuver
fieldlist = fieldnames(Maneuver);
hasTrajectory = find(strcmp(fieldlist,'Trajectory'), 1);
hasDriveCycle = find(strcmp(fieldlist,'DriveCycle'), 1);
hasAccel      = find(strcmp(fieldlist,'Accel'), 1);

if(~isempty(hasTrajectory) && isempty(hasAccel))
    
    Scene = evalin('base','Scene');
    hasTrack = true;
    if(startsWith(lower(Maneuver.Type),'crg_'))
        ctrline = Scene.(Maneuver.Type).Geometry.centerline.xyz(:,1:2);
        w = Scene.(Maneuver.Type).Geometry.w;
    elseif(isfield(Scene,Maneuver.Type))
    if(isfield(Scene.(Maneuver.Type),'Track'))
        ctrline = Scene.(Maneuver.Type).Track.ctrline;
        w = Scene.(Maneuver.Type).Track.w;
    else
    hasTrack = false;
    end
    else
        hasTrack = false;
    end
    if(hasTrack)
    [xy_data] = sm_car_road_track_extrusion(ctrline,w);
    patch(xy_data(:,1),xy_data(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    h2 = plot(xy_data(:,1),xy_data(:,2),'-','Marker','o','MarkerSize',1,'LineWidth',1);
    h3 = plot(ctrline(:,1),ctrline(:,2),'--','MarkerSize',1,'LineWidth',1);
    legend([h2 h3],{'Track','Center Line'},'Location','Best')
    end
    %hold off
    box on
    axis('equal');
    
    % Plot results for systems with a defined trajectory
    % Extract results
    logsout_VehBus = logsout_sm_car.get('VehBus');
    logsout_xCar = logsout_VehBus.Values.World.x;
    logsout_yCar = logsout_VehBus.Values.World.y;
    
    logsout_vx   = logsout_VehBus.Values.Chassis.Body.CG.vx;
    logsout_aYaw = logsout_VehBus.Values.World.aYaw;
    logsout_xBody = [0;cumsum(sqrt((diff(logsout_xCar.Data)).^2+diff(logsout_yCar.Data).^2))];
    
    logsout_DrvBus = logsout_sm_car.get('DrvBus');
    logsout_dist   = logsout_DrvBus.Values.Reference.dist;
    logsout_ref_ayaw = logsout_DrvBus.Values.Reference.ayaw;
    logsout_ref_vx   = logsout_DrvBus.Values.Reference.vTarget;
    
    ayaw_ref = interp1(Maneuver.Trajectory.xTrajectory.Value,Maneuver.Trajectory.aYaw.Value,logsout_dist.Data);
    h4=plot(Maneuver.Trajectory.x.Value,Maneuver.Trajectory.y.Value,'-o','MarkerSize',4,'Color',temp_colororder(4,:));
    hold on
    h5=plot(logsout_xCar.Data, logsout_yCar.Data, 'LineWidth', 1,'Color',temp_colororder(3,:));
    hold off
    axis equal
    xlabel('Global X (m)');
    ylabel('Global Y (m)');
    title('Trajectory (Global X, Y)');
    
    label_str = sprintf('Maneuver: %s\nData: %s',...
        strrep(Maneuver.Type,'_',' '),...
        strrep(Maneuver.Instance,'_',' '));
    text(0.05,0.9,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
    if(~isempty(hasTrajectory) && hasTrack)
        legend([h2 h3 h4 h5],{'Track','Center Line','Reference','Measured'},'Location','Best')
    else
        legend({'Reference','Measured'},'Location','Best');
    end
    
    % Prepare second figure handle
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
    plot(logsout_dist.Data,logsout_ref_vx.Data,'-o');
    hold on
    plot(logsout_dist.Data,logsout_vx.Data,'LineWidth',1);
    hold off
    title('Target Speed Along Trajectory');
    xlabel('Distance Traveled (m)');
    ylabel('Speed (m/s)');
    
    text(0.9,0.15,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5,...
        'HorizontalAlignment','right');
    legend({'Reference','Measured'},'Location','Best');
    
    ah(2) = subplot(212);
    plot(logsout_dist.Data,ayaw_ref,'-o');
    hold on
    
    % Determine when a lap is completed
    lapind = find(abs(diff(logsout_dist.Data))>50);
    if(isempty(lapind))
        lapind = length(logsout_dist.Data);
    end
    % Calculate an offset to keep heading angle in a 2*pi range
    % Determine if offset increases or decreases each lap
    yawUnwrap = unwrap(logsout_aYaw.Data);
    yawPerLap = sum(diff(unwrap(logsout_aYaw.Data(1:lapind(1)))));
    if(yawPerLap>1),      yWrapOffset =  2*pi;
    elseif(yawPerLap<-1), yWrapOffset = -2*pi;
    else,                 yWrapOffset =  0;
    end
    
    % Calculate offset
    yawOffset = zeros(size(logsout_aYaw.Data));
    for l_i = 1:length(lapind)
        yawOffset(lapind(l_i)+1:end) = yawOffset(lapind(l_i)+1:end)-yWrapOffset;
    end
    
    % Determine if reference and measured are offset by 2*pi
    yawUnwrapLap = yawUnwrap+yawOffset;
    check_inds = find(~isnan(ayaw_ref));
    u=mean(ayaw_ref(check_inds)-(yawUnwrapLap(check_inds)));
    if(u>1),      offset = 2*pi;
    elseif(u<-1), offset = -2*pi;
    else,         offset = 0;
    end
    
    plot(logsout_dist.Data,yawUnwrapLap+offset,'LineWidth',1);
    hold off
    xlabel('Distance Traveled (m)');
    ylabel('Target Yaw Angle (rad)');
    title('Target Yaw Angle Along Trajectory');
    linkaxes(ah, 'x')

	% Prepare third figure handle
    fig_handle_name = 'h3_sm_car_maneuver';
    handle_var = evalin('base',['who(''' fig_handle_name ''')']);
    if(isempty(handle_var))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    elseif ~isgraphics(evalin('base',handle_var{:}))
        evalin('base',[fig_handle_name ' = figure(''Name'', ''' fig_handle_name ''');']);
    end
    figure(evalin('base',fig_handle_name))
    clf(evalin('base',fig_handle_name))
    
    ah3(1) = subplot(211);
    plot(logsout_ref_vx.Time,logsout_ref_vx.Data,'-o');
    hold on
    plot(logsout_vx.Time,logsout_vx.Data,'LineWidth',1);
    hold off
    title('Target Speed vs. Time');
    ylabel('Speed (m/s)');
    
    text(0.9,0.15,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5,...
        'HorizontalAlignment','right');
    legend({'Reference','Measured'},'Location','Best');
    
    ah3(2) = subplot(212);
    plot(logsout_dist.Time,ayaw_ref,'-o');
    hold on

	plot(logsout_dist.Time,yawUnwrapLap+offset,'LineWidth',1);
    hold off
    xlabel('Time (s)');
    ylabel('Yaw Angle (rad)');
    title('Target Yaw Angle vs Time');
    linkaxes(ah3, 'x')

elseif(~isempty(hasDriveCycle))
    % Plot results for systems with a defined trajectory
    % Extract results
    logsout_VehBus = logsout_sm_car.get('VehBus');
    logsout_vx   = logsout_VehBus.Values.Chassis.Body.CG.vx;
    
    logsout_DrvBus = logsout_sm_car.get('DrvBus');
    logsout_ref_vx   = logsout_DrvBus.Values.Reference.vTarget;

    plot(logsout_ref_vx.Time,logsout_ref_vx.Data,'-o');
    hold on
    plot(logsout_vx.Time,logsout_vx.Data,'LineWidth',1);
    hold off
    title('Target Speed Along Trajectory');
    xlabel('Distance Traveled (m)');
    ylabel('Speed (m/s)');

    config_str = evalin('base','Vehicle.config');
    label_str = sprintf('Drive Cycle: %s\nVehicle: %s',...
        strrep(Maneuver.Instance,'_',' '),...
        strrep(config_str,'_','\_'));

    text(0.9,0.1,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5,...
        'HorizontalAlignment','right');
    legend({'Reference','Measured'},'Location','NorthWest');

elseif(contains(lower(Init_type),'testrig_post'))
    sm_car_plot5bodymeas

elseif(~isempty(hasTrajectory) && ~isempty(hasAccel))
    logsout_VehBus = logsout_sm_car.get('VehBus');
    logsout_xCar = logsout_VehBus.Values.World.x;
    logsout_yCar = logsout_VehBus.Values.World.y;
    
    logsout_vx   = logsout_VehBus.Values.Chassis.Body.CG.vx;
    
    logsout_DrvBus = logsout_sm_car.get('DrvBus');
    logsout_dist   = logsout_DrvBus.Values.Reference.dist;
    logsout_ref_vx   = logsout_DrvBus.Values.Reference.vTarget;
    logsout_aSteerWheel = logsout_DrvBus.Values.aSteerWheel*180/pi;

    ah(1) = subplot(211);
    plot(logsout_vx.Time,logsout_vx.Data,'LineWidth',1);
    title('Speed vs. Time');
    ylabel('Speed (m/s)');

    label_str = sprintf('Maneuver: %s\nData: %s',...
        strrep(Maneuver.Type,'_',' '),...
        strrep(Maneuver.Instance,'_',' '));
    text(0.5,0.2,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);

    ah(2) = subplot(212);
    plot(Maneuver.Steer.t.Value,Maneuver.Steer.aWheel.Value*180/pi,'-o','LineWidth',2);
    hold on
    plot(logsout_aSteerWheel.Time,logsout_aSteerWheel.Data,'--x','LineWidth',1);
    hold off
    ylabel('Angle (deg)')
    title('Steering Wheel Angle');
    xlabel('Time (s)');
    legend({'Reference','Measured'},'Location','NorthWest');

    linkaxes(ah, 'x')
else
    % Plot Maneuver with Open-Loop Driver Commands
    % Extract simulation results
    logsout_DrvBus = logsout_sm_car.get('DrvBus');
    logsout_aSteerWheel = logsout_DrvBus.Values.aSteerWheel*180/pi;
    logsout_rAccelPedal = logsout_DrvBus.Values.rAccelPedal;
    logsout_rBrakePedal = logsout_DrvBus.Values.rBrakePedal;
    
    ah(1) = subplot(311);
    plot(Maneuver.Accel.t.Value,Maneuver.Accel.rPedal.Value,'-o','LineWidth',2);
    hold on
    plot(logsout_rAccelPedal.Time,logsout_rAccelPedal.Data,'--x','LineWidth',1);
    hold off
    ylabel('Travel (0-1)');
    title('Accelerator Pedal Travel');
    legend({'Command','Measured'},'Location','Best');
    set(gca,'YLim',[0 1]);
    
    ah(2) = subplot(312);
    plot(Maneuver.Brake.t.Value,Maneuver.Brake.rPedal.Value,'-o','LineWidth',2);
    hold on
    plot(logsout_rBrakePedal.Time,logsout_rBrakePedal.Data,'--x','LineWidth',1);
    hold off
    ylabel('Travel (0-1)');
    title('Brake Pedal Travel');
    set(gca,'YLim',[0 1]);
    
    ah(3) = subplot(313);
    plot(Maneuver.Steer.t.Value,Maneuver.Steer.aWheel.Value*180/pi,'-o','LineWidth',2);
    hold on
    plot(logsout_aSteerWheel.Time,logsout_aSteerWheel.Data,'--x','LineWidth',1);
    hold off
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
    set(ah(1),'XLim',[logsout_aSteerWheel.Time(1) logsout_aSteerWheel.Time(end)]);
end

