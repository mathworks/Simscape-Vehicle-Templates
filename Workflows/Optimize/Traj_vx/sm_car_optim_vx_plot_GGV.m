function sm_car_optim_vx_plot_GGV(optResStruct,varargin)
%sm_car_plot_ggv_surf   Plot lap results on GGV diagram
%   sm_car_optim_vx_plot_GGV(optResStruct,<plotTraces>,<GGV_data>)
%
%   This function plots lap results in a GGV diagram, which has lateral
%   acceleration on the x-axis, longitudinal acceleration on the y-axis,
%   and vehicle speed on the z-axis.  The surface representing the maximum
%   possible acceleration can be included in the plot
% 
%       optResStruct        Output of lap time optimization
%
%  You can optionally specify these arguments
%       plotTraces          Optionally specify which traces should be plotted
%                           Combine best, worst, and all into a single string  
%                           For example: 'bestworst','bestall'
%       GGV_data            Data for the surface representing maximum
%                           possible acceleration
% Example: 
%   sm_car_optim_vx_plot_GGV(OptRes_CRG_Mallory_Park,'bestworst')

% Copyright 2021 The MathWorks, Inc.

if(nargin==1)
    plotTraces = 'all';
    GGV_data = [];
elseif(nargin==2)
    plotTraces = varargin{1};
    GGV_data = [];
elseif(nargin==3)
    plotTraces = varargin{1};
    GGV_data = varargin{2};
end

% Identify valid, fastest, and slowest laps
num_iter = length(optResStruct);

% Find valid laps (laptime less than 10000)
[lt, lt_inds] = sort([optResStruct(1:end).laptime],'descend');
lt_ind_start = find(lt<10000,1);
lt_inds_valid = lt_inds(lt_ind_start:end);

% Find fastest and slowest laps
paramset = reshape([optResStruct(:).param],length(optResStruct(end).final),[])';
iter_min_inds = find(sum((paramset == optResStruct(end).final),2)==length(optResStruct(end).final));
iter_min = iter_min_inds(1);
iter_max = lt_inds_valid(1);

% Create placeholders for legend strings and port handles
legendstr = {'','','',''};
p_h       = [1 1 1 1];

% Assume multiple items will be plotted
hold on
if(~isempty(GGV_data))
    % Plot GGV surface
    clr_order = [...
        0         0.4470    0.7410;
        0.8500    0.3250    0.0980];
    fig_h_ggv = sm_car_plot_ggv_surf(GGV_data,false,clr_order(1,:));
    p_h(1) = findobj(fig_h_ggv, 'type', 'surface');
    legendstr{1} = 'GGV Surface';
    hold on
end

if(contains(plotTraces,'best'))
    % Plot fastest lap
    p_h(2) = plot3(-optResStruct(iter_min).bgy/9.81, optResStruct(iter_min).bgx/9.81,optResStruct(iter_min).vx,'r','LineWidth',1);
    legendstr{2} = ['Fastest: ' sprintf('%3.2f',optResStruct(iter_min).laptime) ' sec'];
end

if(contains(plotTraces,'worst'))
    % Plot slowest lap
    p_h(3) = plot3(-optResStruct(iter_max).bgy/9.81, optResStruct(iter_max).bgx/9.81,optResStruct(iter_max).vx,'b','LineWidth',1);
    legendstr{3} = ['Slowest: ' sprintf('%3.2f',optResStruct(iter_max).laptime) ' sec'];
end

if(contains(plotTraces,'all'))
    % Plot all laps
    for i = 1:num_iter
        plot3(-optResStruct(i).bgy/9.81, optResStruct(i).bgx/9.81,optResStruct(i).vx);
        if(optResStruct(i).laptime>=10000)
            % If there are failed runs, add a red dot at the end of the trace
            p_h(4) = plot3(-optResStruct(i).bgy(end)/9.81, optResStruct(i).bgx(end)/9.81,optResStruct(i).vx(end),'ro','MarkerFaceColor','r');
            legendstr{4} = 'End Failed Run';
        end
    end
end

% Adjust legend string based on what was plotted
legendstr = legendstr(~strcmp(legendstr,''));
p_h = p_h(p_h~=1);
if(~isempty(legendstr))
    legend(p_h,legendstr,"Location","best")
end
view(15,30)
grid on

% Ensure x and y axes have the same aspect ratio
xlims = get(gca,'XLim');
ylims = get(gca,'YLim');
zlims = get(gca,'ZLim');

maxxy = max([max(xlims)-min(xlims) max(ylims)-min(ylims)]);
set(gca,'DataAspectRatio',[1 1 (max(zlims)-min(zlims))/maxxy]);

ah = gca;
ah.Clipping = 'off';
