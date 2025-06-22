function hdls = sm_car_plot3d_plot_data(hdls, vehGeom, posVeh, psiVeh, ...
    velVeh, tirePx, tirePy, tirePz, toe, camber, tireF, timeCurr, ...
    figBorder, whlRad, plotTireF, plot3D, plotVehicle, plotPatch)
% sm_car_plot3d_plot_data  Plot results from simulation in 3D
%   This function plots some key results from a vehicle simulation.  This
%   makes it easier to align numerical values with locations and
%   orientations. The plot can be controlled by input parameters, such as the
%   time range, visual elements to include, and if a 2D or 3D view is
%   desired.  The code can be modified to include other elements
%
%   hdls        Graphic handles to update plot
%   vehGeom     Data for patches representing vehicle
%   posVeh      Position of vehicle reference frame in global coordinates
%   psiVeh      [Roll, Pitch, Yaw] angles of vehicle body
%   velVeh      Velocity of vehicle reference frame in global coordinates
%   tirePx      X-position of all tire centers [FL, FR, RL, RR] in global coordinates
%   tirePy      Y-position of all tire centers [FL, FR, RL, RR] in global coordinates
%   tirePz      Z-position of all tire centers [FL, FR, RL, RR] in global coordinates
%   toe         Toe angles of all tires [FL, FR, RL, RR] in local frame
%                 CCW as viewed from above is positive
%   camber      Camber angles of all tires [FL, FR, RL, RR] in local frame
%                 CCW as viewed from rear is positive
%   tireF       Tire forces, columns [FL, FR, RL, RR] rows [Fx, Fy, Fz]
%   timeCurr    Instant in time to be plotted
%   figBorder   Half of width and length for plot axes (m)
%   whlRad      Tire Radius (m)
%   plotTireF   Add tire forces to plot
%   plot3D      Create 3D view of data (2D if false)
%   plotVehicle Add to plot vehicle chassis to plot
%   plotPatch   Add to plot patch showing path on ground traced by vehicle body
%
% Copyright 2025 The MathWorks, Inc.

%% Create axis figure handle - needed for all plot elements
if ~isfield(hdls,'axH'); hdls.axH  = gca(hdls.figH); end

%% Calculate the orientation of vehicle and tire
% Rotation matrix for orienting vehicle visual.
vehRotMat    = rpyToRotationMatrix(psiVeh(1,1), psiVeh(1,2), psiVeh(1,3));

% Rotation matrix for orienting vehicle visual.
% Function requires (roll, pitch, yaw)
% Wheel Roll Angle  = Vehicle Roll Angle + Tire Camber angle
% Wheel Pitch Angle = Vehicle Pitch Angle  (tires do not spin)
% Wheel Yaw Angle   = Vehicle Yaw Angle + Tire Toe angle
tireFLRotMat = rpyToRotationMatrix(psiVeh(1,1)+camber(1), psiVeh(1,2), psiVeh(1,3)+toe(1));
tireFRRotMat = rpyToRotationMatrix(psiVeh(1,1)+camber(2), psiVeh(1,2), psiVeh(1,3)+toe(2));
tireRLRotMat = rpyToRotationMatrix(psiVeh(1,1)+camber(3), psiVeh(1,2), psiVeh(1,3)+toe(3));
tireRRRotMat = rpyToRotationMatrix(psiVeh(1,1)+camber(4), psiVeh(1,2), psiVeh(1,3)+toe(4));

% Stores all positions of the COG of the vehicle
if ~isfield(hdls,'posVeh')
    hdls.posVeh = posVeh;
else
    hdls.posVeh = [hdls.posVeh; posVeh];
end

% Obtain vehicle velocity in vehicle coordinates
vehVel  = vehRotMat*velVeh';

% Position of the tire following sequence FL; FR; RL; RR
tireF(abs(tireF)<50) = 0.1;         % To avoid chattering
tireF                = tireF/1000;  % Scale

%% 1) Create the figure (if needed)
% The code below is only called the first time this function is executed.
% If the struct does not have any assigned figure, create a new one.
if ~isfield(hdls,'figH')
    % Set figure name and axle handles
    hdls.figH = figure('Name','Vehicle Position','Color','w');

    % Set font size and axis labels
    xlabel(hdls.axH,'X (m)'); ylabel(hdls.axH,'Y (m)');
    set(hdls.axH,'NextPlot','add','Box','on','XGrid', 'on', 'YGrid', 'on', 'ZGrid', 'on');

    % Set aspect ratio to axis equal:
    daspect(hdls.axH,[1 1 1]);
end

%% 2) Plot tires and rims
% Check if there are re-usable handles for the tires
if ~isfield(hdls,'wheelPatches')
    plotFirst = 1;
