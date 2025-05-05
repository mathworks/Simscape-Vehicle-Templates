function maneuver_data = sm_car_maneuverdata_slalom(varargin)
%sm_car_maneuverdata_slalom  Generate slalom test sequence
%   This function generates a test input sequence for slalom test.
%   If no arguments are provided, test input sequences for each
%   of the vehicle classes in the Simscape Vehicle Templates will be
%   produced. Providing optional input arguments will produce a custom test
%   sequence:
%
%     tgtSpd    Target speed at start of maneuver (km/h)
%     tgtTime   Time to reach target speed maneuver (sec)
%     tgtDist   Distance to reach target speed (m)
%                  Either setTime or setDist will be used
%                  Unused value should be set to NaN
%                  tgtDist will be used or derived
%     xSlalom   Distance from tgtDist to slalom start (m)
%   latOffset   Lateral offset for line of cones (m)
%    numCones   Integer number of cones (1-12)
%      xCones   Space between cones
%     yPathMx   Max path deviation from line of cones
%       qInit   1 for start left, -1 for start right
%   curveType   Path shape: 'sine','triangle'
%    showPlot   true to plot maneuver
%
%  The output structure includes the following fields:
%   Trajectory  Target path, speed, and yaw angle for driver
%        Cones  Cone locations for plotting and animation
%   Additional fields for driver model
%
% Copyright 2018-2024 The MathWorks, Inc.

maneuver_type = 'Slalom';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

    tgtSpd    =  [40   40  40  40  40  40];  % km/h
    tgtTime   =  [8     8   8   8   8   8];  % sec
    tgtDist   =  [NaN NaN NaN NaN NaN NaN];  % sec
    xSlalom   =  [10   10  10  10  10  10];  % m
    latOffset =  [0     0   0   0   0   0];  % deg/s
    numCones  =  [1     1   1   1   1   1]*8;  % integer
    xCones    =  [1     1   1   1   1   1]*18;  % m
    yPathMx   =  [2     2   2   2   2   2];  % m
    qInit     =  [1     1   1   1   1   1];  % 1 left, -1 right
    curveType =  {'sine' 'sine' 'sine' 'sine' 'sine' 'sine'};
    showPlot   = false;
else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    tgtSpd   =  varargin{1};  % km/h
    tgtTime  =  varargin{2};  % sec
    tgtDist  =  varargin{3};  % m
    xSlalom  =  varargin{4};  % m    
    latOffset = varargin{5};  % m
    numCones =  varargin{6};  % deg
    xCones   =  varargin{7};  % deg/s
    yPathMx  =  varargin{8};  % sec
    qInit    =  varargin{9};  % 1,-1
    curveType = varargin{10}; % 'sine','sawtooth'
    showPlot =  varargin{11}; % true, false
end
 
% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)

    Instance = Instance_List{i};
    mdata.(Instance).Type         = maneuver_type;
    mdata.(Instance).Instance     = Instance;

    if(iscell(curveType))
        % Set of maneuvers has cell array, extract string
        cTypeStr = curveType{i};
    else
        % Single event has a string
        cTypeStr = curveType;
    end

    % Obtain driver trajectory and cone placement parameters
    [traj, cones] = sm_car_traj_gen_slalom(tgtSpd(i)/3.6,tgtTime(i),tgtDist(i),...
        xSlalom(i),latOffset(i),numCones(i),xCones(i),yPathMx(i),qInit(i),...
        cTypeStr,showPlot);
    mdata.(Instance).Trajectory = traj;
    mdata.(Instance).Cones = cones;

    % Driver parameters
    mdata.(Instance).xMaxLat.Value         = 5; % m
    mdata.(Instance).xMaxLat.Units         = 'm'; % m
    mdata.(Instance).xMaxLat.Comments      = ''; % m

    mdata.(Instance).vMinTarget.Value      = 5; % m
    mdata.(Instance).vMinTarget.Units      = 'm/s'; % m
    mdata.(Instance).vMinTarget.Comments   = ''; % m

    mdata.(Instance).vGain.Value           = 1; % m
    mdata.(Instance).vGain.Units           = ''; % m
    mdata.(Instance).vGain.Comments        = 'Scales target speed Trajectory vx'; % m

    mdata.(Instance).xPreview.x.Value      = [2.5 3 3]; % m
    mdata.(Instance).xPreview.x.Units      = 'm'; % m
    mdata.(Instance).xPreview.x.Comments   = ''; % m

    mdata.(Instance).xPreview.v.Value      = [0 1 3]; % m
    mdata.(Instance).xPreview.v.Units      = 'm/s'; % m
    mdata.(Instance).xPreview.v.Comments   = ''; % m
    
end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end

