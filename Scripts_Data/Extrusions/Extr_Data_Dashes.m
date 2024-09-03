function [xy_data] = Extr_Data_Dashes(pitch, numdashes, dash_l, dash_h, Tb)
% EXTR_DATA_GEAR Produce extrusion data for a dashed line as a set of
% vertices.
%   [xy_data] = Extr_Data_Dashes(pitch, numdashes, dash_l, dash_h, Tb)
%   This function returns x-y data for a solid to represent a dashed line.
%   You can specify:
%       pitch     - Separation of dashes 
%       numdashes - Number of teeth
%       dash_l    - Length of dash
%       dash_h    - Height of dash
%       Tb        - Thickness of base of dash solid
% 
% The profile is centered about the midpoint of the  
% mid dash height.

% Copyright 2012-2024 The MathWorks, Inc.

showplot = 'n';

% DEFAULT DATA TO SHOW DIAGRAM
if (nargin == 0)
    pitch = 7.5;
    numdashes = 4;
    dash_l = 3;
    dash_h = 2;
    Tb = 4;
end

% Generate single tooth profile
dash_profile = [0    0; 
                 pitch-dash_l   0;
                 pitch-dash_l   dash_h;
                 pitch          dash_h];
    
% Repeat teeth             
rack_profile = [0 -Tb; dash_profile];             
for idx=2:numdashes
    dash_profile(:,1) = dash_profile(:,1) + pitch; 
    rack_profile = [rack_profile; dash_profile];
end
rack_profile = [rack_profile; numdashes*pitch 0; numdashes*pitch -Tb];       

% Center rack profile
rack_profile(:,1) = rack_profile(:,1) - numdashes*pitch/2;
rack_profile(:,2) = rack_profile(:,2) - dash_h/2;

xy_data = flipud(rack_profile);
dashes_origin_offset = [0 Tb+dash_h/2];
xy_data = xy_data + dashes_origin_offset; 
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
    
    % Plot extrusion
    patch(xy_data(:,1),xy_data(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(xy_data(:,1),xy_data(:,2),'-','Marker','o','MarkerSize',4,'LineWidth',2);
    axis('equal');
    
    % SHOW PARAMETERS
    hold on

	teeth_pts = [0 pitch 2*pitch]-dash_l/2;
    plot(teeth_pts,(dash_h+dashes_origin_offset(2))*ones(size(teeth_pts)),'r-x','MarkerFaceColor','r');
    text(pitch,dash_h*2+dashes_origin_offset(2),'{\color{red}numdashes}');

    plot([pitch  2*pitch]+[1 1]*dashes_origin_offset(1),[0 0]+[1 1]*dashes_origin_offset(2),'k-d','MarkerFaceColor','k','MarkerSize',10);
    text(1.25*pitch+dashes_origin_offset(1),+dash_h/4+dashes_origin_offset(2),'pitch');

    plot([1 1]*-dash_l/2+[1 1]*dashes_origin_offset(1),[-1 1]*dash_h/2+[1 1]*dashes_origin_offset(2),'b-d','MarkerFaceColor','b','MarkerSize',8);
    text(-dash_l/2+dashes_origin_offset(1),-dash_h+dashes_origin_offset(2), '{\color{blue}dash\_h}');

    plot([-1 0]*dash_l+[1 1]*dashes_origin_offset(1),[0 0]+[1 1]*dashes_origin_offset(2),'g-d','MarkerFaceColor','g','MarkerSize',8);
    text(0+dashes_origin_offset(1),0+dashes_origin_offset(2), '{\color{green}  dash\_l}');

    plot([-1 -1]*pitch/2+[1 1]*dashes_origin_offset(1),[-dash_h/2 -dash_h/2-Tb]+[1 1]*dashes_origin_offset(2),'c-d','MarkerFaceColor','c','MarkerSize',8);
    text(-pitch/2+[1 1]*dashes_origin_offset(2),-dash_h/2-Tb/2+[1 1]*dashes_origin_offset(2), '{\color{black}  Tb}');
    
    title('[xy\_data] = Extr\_Data\_Dashes(pitch, numdashes, dash\_l, dash\_h, Tb);');
    hold off
    box on
    
    clear xy_data
end
