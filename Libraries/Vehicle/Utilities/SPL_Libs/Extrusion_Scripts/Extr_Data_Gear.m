function [xy_data] = Extr_Data_Gear(type, Dp, N, radh, varargin)
% EXTR_DATA_GEAR Produce extrusion data for a involute gear cross-section 5
% as a set of vertices. The pressure angle is assumed to be 14.5 deg.
%   [xy_data] = Extr_Data_Gear(type, Dp, N, radh, varargin)
%   This function returns x-y data for an involute gear.
%   You can specify:
%       type            - 'internal' or 'external'
%       Dp              - Pitch diameter of the gear
%       N               - Number of teeth
%       radh            - Radius of center hole for external gears
%                       - Outer ring thickness for internal gears
%       5th Input       - Addendum
%       6th Input       - Dedendum
%
%   To see a plot showing parameter values, enter the name
%   of the function with no arguments or with just the gear type
%   >> Extr_Data_Gear
%   >> Extr_Data_Gear('internal')
%
%   To see a plot created with your parameter values,
%   add 'plot' as the final argument
%   >> Extr_Data_Gear('internal',0.25, 20, 0.01, 'plot')

% Copyright 2013-2024 The MathWorks, Inc.

Ap = 14.5; % Pressure Angle
showplot = 'n';

% DEFAULT DATA TO SHOW DIAGRAM
if (nargin == 0)
    type = 'external';
    Dp = 0.25;
    N = 10;
    radh = 0.02;
end

if (nargin == 1)
    Dp = 0.25;
    N = 10;
    radh = 0.02;
    showplot = 'plot';
end

% Calculate defaults based on required parameters
Ad = Dp/N;
Dd = 1.157*Ad;

% CHECK IF PLOT REQUESTED OR Ad SPECIFIED
if nargin==5
    if ischar(varargin{1})   % PLOT REQUESTED
        showplot = varargin{1};
    else
        Ad = varargin{1};    % Ad SPECIFIED
    end
    Dd = 1.157*Ad;           % RECALCULATE Dd DEFAULT
end

% CHECK IF PLOT REQUESTED OR Dd SPECIFIED
if nargin==6
    Ad   = varargin{1};       % Ad SPECIFIED
    if ischar(varargin{2})  % PLOT REQUESTED
        showplot = varargin{2};
    else
        Dd = varargin{2};   % Dd SPECIFIED
    end
end

% CHECK IF PLOT REQUESTED
if nargin==7
    Ad   = varargin{1};       % Ad SPECIFIED
    Dd   = varargin{2};       % Dd SPECIFIED
    if ischar(varargin{3})  % PLOT REQUESTED
        showplot = varargin{3};
    end
end

Db = Dp*cos(Ap*pi/180); % Base diameter
Do = Dp + 2*Ad; % Outer diameter
Dr = Dp - 2*Dd; % Root diameter

% Tooth face profile
%lambda = linspace(0, sqrt((Do/Db)^2 - 1), 50); % Sample 50 points along curve
lambda = linspace(0, sqrt((Do/Db)^2 - 1), 50); % Sample 50 points along curve
pts = [cos(lambda); sin(lambda)];
face_profile = [[Dr/2; 0], (Db/2) * (pts + [lambda; -lambda] .* flipud(pts))];
r = sqrt(sum(face_profile .^ 2, 1));

Yp = interp1(r,face_profile(2,:),Dp/2);
sp = Yp/Dp; cp = sqrt(1-sp^2);

% Rotate and mirror face profile
R = [cp sp; -sp cp];
face_profile = R*face_profile;
Wang = pi/N;
R = [cos(Wang/2) sin(Wang/2); -sin(Wang/2) cos(Wang/2)];
face_profile = R*face_profile;

mrr_face_profile = [face_profile(1,end:-1:1); -face_profile(2,end:-1:1)];
tooth_profile = [face_profile mrr_face_profile];

