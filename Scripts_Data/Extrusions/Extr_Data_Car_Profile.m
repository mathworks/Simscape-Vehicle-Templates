function [xy_data_top, xy_data_side] = Extr_Data_Car_Profile(whl_rad, whl_base, thk, varargin)
%Extr_Data_Car_Profile Produce extrusion data for a car profile.
%   [xy_data_top, xy_data_side] = Extr_Data_Car_Profile(whl_rad, whl_base, thk, varargin)
%   This function returns x-y data for a car profile.
%   [0, 0] is at the center of the front wheel cutout.
%   You can specify:
%       Radius of wheel cutouts    whl_rad
%       Length of whl_base         whl_base
%       Thickness of top profile   thk
%
%   To see a plot showing parameter values, enter the name
%   of the function with no arguments
%   >> Extr_Data_Car_Profile
%
%   To see a plot created with your parameter values,
%   add 'plot' as the final argument
%   >> Extr_Data_Car_Profile(0.43, 3.2, 0.05,'plot')

% Copyright 2018-2024 The MathWorks, Inc.

if (nargin == 0)
    whl_rad = 0.43;
    whl_base = 3.2;
    thk = 0.05;
end

% Check if plot should be produced
if (isempty(varargin))
    showplot = 'n';
else
    showplot = varargin;
end

whl_rad_nominal = 0.43;
whl_base_nominal = 3.2;

wrad_dl = whl_rad - whl_rad_nominal;
wbase_dl = whl_base - whl_base_nominal;

xy_grill = [0.7095 -0.2129];
xy_ell_hood = Extr_Data_Ellipse(1.2949,0.3548,180,360-45,1).*[-1 -1]+[-0.5854 0.2129+wrad_dl];
xy_ell_roof = Extr_Data_Ellipse(0.8514*1.05+wbase_dl/2,0.2483+wbase_dl/2*0.2483/0.8514,180+10,360-20,1).*[-1 -1]+[-2.1641-wbase_dl/2 0.7805+wrad_dl];
xy_trunk = [...
    -3.5477    0.7024;...
    -4.0798    0.6670]+[-wbase_dl wrad_dl];
xy_ell_rear1 = flipud(Extr_Data_Ellipse(0.1064,0.1419,120,205,1)).*[-1 -1]+[-4.1933-wbase_dl    0.6244+wrad_dl];
xy_ell_rear2 = flipud(Extr_Data_Ellipse(0.1206,0.2838,120,245,1)).*[-1 1].*[-1 -1]+[-4.0514-wbase_dl    0.2980+wrad_dl];
xy_ell_rear3 = [-4.0656-wbase_dl    0.0497+wrad_dl];
xy_ell_rear4 = [-4.0656-wbase_dl   -0.2129];
xy_ell_rear5 = [3.9450+whl_rad 1.2772].*[-1 -1]+[0.7450-wbase_dl    1.0643];
xy_ringwhlr = fliplr(Extr_Data_Ring(whl_rad,0,90,360-90)).*[-1 -1]+[-3.2000-wbase_dl 0];
xy_bottom1 = [3.9450-whl_rad 1.2772; 0.7450+whl_rad-wbase_dl 1.2772].*[-1 -1]+[0.7450-wbase_dl    1.0643];
xy_ringwhlf = fliplr(Extr_Data_Ring(whl_rad,0,90,360-90)).*[-1 -1];
xy_whlf2botf = [0.7450-whl_rad 1.2772].*[-1 -1]+[0.7450    1.0643];


car_top_profile  = [xy_grill;xy_ell_hood;xy_ell_roof;xy_trunk;xy_ell_rear1;xy_ell_rear2;xy_ell_rear3;xy_ell_rear4];
xy_data_side = [car_top_profile;xy_ell_rear5;xy_ringwhlr;xy_bottom1;xy_ringwhlf;xy_whlf2botf];

car_top_outer_profile = Extr_Data_Cam_Roller_Curve(car_top_profile,thk,'outside');
car_top_outer_profile(1,:) = [car_top_outer_profile(1,1) car_top_profile(1,2)];
car_top_outer_profile(end,:) = [car_top_outer_profile(end,1) car_top_profile(end,2)];
xy_data_top = [car_top_outer_profile;flipud(car_top_profile)];

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
    
    % Plot extrusion
    subplot(211)
	patch(xy_data_top(:,1),xy_data_top(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(xy_data_top(:,1),xy_data_top(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1);
    text(0.9, 0.9, 'xy\_data\_top','Units','Normalized','HorizontalAlignment','right');
    axis('equal');
    box on;

	% Show parameters
    [~, I_in] = max(car_top_profile,[],1);
    [~, I_out] = max(car_top_outer_profile,[],1);
    
	plot(...
        [car_top_profile(I_in(2), 1) car_top_outer_profile(I_out(2), 1)],...
	    [car_top_profile(I_in(2), 2) car_top_outer_profile(I_out(2), 2)],...
        'g-d','MarkerFaceColor','g');
    text(car_top_profile(I_in(2),1),car_top_profile(I_in(2),2)-thk*2,'{\color{green}thk}','HorizontalAlignment','center');
    title('[xy\_data\_top, xy\_data\_side] = Extr\_Data\_Car\_Profile(whl\_rad, whl\_base, thk)'); 
    
    subplot(212)
	patch(xy_data_side(:,1),xy_data_side(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(xy_data_side(:,1),xy_data_side(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1);
    text(0.9, 0.9, 'xy\_data\_side','Units','Normalized','HorizontalAlignment','right');
    axis('equal');
	% Show parameters
	plot([0 -whl_base],[0 0],'r-d','MarkerFaceColor','r');
    text(-whl_base/2,max(xy_data_side(:,2))*0.075,'{\color{red}whl\_base}');

    wrad_label_ang = 135;
    plot([0 whl_rad*(cosd(wrad_label_ang))],[0 whl_rad*(sind(wrad_label_ang))],'k-d','MarkerFaceColor','k');
    text(whl_rad*0.75*(cosd(wrad_label_ang)),whl_rad*0.75*(sind(wrad_label_ang)),'{\color{black}wheel\_cutout\_radius   }','HorizontalAlignment','right','VerticalAlignment','Bottom');
    hold off
    box on;
    
        % Figure name
    figString = ['h2_' mfilename];
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

    plot(xy_grill(:,1),xy_grill(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_grill');hold on
    plot(xy_ell_hood(:,1),xy_ell_hood(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_ell_hood');
    plot(xy_ell_roof(:,1),xy_ell_roof(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_ell_roof');
    plot(xy_trunk(:,1),xy_trunk(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_trunk');
    plot(xy_ell_rear1(:,1),xy_ell_rear1(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_ell_rear1');
    plot(xy_ell_rear2(:,1),xy_ell_rear2(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_ell_rear2');
    plot(xy_ell_rear3(:,1),xy_ell_rear3(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_ell_rear3');
    plot(xy_ell_rear4(:,1),xy_ell_rear4(:,2),'-','Marker','o','MarkerSize',2,'LineWidth',1,'DisplayName','xy_ell_rear4');
    hold off
    axis equal
    legend('Location','Best')
end