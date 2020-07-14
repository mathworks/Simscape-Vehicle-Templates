function [xy_data] = Extr_Data_Mesh(lenX, lenY, numHx, numHy, hx, hy, varargin)
%Extr_Data_Mesh Produce extrusion data for a square mesh.
%   [xy_data] = Extr_Data_Mesh(lenX, lenY, numHx, numHy, hx, hy)
%   This function returns x-y data for a square mesh.  
%   You can specify:
%       Mesh outer width               lenX
%       Mesh outer length              lenY
%       Number of mesh holes along X   numHx
%       Number of mesh holes along Y   numHy
%       Width of mesh holes (along x)  hx
%       Length of mesh holes (along y) hy
%
%   To see a plot showing parameter values, enter the name
%   of the function with no arguments
%   >> Extr_Data_Mesh
%
%   To see a plot created with your parameter values, 
%   add 'plot' as the final argument
%   >> Extr_Data_Mesh(3,3,3,2,0.8,0.8,'plot')

% Copyright 2017-2020 The MathWorks, Inc.

% Default data to show diagram
if (nargin == 0)
    lenX = 3;
    lenY = 3;
    numHx = 3;
    numHy = 2;
    hx = 0.8;
    hy = 0.8;
end

self_intersect_offset = 1e-4;

if (nargin==0 ||nargin==7)
    showplot = 'plot';
else
    showplot = 'n';
end

% Calculate extrusion data

tx = (lenX-(numHx*hx))/(numHx+1);
ty = (lenY-(numHy*hy))/(numHy+1);

xy_data = [...
    0     0;
    lenX  0;
    lenX  ty-self_intersect_offset;
    tx    ty-self_intersect_offset];

for j=1:numHy
    for i=1:numHx
        append_pts = [
            tx*(i)+hx*(i-1) ty+(ty+hy)*(j-1);
            tx*(i)+hx*(i-1) ty+hy+(ty+hy)*(j-1);
            tx*(i)+hx*i     ty+hy+(ty+hy)*(j-1);
            tx*(i)+hx*i     ty+(ty+hy)*(j-1);
            ];
        xy_data = [xy_data;append_pts];
    end
    if(i==numHx)
        xy_data = [xy_data;
            lenX hy*(j-1)+ty*j;
            lenX hy*j+ty*(j+1)-self_intersect_offset;
            tx   hy*j+ty*(j+1)-self_intersect_offset];
    end
    if(j==numHy)
        xy_data=[xy_data;0 lenY-self_intersect_offset];
    end
end

xy_data = xy_data-[lenX/2 lenY/2];

% Plot diagram to show parameters and extrusion

if (nargin == 0 || strcmpi(showplot,'plot'))
    
    % Get max axis dimension
    maxd = max(lenX,lenY);
    
    % Plot extrusion
    plot(xy_data(:,1),xy_data(:,2),'b-o','LineWidth',1.5);
    axis('square');
    axis([-0.55 0.55 -0.55 0.55]*maxd);
    
    % Show parameters

    hold on
        
    plot([-0.5 0.5]*lenX,-[1 1]*(lenY-ty)/2,'r-d','MarkerFaceColor','r');
    text(0,-(lenY-ty)/2,'{\color{red}lenX}');

    plot(-[1 1]*(lenX-tx)/2,[-0.5 0.5]*lenY,'c-d','MarkerFaceColor','c');
    text(-(lenX-tx)/2,0,'{\color{cyan}lenY}');

    plot([tx tx+hx]-lenX/2,[1 1]*(ty+hy/2)-lenY/2,'g-d','MarkerFaceColor','g');
    text((tx+hx/2)-lenX/2,(ty+hy/2)-lenY/2,'{\color{green}hx}');

    plot([-1 -1]*(tx+hx/2)+lenX/2,-[ty ty+hy]+lenY/2,'m-d','MarkerFaceColor','m');
    text(-(tx+hx/2)+lenX/2,-(ty+hy/2)+lenY/2,'{\color{magenta}hy}');

    plot([tx+hx/2 2*tx+3*hx/2]-lenX/2,-[1 1]*(ty+hy/2)+lenY/2,'k:d','MarkerFaceColor','w');
    text(-lenX/2+(tx+hx/2),lenY/2-(ty+hy/4),'{\color{black}numHx}','HorizontalAlignment','center');

	title(['[xy\_data] = Extr\_Data\_Mesh(lenX, lenY, numHx, numHy, hx, hy);']);
    hold off
    clear xy_data
    
end
