function maneuver_data = sm_car_maneuverdata_ramp_steer(varargin)
%sm_car_maneuverdata_ramp_steer  Generate ramp steer test sequence
%   This function generates a test input sequence for ramp steer test.
%   If no arguments are provided, test input sequences for each
%   of the vehicle classes in the Simscape Vehicle Templates will be
%   produced. Providing optional input arguments will produce a custom test
%   sequence:
%
%     tgtSpd    Target speed at start of maneuver (km/h)
%     tgtTime   Time to reach target speed maneuver (sec)
%     tgtDist   Distance to reach target speed (m)
%                  Either tgtTime or setDist will be used
%                  Unused value should be set to NaN
%                  tgtDist will be used or derived
%     qStr      Steering wheel angle (deg)
%     tStr      Time to reach steering wheel angle (sec)
%     tStart    Length of time before maneuver begins(sec)
%                  Should be longer than time to reach target speed
%                  Used to override Driver with open loop connections
%     tOff      Length of time to ramp steering wheel back to 0 (sec)
%
%  The output structure includes the following fields:
%       Steer   Steering wheel angle versus time
%       Brake   Brake pedal input (0 for open-loop portion of test)
%       Accel   Accelerator pedal (0 for open-loop portion of test)
%       Additional fields for driver model
%
% Copyright 2018-2024 The MathWorks, Inc.

maneuver_type = 'Ramp_Steer';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

    tgtSpd   =  [50   50  50  50  50  50];  % km/h
    tgtTime  =  [8     8   8   8   8   8];  % sec
    tgtDist  =  [NaN NaN NaN NaN NaN NaN];  % sec
    qStr     =  [25   25  25  25  25  25];  % deg
    tStr     =  [0.1 0.1 0.1 0.1 0.1 0.1];  % sec
    tStart   =  [10   10  10  10  10  10];  % sec
    tOff     =  [3     3   3   3   3   3];  % sec

else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    tgtSpd   =  varargin{1};  % km/h
    tgtTime  =  varargin{2};  % sec
    tgtDist  =  varargin{3};  % m
    qStr     =  varargin{4};  % deg
    tStr     =  varargin{5};  % 1/sec
    tStart   =  varargin{6};  % sec
    tOff     =  varargin{7};  % sec
end

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).TStart.Value = tStart(i);

    % Assemble steering sequence (angle, duration)
    strSeq = [...
        0            0;
        qStr(i)     tStr(i);
        qStr(i)     tOff(i)];

    % Define time vector start : end
    timeVecSteer = [0 cumsum(strSeq(:,2)')+tStart(i)];

    % Ensure final value is an integer
    timeVecSteer(end) = round(timeVecSteer(end)+0.5);

    mdata.(Instance).Steer.t.Value         = timeVecSteer;
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = [0 strSeq(:,1)']*pi/180;
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).Accel.t.Value         = [0.00	timeVecSteer(end)];
    mdata.(Instance).Accel.t.Units         = 'sec';
    mdata.(Instance).Accel.t.Comments      = '';

    mdata.(Instance).Accel.rPedal.Value    = [0.00	 0];
    mdata.(Instance).Accel.rPedal.Units    = '0-1';
    mdata.(Instance).Accel.rPedal.Comments = '';

    mdata.(Instance).Brake.t.Value         = [0.00	timeVecSteer(end)];
    mdata.(Instance).Brake.t.Units         = 'sec';
    mdata.(Instance).Brake.t.Comments      = '';

    mdata.(Instance).Brake.rPedal.Value    = [0.00	 0];
    mdata.(Instance).Brake.rPedal.Units    = '0-1';
    mdata.(Instance).Brake.rPedal.Comments = '';

    % Obtain closed loop trajectory (ramp to target speed)
    traj = sm_car_traj_gen_straight_constant_speed(tgtSpd(i)/3.6,tgtTime(i),tgtDist(i),0,false);
    mdata.(Instance).Trajectory = traj;

    mdata.(Instance).xMaxLat.Value         = 5; % m
    mdata.(Instance).xMaxLat.Units         = 'm'; % m
    mdata.(Instance).xMaxLat.Comments      = ''; % m

    mdata.(Instance).vMinTarget.Value      = 5; % m
    mdata.(Instance).vMinTarget.Units      = 'm/s'; % m
    mdata.(Instance).vMinTarget.Comments   = ''; % m

    mdata.(Instance).vGain.Value           = 1; % m
    mdata.(Instance).vGain.Units           = ''; % m
    mdata.(Instance).vGain.Comments        = 'Scales target speed Trajectory vx'; % m

    mdata.(Instance).xPreview.x.Value      = [2.5 3 21]; % m
    mdata.(Instance).xPreview.x.Units      = 'm'; % m
    mdata.(Instance).xPreview.x.Comments   = ''; % m

    mdata.(Instance).xPreview.v.Value      = [0 5 20]; % m
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

