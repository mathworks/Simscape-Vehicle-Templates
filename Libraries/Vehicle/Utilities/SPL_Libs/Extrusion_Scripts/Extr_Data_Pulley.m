function [xy_data] = Extr_Data_Pulley(rad_p, h_grv, rad_h, a_grv, th_p,  varargin)
%Extr_Data_Pulley Produce Produce *revolution* data for a pulley.
%   [xy_data] = Extr_Data_Pulley((rad_p, h_grv, rad_h, a_grv, th_p)
%   This function returns x-y data for a pulley for use in a revolved solid.
%   You can specify:
%       Pulley radius	 rad_p   (radius where cable wraps)
%       Depth of groove	 h_grv   (height of edges surrounding cable)
%       Hole radius      rad_h   
%       Angle of groove	 a_grv   (angle of edges surrounding cable)
%       Pulley thickness th_p
%
%   To see a plot showing parameter values, enter the name
%   of the function with no arguments
%   >> Extr_Data_Pulley
%
%   To see a plot created with your parameter values,
%   add 'plot' as the final argument
%   >> Extr_Data_Pulley(0.025,0.005,0.005,25,0.02,'plot')

% Copyright 2012-2024 The MathWorks, Inc.

% Default data to show diagram
if (nargin == 0)
    rad_p = 0.025;
    rad_h = 0.005;
    h_grv = 0.005;
    a_grv = 25;
    th_p  = 0.02;
end

% Check if plot should be produced
if (isempty(varargin))
    showplot = 'n';
else
    showplot = varargin;
end

d_grv = min(h_grv,(th_p/2)/tand(a_grv));
w_grWall = d_grv*tand(a_grv);

% Calculate revolution data
xy_data = [...
  rad_p+d_grv         ,  0.5 * th_p;...
  rad_h               ,  0.5 * th_p;...
  rad_h               , -0.5 * th_p;...
  rad_p+d_grv         , -0.5 * th_p];

if (w_grWall >= (th_p/2))
  xy_data = [...
      xy_data;...
      rad_p , 0];
else
  xy_data = [...
      xy_data;...
      rad_p+d_grv , -0.5*(th_p)+(0.5*(th_p)-w_grWall)/2;...
      rad_p       , -(0.5*(th_p)-w_grWall)/2;...
      rad_p       , +(0.5*(th_p)-w_grWall)/2;...
      rad_p+d_grv , +0.5*(th_p)-(0.5*(th_p)-w_grWall)/2];
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
    
    temp_colordef = get(gca,'ColorOrder');
    
    % Plot extrusion
    patch(xy_data(:,1),xy_data(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(xy_data(:,1),xy_data(:,2),'-','Marker','o','MarkerSize',4,'LineWidth',2);
    axis('equal');
    axis([-1.1 1.1 -1.1 1.1]*(rad_p+d_grv));

    
    % Mirror data to show revolution
    patch(-xy_data(:,1),xy_data(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(-xy_data(:,1),xy_data(:,2),'-.','Color',temp_colordef(1,:),...
        'MarkerEdgeColor',temp_colordef(1,:),'Marker','o','MarkerSize',4,'LineWidth',1);
    
   
    % Show parameters
    hold on
    
    plot([0 rad_p ],[0 0],'r-d','MarkerFaceColor','r');
    text(rad_p/2,rad_p*0.05,'{\color{red}rad\_p}',...
        'HorizontalAlignment','center');
    
    plot([rad_p rad_p+h_grv],[1 1]*0.5*th_p/2,'g-d','MarkerFaceColor','g');
    text(rad_p+h_grv/2,1.5*th_p/2,'{\color{green}h\_grv}',...
        'HorizontalAlignment','center');
    
    if (w_grWall >= (th_p/2))
       pt_ind = 4;
    else
       pt_ind = 5;
    end

	plot([0 xy_data(pt_ind,1)],[xy_data(pt_ind,2) xy_data(pt_ind,2)],'k:');
	plot([0 xy_data(pt_ind,1)],[xy_data(pt_ind,1)*tand(a_grv)+xy_data(pt_ind,2) xy_data(pt_ind,2)],'k:');

    arc1_r = xy_data(pt_ind,1);

    arc1 = linspace(0,a_grv,50)';
    plot((1-cosd(arc1))*arc1_r,sind(arc1)*arc1_r+xy_data(pt_ind,2),'k-');
    plot((1-cosd(arc1(1)))*arc1_r,sind(arc1(1))*arc1_r+xy_data(pt_ind,2),'kd','MarkerFaceColor','k');
    plot((1-cosd(arc1(end)))*arc1_r,sind(arc1(end))*arc1_r+xy_data(pt_ind,2),'kd','MarkerFaceColor','k');
    text((1-cosd(arc1(end)))*arc1_r,sind(arc1(end))*arc1_r+xy_data(pt_ind,2),' a\_grv');

    plot([0 0], [-1 1]*2*th_p,'k-.');
    plot([0 rad_h],[1 1]*(-th_p),'b-d','MarkerFaceColor','b');
    text(rad_h,-th_p,'{\color{blue} rad\_h}');

	plot([1 1]*(rad_h+rad_p)*0.6,[-1 1]*th_p/2,'c-d','MarkerFaceColor','c');
    text((rad_h+rad_p)*0.6,th_p/2*1.5,'{\color{cyan} th\_p}',...
        'HorizontalAlignment','right');

    title(['[xy\_data] = Extr\_Data\_Pulley(rad\_p, h\_grv, rad\_h, a\_grv, th\_p);']);
    
    hold off
    box on
    clear xy_data
end
