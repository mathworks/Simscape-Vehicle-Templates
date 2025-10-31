function [xy_data] = sm_car_road_track_extrusion(track_ctrline,track_width,varargin)
%sm_car_road_track_extrusion  Configure maneuver for Simscape Vehicle Model
%   sm_car_road_track_extrusion(track_ctrline, track_width)
%   This function creates extrusion data for a track based on its center
%   line profile and track width.
%
% Copyright 2018-2025 The MathWorks, Inc.

% Check if plot should be produced
if (isempty(varargin))
    showplot = 'n';
else
    showplot = varargin;
end

% Create outer and inner profile
xy_data1=Extr_Data_Cam_Roller_Curve(track_ctrline(:,1:2),track_width/2,'Outside');
xy_data2=Extr_Data_Cam_Roller_Curve(track_ctrline(:,1:2),track_width/2,'Inside');

distance_endStart = ...
    sqrt(...
    (track_ctrline(end,1)-track_ctrline(1,1))^2 + ...
    (track_ctrline(end,2)-track_ctrline(1,2))^2);

% Check for closed tracks
if(distance_endStart<50)
    % For closed tracks, ensure ends of extrusion data meet
    xy_data = flipud([flipud([xy_data1;xy_data1(1,:)]);[xy_data2;xy_data2(1,:)]]);
else
    % For open tracks, do not connect ends
    xy_data = flipud([flipud([xy_data1(2:end,:)]);[xy_data2(2:end,:)]]);
end

% Plot diagram to show parameters and extrusion
if (nargin == 0 || strcmpi(showplot,'plot'))
    
    % Figure name
    figString = ['h1_' mfilename];
    % Only create a figure if no figure exists
    figExist = 0;
    fig_hExist = evalin('base',['exist(''' figString ''')']);
    if (fig_hExist)
        figExist = evalin('base',['ishandle(' figString ') && strcmp(get(' figString ', ''type''), ''figure'')']);
    end
    if ~figExist
        fig_h = figure('Name',figString);
        assignin('base',figString,fig_h);
    else
        fig_h = evalin('base',figString);
    end
    figure(fig_h)
    clf(fig_h)
    
    temp_colororder = get(gca,'defaultAxesColorOrder');
    
    % Plot extrusion data
    patch(xy_data(:,1),xy_data(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    h2 = plot(xy_data(:,1),xy_data(:,2),'-','Marker','o','MarkerSize',1,'LineWidth',1);
    h3 = plot(track_ctrline(:,1),track_ctrline(:,2),'--','MarkerSize',1,'LineWidth',1);
    axis('equal');
    hold off
    box on
    
    title('[xy\_data] = sm\_car\_road\_track\_extrusion(track\_ctrline,track\_width);');
    legend([h2 h3],{'Track','Center Line'},'Location','Best')

    clear xy_data
end