else
    plotFirst = 0;
end

% Loop over tires
for i=1:4
    % Loop over patches
    for ii=1:numel(vehGeom.Wheel.faces)

        % Patch of one wheel
        wheelPts = vehGeom.Wheel.vertices{ii};

        % Mirror solids for left wheels
        % Assumed order is L, R, L, R
        if (rem(i,2)==1) ; wheelPts = ([-1,0,0;0,-1,0;0,0,1]*wheelPts')'; end

        switch (i)
            % Select rotation matrix based on wheel
            case 1, rotMatWhl = tireFLRotMat;
            case 2, rotMatWhl = tireFRRotMat;
            case 3, rotMatWhl = tireRLRotMat;
            case 4, rotMatWhl = tireRRRotMat;
        end

        % Vertex locations = Reorented vertices + global wheel center position
        wheelPosAbs  = rotMatWhl*wheelPts' + [tirePx(i) tirePy(i) tirePz(i)]';

        if (plotFirst)
            hdls.wheelPatches{i,ii} = patch(hdls.axH,...
                'Faces', vehGeom.Wheel.faces{ii}, ...
                'Vertices', wheelPosAbs', ...
                'FaceColor', vehGeom.Wheel.colors{ii}, ...
                'FaceAlpha',vehGeom.Wheel.opacities{ii}, ...
                'EdgeColor', 'none', 'FaceLighting', 'gouraud', ...
                'AmbientStrength', 0.3, 'DiffuseStrength', 0.8, ...
                'SpecularStrength', 0.9, 'SpecularExponent', 25, ...
                'BackFaceLighting', 'reverselit');
        else
            set(hdls.wheelPatches{i,ii},'Vertices',wheelPosAbs'); 
        end
    end
end

% Plot tire forces
if (plotTireF)
    % Loop over tires
    for numTire=1:4
        % Obtain force components in global coordinates 
        tireForceX = vehRotMat*rotMatrix(toe(numTire))*[tireF(1,numTire);0;0];
        tireForceY = vehRotMat*rotMatrix(toe(numTire))*[0;tireF(2,numTire);0];

        posTire = [tirePx; tirePy; tirePz];  % Global tire center positions
        if (plotFirst)
            % Create handles.  Plot xy components near ground.
            hdls.tireX{numTire} = quiver3(hdls.axH,...
                posTire(1,numTire),posTire(2,numTire),posTire(3,numTire)-whlRad*0.9,...
                tireForceX(1),tireForceX(2),tireForceX(3),'Color','r', 'LineWidth', 1, 'MaxHeadSize', 0.1);
            hdls.tireY{numTire} = quiver3(hdls.axH,...
                posTire(1,numTire),posTire(2,numTire),posTire(3,numTire)-whlRad*0.9,...
                tireForceY(1),tireForceY(2),tireForceY(3),'Color','r', 'LineWidth', 1, 'MaxHeadSize', 0.1);
        else
            % Update data associated with handles
            set(hdls.tireX{numTire},'XData',posTire(1,numTire),'YData',posTire(2,numTire),'ZData',posTire(3,numTire)-whlRad*0.9,...
                'UData',tireForceX(1),'VData',tireForceX(2),'WData',tireForceX(3));
            set(hdls.tireY{numTire},'XData',posTire(1,numTire),'YData',posTire(2,numTire),'ZData',posTire(3,numTire)-whlRad*0.9,...
                'UData',tireForceY(1),'VData',tireForceY(2),'WData',tireForceY(3));
        end
    end

    % Plot tire forces in Z
    if (plotFirst)
        % Create handles.  Plot z components near ground.
        hdls.tireZ = quiver3(hdls.axH,posTire(1,:),posTire(2,:),posTire(3,:)-whlRad*0.9,...
            zeros(1,4),zeros(1,4),tireF(3,:),'Color','r', 'LineWidth', 1, 'MaxHeadSize', 0.1);
    else
        % Update data associated with handles
        set(hdls.tireZ,'XData',posTire(1,:),'YData',posTire(2,:),'ZData',posTire(3,:)-whlRad*0.9,'WData',tireF(3,:));
    end
end

%% 3) Plot vehicle and forces
% Plot the vehicle body (use cellfun to loop through all patch elements)
if plotVehicle==1 && ~isfield(hdls,'vehPatches')
    hdls.vehPatches = cellfun(@(f,v,c,o) patch(hdls.axH,...
        'Faces', f, 'Vertices', (vehRotMat*v'+posVeh')',...
        'FaceColor',c, 'FaceAlpha', o, ...
        'EdgeColor','none','FaceLighting','gouraud','DiffuseStrength', 0.8,'SpecularExponent',25),...
        vehGeom.Vehicle.faces, vehGeom.Vehicle.vertices, vehGeom.Vehicle.colors,...
        vehGeom.Vehicle.opacities,'UniformOutput', false);
elseif plotVehicle ==1
    cellfun(@(patch, v) set(patch, 'Vertices', (vehRotMat*v'+posVeh')'), ...
        hdls.vehPatches, vehGeom.Vehicle.vertices, 'UniformOutput', false);
end

% Plot the first point of the vehicle trajectory (only if user does not want to use patch plot)
if plotPatch==0 && ~isfield(hdls,'vehPath')
    hdls.vehPath = plot3(hdls.axH,posVeh(1),posVeh(2),posVeh(3),'bo','MarkerFaceColor','b', 'MarkerEdgeColor', 'k');
elseif plotPatch==0
    set(hdls.vehPath,'XData',hdls.posVeh(:,1),'YData',hdls.posVeh(:,2),'ZData',hdls.posVeh(:,3));
end

% Text Box with details
if (~isfield(hdls,'txtbxHndl'))
    % Create handles
    str = sprintf('Velocity: %3.1f m/s |  Time: %3.2f sec',round(norm(velVeh)),timeCurr);
    hdls.txtbxHndl = text(hdls.axH,'String',str,'Position',[0.5 -0.15 0], 'BackgroundColor',[1,1,1],'Units','Normalized','HorizontalAlignment','center');
else
    % Update string associated with handles
    txtBxString = sprintf('Velocity: %3.1f m/s |  Time: %3.2f sec',norm(velVeh),timeCurr);
    set(hdls.txtbxHndl,'String',txtBxString);
end

%% 3) Plot speed vector
% For better visibility, the speed vector needs to be scaled
if ~isfield(hdls,'speedVec')
    % Create handles
    hdls.speedVec = quiver3(hdls.axH,posVeh(1),posVeh(2),posVeh(3)+0.5,velVeh(1)/4,velVeh(2)/4,velVeh(3)/4,'Color','b', 'LineWidth', 2, 'MaxHeadSize', 0.4);
else
    % Update string associated with handles
    set(hdls.speedVec,'XData',posVeh(1),'YData',posVeh(2),'ZData',posVeh(3)+0.5,'UData',velVeh(1)/4,'VData',velVeh(2)/4,'WData',velVeh(3)/4);
end

%% Plot vehicle patch (if requested)
if (plotPatch==1 && plotVehicle ==1)
    cpInd = vehGeom.Vehicle.ChassisPatchInd;
    patchPosition = vehRotMat*(vehGeom.Vehicle.vertices{cpInd})' + posVeh'; patchPosition(3,:) = posVeh(3)+0.05;
    hdls.vehPatch = patch(hdls.axH,'Faces', hdls.vehPatches{cpInd}.Faces, 'Vertices', patchPosition','FaceColor', [1,0,0], 'FaceAlpha', 0.8,'EdgeColor', 'none', 'FaceLighting', 'gouraud','AmbientStrength', 0.3, 'DiffuseStrength', 0.8,'SpecularStrength', 0.9, 'SpecularExponent', 25, 'BackFaceLighting', 'reverselit');
end

%% Update the axles and set the view

% Update the plot axes if needed (because the car reached the edge of the plot)
%newXlim = get(hdls.axH,'Xlim'); newYlim = get(hdls.axH,'Ylim');

% Rescale figure and ticks
hdls.axH.XLim= [posVeh(end,1)-figBorder   posVeh(end,1)+figBorder];
hdls.axH.YLim= [posVeh(end,2)-figBorder   posVeh(end,2)+figBorder];
hdls.axH.ZLim= [posVeh(end,3)-figBorder/3 posVeh(end,3)+figBorder/3];

% Generate 3 evenly spaced tick positions
rangeX = (hdls.axH.XLim(2)-hdls.axH.XLim(1));
rangeY = (hdls.axH.YLim(2)-hdls.axH.YLim(1));
rangeZ = (hdls.axH.ZLim(2)-hdls.axH.ZLim(1));
xticks(hdls.axH,round(posVeh(end,1)+[-rangeX*0.45,0,rangeX*0.45],1));
yticks(hdls.axH,round(posVeh(end,2)+[-rangeY*0.45,0,rangeY*0.45],1));
zticks(hdls.axH,round(posVeh(end,3)+[-rangeZ*0.45,0,rangeZ*0.45],1));

% If 3D plot is requested scale the axles
if (plot3D == 0) 
    view(hdls.axH,2); 
end

end

function rotMat = rotMatrix(delta)
rotMat = [cos(delta) -sin(delta) 0; sin(delta) cos(delta) 0; 0 0 1];
end
