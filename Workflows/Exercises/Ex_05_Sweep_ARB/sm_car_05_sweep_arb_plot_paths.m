% Script to plot paths of vehicle from sweep of anti-roll bar stiffness
% Copyright 2021 The MathWorks, Inc.

if(exist('simOut','var'))
    
    % Clear results figure if it already exists.
    if exist('sm_car_sweep_path', 'var')
        if isgraphics(sm_car_sweep_path, 'figure')
            clf( sm_car_sweep_path, 'reset' )
        end
    end
    sm_car_sweep_path = figure('Name', 'sm_car_sweep_path');
    
    temp_colororder = get(gca,'defaultAxesColorOrder');
    
    plot(Maneuver.Trajectory.x.Value,Maneuver.Trajectory.y.Value,'-o','MarkerSize',4,'Color',temp_colororder(4,:),'DisplayName','Reference');
    hold on
    
    for i = 1:length(simOut)
        logsout_sm_car = simOut(i).logsout;
        
        logsout_VehBus = logsout_sm_car.get('VehBus');
        logsout_xCar = logsout_VehBus.Values.World.x;
        logsout_yCar = logsout_VehBus.Values.World.y;
        
        
        h5=plot(logsout_xCar.Data, logsout_yCar.Data,...
            'LineWidth', 1,'DisplayName', ['k = ' num2str(k(i)) ' Nm/deg']);%,'Color',temp_colororder(3,:));
    end
    hold off
    axis equal
    xlabel('Global X (m)');
    ylabel('Global Y (m)');
    title('Trajectory (Global X, Y)');
    
    label_str = sprintf('Maneuver: %s\nData: %s',...
        'Double Lane Change with Bump',...
        strrep(Maneuver.Instance,'_',' '));
    text(0.05,0.9,label_str,...
        'Units','Normalized','Color',[1 1 1]*0.5);
    
    legend('Location','Best')
    set(gca,'XLim',[185 225]);
else
    error('Please run sm_car_05_sweep_arb.mlx to generate simulation results.')
end