% INTERNAL OR EXTERNAL
%tooth_profile(1,:) = [tooth_profile(1,:)-(Dp)-Ad];
if (strcmpi(type,'internal'))
    tooth_profile(1,:) = [tooth_profile(1,:)-(Dp)];
    tooth_profile = fliplr(tooth_profile);
end

% Replicate teeth
gear_profile = tooth_profile;
R = [cos(2*Wang) -sin(2*Wang); sin(2*Wang) cos(2*Wang)];
for idx=1:N-1
    tooth_profile = R*tooth_profile;
    gear_profile = [gear_profile tooth_profile];
end

if (strcmpi(type,'internal'))
    Outer_Ring = -1*(Dp/2+Dd+radh)*[cos(0:2*pi/100:2*pi); sin(0:2*pi/100:2*pi)]';
    xy_data = [Outer_Ring;flipud(gear_profile');gear_profile(:,end)'];
else
    xy_data = gear_profile';
end

if (strcmpi(type,'external') && radh > 0)
    th = linspace(0,-2*pi,100)';
    hole_xsec = [radh*cos(th) radh*sin(th)];
    xy_data = [xy_data; xy_data(1,:); hole_xsec];
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
    
    
    % Plot extrusion
    patch(xy_data(:,1),xy_data(:,2),[1 1 1]*0.90,'EdgeColor','none');
    hold on
    plot(xy_data(:,1),xy_data(:,2),'-','Marker','o','MarkerSize',4,'LineWidth',2);
    axis('equal');
    
    % Show parameters
    hold on
    
    teeth_pts = 0.75*Dp/2*[sin(1*Wang) cos(1*Wang);sin(3*Wang) cos(3*Wang); sin(5*Wang) cos(5*Wang)];
    plot(teeth_pts(:,1),teeth_pts(:,2),'r-d','MarkerFaceColor','r');
    text(teeth_pts(2,1)*0.75,teeth_pts(2,2)*0.75,'{\color{red}N}');
    
    plot([-Dp/2 Dp/2*sin(90*pi/180)],[0 Dp/2*cos(90*pi/180)],'k-d','MarkerFaceColor','k','MarkerSize',10,'LineWidth',2);
    text(0,0.7*Dp/4*cos(80*pi/180),'Dp');
    
    % Ad and Dd directions are opposite for internal gears
    sign=1;
    if (strcmpi(type,'internal'))
        sign = -1;
        plot([(Dp/2-Dd*sign) (Dp/2-Dd*sign)+radh]*sin(90*pi/180),[Dp/2 (Dp/2-Dd*sign)]*cos(90*pi/180),'b-d','MarkerFaceColor','b','MarkerSize',8);
        text((Dp+radh)/2-Dd*sign, Dp/2/N/2,'{\color{blue}radh}');
    else
        plot([0 -radh*sind(45)],[0 radh*cosd(45)],'b-d','MarkerFaceColor','b','MarkerSize',8);
        text(-radh, radh,'{\color{blue}radh}','HorizontalAlignment','right');
    end        
    
    plot([Dp/2 (Dp/2+Ad*sign)]*sin(90*pi/180),[Dp/2 (Dp/2+Ad*sign)]*cos(90*pi/180),'g-d','MarkerFaceColor','g','MarkerSize',8);
    text(((Dp+Ad*sign)/2), Dp/2/N/2,'{\color{green}Ad}');
    
    plot([Dp/2 (Dp/2-Dd*sign)]*sin(90*pi/180),[Dp/2 (Dp/2-Dd*sign)]*cos(90*pi/180),'r-d','MarkerFaceColor','r','MarkerSize',6);
    text((Dp-Dd*sign)/2, Dp/2/N/2,'{\color{red}Dd}');
    
    title('[xy\_data] = Extr\_Data\_Gear(type, Dp, N, (rad), (Ad), (Dd));');
    hold off
    box on
    clear xy_data
end
