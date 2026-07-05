function ax_h = sm_car_gs_grid_surface_plot(SceneData,varargin)
   
% Figure name
if(nargin==2)
    ax_h = varargin{1};
else
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
    ax_h = gca;
end

[xm, ym] = meshgrid(SceneData.gsd.xg,SceneData.gsd.yg);
surf(xm,ym,SceneData.gsd.z_heights')
hold on
plot3(...
    SceneData.gsd.xg, ...
    repmat(SceneData.gsd.yg(1),1,length(SceneData.gsd.xg)),...
    SceneData.gsd.z_heights(:,1)','ro','MarkerFaceColor','r')
plot3(...
    repmat(SceneData.gsd.xg(1),1,length(SceneData.gsd.yg)),...
    SceneData.gsd.yg, ...
    SceneData.gsd.z_heights(1,:)','go')

hold off
xlabel(ax_h,'X (m)');
ylabel(ax_h,'Y (m)');
zlabel(ax_h,'Z (m)');
title(ax_h,[strrep(SceneData.Name,'_','\_') ' (no offsets)'])
box on
%axis equal
