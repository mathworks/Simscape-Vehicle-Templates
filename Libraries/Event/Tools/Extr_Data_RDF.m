function [xy_data_L, xy_data_R] = Extr_Data_RDF(filename, poly_line_depth, varargin)
%Extr_Data_RDF Produce extrusion data from RDF file.
%   [[xy_data_L, xy_data_R] = Extr_Data_RDF(filename)
%   This function returns x-y data left and right road surfaces.
%   You specify:
%       filename                        Name of the RDF file
%       poly_line_depth                 Depth of road surface
%
%   To see a plot created with your parameter values,
%   add 'plot' as the final argument
%   >> Extr_Data_RDF(10,5,'plot')

% Copyright 2013-2024 The MathWorks, Inc.

showplot = 'n';
if(nargin>2)
    showplot = varargin{1};
end

road_raw = importdata(filename,' ');

line_i = 1;
rdf_type = [];
while (line_i < length(road_raw.textdata) || ...
        isempty(rdf_type))
    linetext = road_raw.textdata{line_i};
    if(contains(linetext,'ROAD_TYPE'))
        rdf_type = extractBetween(linetext,"'","'");
    end
    line_i=line_i+1;
end

if(isempty(rdf_type))
    rdf_type = 'not found';
end

switch char(rdf_type)
    case 'not found'
        xy_data_L = [-1 -1];
        xy_data_R = [-1 -1];
        disp(['RDF type not found in ' which(filename) ]);
    case 'poly_line'
        road.x = road_raw.data(2:end-1,1);
        road.zl = road_raw.data(2:end-1,2);
        road.zr = road_raw.data(2:end-1,3);
        xy_data_L = flipud([road.x road.zl;flipud(road.x) flipud(road.zl)-poly_line_depth]);
        xy_data_R = flipud([road.x road.zr;flipud(road.x) flipud(road.zr)-poly_line_depth]);
        
    otherwise
        disp(['RDF type unknown: ' rdf_type]);
end

% Plot diagram to show parameters and extrusion
if (strcmpi(showplot,'plot'))

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
    patch(xy_data_L(:,1),xy_data_L(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(xy_data_L(:,1),xy_data_L(:,2),'-','Marker','o','MarkerSize',4,'LineWidth',2);

	patch(xy_data_R(:,1),xy_data_R(:,2),[1 1 1]*0.90,'EdgeColor','none');
    plot(xy_data_R(:,1),xy_data_R(:,2),'-','Marker','x','MarkerSize',4,'LineWidth',2);

    axis('equal');
    %axis([-1.1 1.1 -1.1 1.1]*maxd/2);
    
    title('[xy\_data\_L xy\_data\_R] = Extr\_Data\_RDF(filename, poly_line_depth);');
    hold off
    box on
    clear xy_data_L xy_data_R
end
    

