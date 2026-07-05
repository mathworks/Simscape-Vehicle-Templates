function maneuver_data = sm_car_maneuverdata_parking(varargin)
%sm_car_maneuverdata_parking  Generate parking test sequence
%   This function generates a test input sequence for parking test
%   sequence. The driver turns the steering wheel to the max steering
%   angle, negative max target steering angle, and then back to 0. For each
%   phase, the driver turns the wheel at the specified target rate. Upon
%   completing the steering sequence, the brakes are applied. If no
%   arguments are provided, test input sequences for each of the vehicle
%   classes in the Simscape Vehicle Templates will be produced. Providing
%   optional input arguments will produce a custom test sequence.
%
%     tgtSpd   Target speed for maneuver (km/h)
%     qSteer   Max steering angle   (deg)
%     wSteer   Steering angle speed (deg/s)
%
%  The output structure includes the following fields:
%       Steer   Steering wheel angle versus time
%       Brake   Brake pedal input (0 for open-loop portion of test)
%       Accel   Accelerator pedal (0 for open-loop portion of test)
%       Additional fields for driver model
%
% Copyright 2018-2024 The MathWorks, Inc.

maneuver_type = 'Parking';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
Instance_List = {...
    'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};

    tgtSpd  =  [-7   -7   -7   -7   -7   -7   -7  ];  % km/h
    qSteer  =  [25   25   25   25   25   25   25  ];  % deg
    wSteer  =  [25   25   25   25   25   25   25  ];  % deg/sec

else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    tgtSpd  =  varargin{1};  % km/h
    qSteer  =  varargin{2};  % m
    wSteer  =  varargin{3};  % sec
end

maxManvTime = 200;

% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type                  = maneuver_type;
    mdata.(Instance).Instance              = Instance;

    % Steering command
    qStr   = qSteer(i);  % (deg)     Amplitude of steering angle
    wStr   = wSteer(i);  % (deg/sec) Steering angle rate
    
    % Convert to steering angle vs. time vectors
    durStr =  ... % Durations per phase
        [4
        abs((qStr-0)/wStr)
        abs((qStr- (-qStr))/wStr)
        abs((qStr-0)/wStr)
        0.5
        ];
    
    tStr    = [0; cumsum(durStr)];
    qStrVec = [0 0 qStr -qStr 0 0]*pi/180;

    mdata.(Instance).Steer.t.Value         = tStr;
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = qStrVec;
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).Brake.t.Value         = [tStr; tStr(end)+0.1; tStr(end)+1; tStr(end)+1.5; tStr(end)+2];
    mdata.(Instance).Brake.t.Units         = 'sec';
    mdata.(Instance).Brake.t.Comments      = '';

    mdata.(Instance).Brake.rPedal.Value    = [tStr*0; 1; 1; 0; 0]*0.5;
    mdata.(Instance).Brake.rPedal.Units    = '0-1';
    mdata.(Instance).Brake.rPedal.Comments = '';

    mdata.(Instance).Accel.t.Value         = [0.00	maxManvTime];
    mdata.(Instance).Accel.t.Units         = 'sec';
    mdata.(Instance).Accel.t.Comments      = '';

    mdata.(Instance).Accel.rPedal.Value    = [0.00	 0];
    mdata.(Instance).Accel.rPedal.Units    = '0-1';
    mdata.(Instance).Accel.rPedal.Comments = '';

    mdata.(Instance).TStart.aSteer.Value = 0;        % Use closed loop steering
    mdata.(Instance).TStart.rAccel.Value = tStr(end);         % Open loop acceleration at maneuver start
    mdata.(Instance).TStart.rBrake.Value = 0; % Open loop deceleration at maneuver start

    tgtSpd4traj = tgtSpd(i);
    if(tgtSpd4traj == 0)
        % Cannot ask for 0 speed; ask for speed = 1, will be fixed later)
        tgtSpd4traj = 1;
    end
    traj = sm_car_traj_gen_straight_constant_speed(tgtSpd4traj/3.6,10,NaN,0,false);

    if(tgtSpd(i)==0)
        traj.vx.Value = traj.vx.Value*0;
    else
        % Manuever starts with vehicle at target speed
        % Set target speed constant at that value
        nptsTraj = length(traj.xTrajectory.Value);
        traj.vx.Value(1:floor(nptsTraj/2)) = tgtSpd(i)/3.6;
    end
    mdata.(Instance).Trajectory = traj;

    mdata.(Instance).xMaxLat.Value         = 1000; % m
    mdata.(Instance).xMaxLat.Units         = 'm'; % m
    mdata.(Instance).xMaxLat.Comments      = ''; % m

    mdata.(Instance).vMinTarget.Value      = 0; % m
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

