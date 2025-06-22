function maneuver_data = sm_car_maneuverdata_fishhook(varargin)
%sm_car_maneuverdata_fishhook  Generate fishhook test sequence
%   This function generates a test input sequence for fishhook test
%   (J-Turn). If no arguments are provided, test input sequences for each
%   of the vehicle classes in the Simscape Vehicle Templates will be
%   produced. Providing optional input arguments will produce a custom test
%   sequence:
%
%
%     tgtSpd    Target speed at start of maneuver (km/h)
%     tgtTime   Time to reach target speed maneuver (sec)
%     tgtDist   Distance to reach target speed (m)
%                  Either tgtTime or tgtDist will be used
%                  Unused value should be set to NaN
%                  tgtDist will be used or derived
%     qStr1     Steering wheel angle for first steering event (deg)
%     wStr1     Speed of steering wheel turn (deg/s)
%                  In a fishhook maneuver the steering wheel is sometimes
%                  turned using an electric motor and can be very fast.
%    tHold1     Length of time first steering angle is held (sec)
%    tHold2     Length of time first steering angle is held (sec)
%    tStart     Length of time before maneuver begins(sec)
%                  Should be longer than time to reach target speed
%      tOff     Length of time to ramp steering wheel back to 0 (sec)
%
%  The output structure includes the following fields:
%       Steer   Steering wheel angle versus time
%       Brake   Brake pedal input (0 for open-loop portion of test)
%       Accel   Accelerator pedal (0 for open-loop portion of test)
%       Additional fields for driver model
%
% Copyright 2018-2024 The MathWorks, Inc.

maneuver_type = 'Fishhook';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

    tgtSpd  =  [50   50  50  50  50  50];  % km/h
    tgtTime =  [8     8   8   8   8   8];  % sec
    tgtDist =  [NaN NaN NaN NaN NaN NaN];  % sec
    qStr1   =  [35   35  35  35  35  35];  % deg
    wStr1   =  [720 720 720 720 720 720];  % deg/s
    tHold1  =  [1.5 1.5 1.5 1.5 1.5 1.5];  % sec
    qStr2   = -qStr1;   % deg
    wStr2   = -wStr1;    % deg/s
    tHold2  =  [3     3   3   3   3   3];  % sec
    tStart  =  [10   10  10  10  10  10];  % sec
    tOff    =  [3     3   3   3   3   3];  % sec

else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    tgtSpd  =  varargin{1};  % km/h
    tgtTime =  varargin{2};  % sec
    tgtDist =  varargin{3};  % m
    qStr1   =  varargin{4};  % deg
    wStr1   =  varargin{5};  % deg/s
   tHold1   =  varargin{6};  % sec
    qStr2   = -qStr1;        % deg
    wStr2   = -wStr1;        % deg/s
   tHold2   =  varargin{7};  % sec
   tStart   =  varargin{8};  % sec
     tOff   =  varargin{9};  % sec
end
 
% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    mdata.(Instance).TStart.aSteer.Value = tStart(i);
    mdata.(Instance).TStart.rAccel.Value = tStart(i);
    mdata.(Instance).TStart.rBrake.Value = tStart(i);

    strSeq = [...
        0            0;
        qStr1(i)     abs(qStr1(i)/wStr1(i));
        qStr1(i)     tHold1(i);
        qStr2(i)     abs((qStr1(i)-qStr2(i))/wStr2(i));
        qStr2(i)     tHold2(i);
        0            tOff(i);
        0            2];

    timeVecSteer = [0 cumsum(strSeq(:,2)')+tStart(i)];

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

    mdata.(Instance).nPreviewPoints.Value      = 5; % m
    mdata.(Instance).nPreviewPoints.Units      = ''; % m
    mdata.(Instance).nPreviewPoints.Comments   = 'For Pure Pursuit Driver'; % m    
end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end

