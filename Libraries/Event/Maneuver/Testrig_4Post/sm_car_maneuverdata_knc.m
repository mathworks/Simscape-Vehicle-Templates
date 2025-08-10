function maneuver_data = sm_car_maneuverdata_knc(varargin)
%sm_car_maneuverdata_knc  Generate kinematics and compliance test sequence
%   maneuver_data = sm_car_maneuverdata_knc(varargin)
%   This function generates a test input sequence for a kinematics and
%   compliance test (KnC). If no arguments are provided, test input
%   sequences for each of the vehicle classes in the Simscape Vehicle
%   Templates will be produced. Providing optional input arguments will
%   produce a custom test sequence:
%
%       Jounce         Height for testing toe, camber, and endstops (m)
%       Rebound        Depth for testing toe, camber, and endstops  (m)
%       zBumpHeight    Height for bump test (positive and negative) (m)
%       qSteerCaster   Steering wheel angle for caster test  (rad)
%       Roll           Height for roll test (positive and negative) (m)
%       tAlign         Aligning torque (N*m)
%       fLong          Longitudinal force at contact patch (N)
%       fLat           Lateral force at contact patch (N)
%       fLatCO         Lateral force offset from contact patch along x (N)
%       fLongWC        Longitudinal force at wheel center (N)
%       xCPOffset      Longitudinal offset from contact patch (m)
%
%  The output structure includes the following fields:
%              Steer   Steering wheel angle versus time
%  PostL1, R1, ....    Post height vs. time  for Axle 1 left, Axle 1 right, ...
%              Brake   Brake pedal input (0)
%              Accel   Accelerator pedal input (0)
%             tRange   Time range for each phase of test [start, finish]
%    zOffsetBumpTest   Height to determine bump steer, bump camber, etc.
%      qToeForCaster   Toe angle used to determine bump caster, KPI
%
% Copyright 2018-2024 The MathWorks, Inc.

maneuver_type = 'KnC';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};
    Jounce       =  [   0.14  0.22  0.10    0.15  0.22  0.22  0.05];  % m
    Rebound      =  [  -0.15 -0.15 -0.11 -0.10 -0.15 -0.15 -0.03];  % m
    zBumpHeight  =  [   0.01  0.01  0.01  0.01  0.01  0.01  0.01];  % m
    qSteerCaster =  [   0.95  0.95  0.95  0.95  0.95  0.95  0.95];  % rad
    Roll         =  [   0.10  0.10  0.10  0.10  0.10  0.10  0.07];  % m
    tAlign       =  [ 500   500   500   500   500   500   500   ]*2;  % m
    fLong        =  [1200  1200  1200  1200  1200  1200  1200   ]*2;  % m
    fLat         =  [1200  1200  1200  1200  1200  1200  1200   ]*2;  % m
    fLatCO       =  [1200  1200  1200  1200  1200  1200  1200   ]*2;  % m
    fLongWC      =  [1200  1200  1200  1200  1200  1200  1200   ]*2;  % m
    xCPOffset    =  [   1     1     1     1     1     1     1   ]*-0.3;  % m
else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    Jounce       =  varargin{1};  % m
    Rebound      =  varargin{2};  % m
    zBumpHeight  =  varargin{3};  % m
    qSteerCaster =  varargin{4};  % rad
    Roll         =  varargin{5};  % m
    tAlign       =  varargin{6};  % N*m
    fLong        =  varargin{7};  % N
    fLat         =  varargin{8};  % N

    fLatCO       =  varargin{9};  % N
    fLongWC      =  varargin{10}; % N
    xCPOffset    =  varargin{11}; % m

end

% Durations for pieces of test (sec)
durSettleInit = 5;   % Long to let bushings settle
durSettle     = 0.5; 
durJounce     = 5;  % Move posts to z upper limit
durRebound    = 5;  % Move posts to z lower limit
durzBump      = 1;  % Move to height offsets for steer test (+,-)
durqSteer     = 5;  % Steer Test
durRoll       = 5;  % Move posts in opposite direction in z 
durAlignTrq   = 5;  % Aligning torque
durLongFrc    = 5;  % Longitudinal Force, Contact Patch
durLatFrc     = 5;  % Lateral Force, Contact Patch

durLongFrcL   = 5;  % Longitudinal Contact Patch,           Left only
durLatFrcL    = 5;  % Lateral, Contact Patch,               Left only
durLatFrcO    = 5;  % Lateral, Contact Patch X Offset
durLatFrcOL   = 5;  % Lateral, Contact Patch X Offset, Left Only
durLongFrcWC  = 5;  % Longitudinal, Wheel Center
durLongFrcWCL = 5;  % Longitudinal, Wheel Center,           Left Only

% Assemble Maneuver
% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type      = maneuver_type;
    mdata.(Instance).Instance  = Instance;

    mdata.(Instance).xCPOffset = xCPOffset(i);


    % Assemble Jounce Rebound Test
    %  [duration height  steer fx fy tz fcoy fwcx]
    JR_seq = [...
        0             0          0     0  0  0  0  0;
        durSettleInit 0          0     0  0  0  0  0;
        durSettle     0          0     0  0  0  0  0;
        durJounce     Jounce(i)  0     0  0  0  0  0;
        durSettle     Jounce(i)  0     0  0  0  0  0;
        durJounce     0          0     0  0  0  0  0;
        durRebound    Rebound(i) 0     0  0  0  0  0;
        durSettle     Rebound(i) 0     0  0  0  0  0;
        durRebound    0          0     0  0  0  0  0;
        durSettle     0          0     0  0  0  0  0];

    JR_timeline = cumsum(JR_seq(:,1));

    % Assemble Bump Test
    %  [duration height  steer fx fy tz fcoy fwcx]
    BP_seq = [...
        durSettle     0                0                0  0  0  0  0;
        durqSteer     0                qSteerCaster(i)  0  0  0  0  0;
        durSettle     0                qSteerCaster(i)  0  0  0  0  0;
        2*durqSteer   0               -qSteerCaster(i)  0  0  0  0  0;
        durSettle     0               -qSteerCaster(i)  0  0  0  0  0;
        durqSteer     0                0                0  0  0  0  0;
        durSettle     0                0                0  0  0  0  0;
        durzBump      zBumpHeight(i)   0                0  0  0  0  0;
        durSettle     zBumpHeight(i)   0                0  0  0  0  0;
        durqSteer     zBumpHeight(i)   qSteerCaster(i)  0  0  0  0  0;
        durSettle     zBumpHeight(i)   qSteerCaster(i)  0  0  0  0  0;
        2*durqSteer   zBumpHeight(i)  -qSteerCaster(i)  0  0  0  0  0;
        durSettle     zBumpHeight(i)  -qSteerCaster(i)  0  0  0  0  0;
        durqSteer     zBumpHeight(i)   0                0  0  0  0  0;
        durSettle     zBumpHeight(i)   0                0  0  0  0  0;
        2*durzBump   -zBumpHeight(i)   0                0  0  0  0  0;
        durSettle    -zBumpHeight(i)   0                0  0  0  0  0;
        durqSteer    -zBumpHeight(i)   qSteerCaster(i)  0  0  0  0  0;
        durSettle    -zBumpHeight(i)   qSteerCaster(i)  0  0  0  0  0;
        2*durqSteer  -zBumpHeight(i)  -qSteerCaster(i)  0  0  0  0  0;
        durSettle    -zBumpHeight(i)  -qSteerCaster(i)  0  0  0  0  0;
        durqSteer    -zBumpHeight(i)   0                0  0  0  0  0;
        durSettle    -zBumpHeight(i)   0                0  0  0  0  0;
        durzBump      0                0                0  0  0  0  0;
        durSettle     0                0                0  0  0  0  0];

    BP_timeline = cumsum(BP_seq(:,1)) + JR_timeline(end);

    % Assemble Roll Test
    RO_seq = [...
        durSettle     0         0  0 0 0 0 0;
        durRoll       Roll(i)   0  0 0 0 0 0;
        durSettle*2   Roll(i)   0  0 0 0 0 0;
        durRoll*2    -Roll(i)   0  0 0 0 0 0;
        durSettle*2  -Roll(i)   0  0 0 0 0 0;
        durRoll       0         0  0 0 0 0 0;
        durSettle     0         0  0 0 0 0 0];

    RO_timeline = cumsum(RO_seq(:,1)) + BP_timeline(end);

    % Assemble Aligning Torque Test
    AL_seq = [...
        durSettle     0   0  0 0 0 0 0;
        durAlignTrq   0   0  0 0  tAlign(i) 0 0;
        durSettle*2   0   0  0 0  tAlign(i) 0 0;
        durAlignTrq   0   0  0 0 0 0 0;
        durSettle     0   0  0 0 0 0 0;
        durAlignTrq   0   0  0 0 -tAlign(i) 0 0;
        durSettle*2   0   0  0 0 -tAlign(i) 0 0;
        durAlignTrq   0   0  0 0 0 0 0;
        durSettle     0   0  0 0 0 0 0];

    AL_timeline = cumsum(AL_seq(:,1)) + RO_timeline(end);

    % Assemble Lateral Force Test
    LA_seq = [...
        durSettle     0   0  0      0         0 0 0;
        durLatFrc     0   0  0      -fLat(i)  0 0 0;
        durSettle*2   0   0  0      -fLat(i)  0 0 0;
        durLatFrc     0   0  0      0         0 0 0;
        durSettle     0   0  0      0         0 0 0;
        durLatFrc     0   0  0       fLat(i)  0 0 0;
        durSettle*2   0   0  0       fLat(i)  0 0 0;
        durLatFrc     0   0  0      0         0 0 0;
        durSettle     0   0  0      0         0 0 0];

    LA_timeline = cumsum(LA_seq(:,1)) + AL_timeline(end);


    % Assemble Longitudinal Force Test
    LO_seq = [...
        durSettle     0   0  0         0      0 0 0;
        durLongFrc    0   0  -fLong(i) 0      0 0 0;
        durSettle*2   0   0  -fLong(i) 0      0 0 0;
        durLongFrc    0   0  0         0      0 0 0;
        durSettle     0   0  0         0      0 0 0;
        durLongFrc    0   0   fLong(i) 0      0 0 0;
        durSettle*2   0   0   fLong(i) 0      0 0 0;
        durLongFrc    0   0  0         0      0 0 0;
        durSettle     0   0  0         0      0 0 0];

    LO_timeline = cumsum(LO_seq(:,1)) + LA_timeline(end);

    % Assemble Longitudinal Force Test, Left Only
    LOL_seq = [...
        durSettle     0   0  0         0      0 0 0;
        durLongFrcL   0   0  -fLong(i) 0      0 0 0;
        durSettle*2   0   0  -fLong(i) 0      0 0 0;
        durLongFrcL   0   0  0         0      0 0 0;
        durSettle     0   0  0         0      0 0 0;
        durLongFrcL   0   0   fLong(i) 0      0 0 0;
        durSettle*2   0   0   fLong(i) 0      0 0 0;
        durLongFrcL   0   0  0         0      0 0 0;
        durSettle     0   0  0         0      0 0 0];

    LOL_timeline = cumsum(LOL_seq(:,1)) + LO_timeline(end);

    % Assemble Lateral Force Test, Left Only
    LAL_seq = [...
        durSettle     0   0  0      0         0 0 0;
        durLatFrcL    0   0  0      -fLat(i)  0 0 0;
        durSettle*2   0   0  0      -fLat(i)  0 0 0;
        durLatFrcL    0   0  0      0         0 0 0;
        durSettle     0   0  0      0         0 0 0;
        durLatFrcL    0   0  0       fLat(i)  0 0 0;
        durSettle*2   0   0  0       fLat(i)  0 0 0;
        durLatFrcL    0   0  0      0         0 0 0;
        durSettle     0   0  0      0         0 0 0];

    LAL_timeline = cumsum(LAL_seq(:,1)) + LOL_timeline(end);
    
    % Assemble Lateral Force Contact Patch Offset Test
    %  [duration height  steer fx fy tz fcoy fwcx]

    LAO_seq = [...
        durSettle     0   0  0      0 0  0          0;
        durLatFrcO    0   0  0      0 0 -fLatCO(i)  0;
        durSettle*2   0   0  0      0 0 -fLatCO(i)  0;
        durLatFrcO    0   0  0      0 0  0          0;
        durSettle     0   0  0      0 0  0          0;
        durLatFrcO    0   0  0      0 0  fLatCO(i)  0;
        durSettle*2   0   0  0      0 0  fLatCO(i)  0;
        durLatFrcO    0   0  0      0 0  0          0;
        durSettle     0   0  0      0 0  0          0];

    LAO_timeline = cumsum(LAO_seq(:,1)) + LAL_timeline(end);

    % Assemble Lateral Force Contact Patch Offset Test, Left Only
    %  [duration height  steer fx fy tz fcoy fwcx]

    LAOL_seq = [...
        durSettle     0   0  0      0 0  0          0;
        durLatFrcOL   0   0  0      0 0 -fLatCO(i)  0;
        durSettle*2   0   0  0      0 0 -fLatCO(i)  0;
        durLatFrcOL   0   0  0      0 0  0          0;
        durSettle     0   0  0      0 0  0          0;
        durLatFrcOL   0   0  0      0 0  fLatCO(i)  0;
        durSettle*2   0   0  0      0 0  fLatCO(i)  0;
        durLatFrcOL   0   0  0      0 0  0          0;
        durSettle     0   0  0      0 0  0          0];

    LAOL_timeline = cumsum(LAOL_seq(:,1)) + LAO_timeline(end);

    % Assemble Longitudinal Force Wheel Center Test
    %  [duration height  steer fx fy tz fcoy fwcx]

    LOW_seq = [...
        durSettle     0   0  0      0 0  0           0;
        durLongFrcWC  0   0  0      0 0  0  fLongWC(i);
        durSettle*2   0   0  0      0 0  0  fLongWC(i);
        durLongFrcWC  0   0  0      0 0  0           0;
        durSettle     0   0  0      0 0  0           0];

    LOW_timeline = cumsum(LOW_seq(:,1)) + LAOL_timeline(end);

    % Assemble Longitudinal Force Wheel Center Test, Left Only
    %  [duration height  steer fx fy tz fcoy fwcx]

    LOWL_seq = [...
        durSettle     0   0  0      0 0  0           0;
        durLongFrcWCL 0   0  0      0 0  0  fLongWC(i);
        durSettle*2   0   0  0      0 0  0  fLongWC(i);
        durLongFrcWCL 0   0  0      0 0  0           0;
        durSettle     0   0  0      0 0  0           0];

    LOWL_timeline = cumsum(LOWL_seq(:,1)) + LOW_timeline(end);

    % Create Vectors
    t     = cumsum([JR_seq(:,1);BP_seq(:,1); RO_seq(:,1);     AL_seq(:,1);  LA_seq(:,1);         LO_seq(:,1);   LOL_seq(:,1);   LAL_seq(:,1); LAO_seq(:,1);   LAOL_seq(:,1); LOW_seq(:,1);   LOWL_seq(:,1)]);
    zWhlL =        [JR_seq(:,2);BP_seq(:,2); RO_seq(:,2);     AL_seq(:,2);  LA_seq(:,2);         LO_seq(:,2);   LOL_seq(:,2);   LAL_seq(:,2); LAO_seq(:,2);   LAOL_seq(:,2); LOW_seq(:,2);   LOWL_seq(:,2)];
    zWhlR =        [JR_seq(:,2);BP_seq(:,2);-RO_seq(:,2);     AL_seq(:,2);  LA_seq(:,2);         LO_seq(:,2);   LOL_seq(:,2);   LAL_seq(:,2); LAO_seq(:,2);   LAOL_seq(:,2); LOW_seq(:,2);   LOWL_seq(:,2)];
    qStr  =        [JR_seq(:,3);BP_seq(:,3); RO_seq(:,3);     AL_seq(:,3);  LA_seq(:,3);         LO_seq(:,3);   LOL_seq(:,3);   LAL_seq(:,3); LAO_seq(:,3);   LAOL_seq(:,3); LOW_seq(:,3);   LOWL_seq(:,3)];
    fxWhlL =       [JR_seq(:,4);BP_seq(:,4); RO_seq(:,4);     AL_seq(:,4);  LA_seq(:,4);         LO_seq(:,4);   LOL_seq(:,4);   LAL_seq(:,4); LAO_seq(:,4);   LAOL_seq(:,4); LOW_seq(:,4);   LOWL_seq(:,4)];
    fxWhlR =       [JR_seq(:,4);BP_seq(:,4); RO_seq(:,4);     AL_seq(:,4);  LA_seq(:,4);         LO_seq(:,4); 0*LOL_seq(:,4); 0*LAL_seq(:,4); LAO_seq(:,4); 0*LAOL_seq(:,4); LOW_seq(:,4); 0*LOWL_seq(:,4)];
    fyWhlL =       [JR_seq(:,5);BP_seq(:,5); RO_seq(:,5);     AL_seq(:,5); -(abs(LA_seq(:,5)));  LO_seq(:,5);   LOL_seq(:,5);   LAL_seq(:,5); LAO_seq(:,5);   LAOL_seq(:,5); LOW_seq(:,5);   LOWL_seq(:,5)];
    fyWhlR =       [JR_seq(:,5);BP_seq(:,5); RO_seq(:,5);     AL_seq(:,5);  LA_seq(:,5);         LO_seq(:,5); 0*LOL_seq(:,5); 0*LAL_seq(:,5); LAO_seq(:,5); 0*LAOL_seq(:,5); LOW_seq(:,5); 0*LOWL_seq(:,5)];
    tzWhlL =       [JR_seq(:,6);BP_seq(:,6); RO_seq(:,6); abs(AL_seq(:,6)); LA_seq(:,6);         LO_seq(:,6);   LOL_seq(:,6);   LAL_seq(:,6); LAO_seq(:,6);   LAOL_seq(:,6); LOW_seq(:,6);   LOWL_seq(:,6)];
    tzWhlR =       [JR_seq(:,6);BP_seq(:,6); RO_seq(:,6);     AL_seq(:,6);  LA_seq(:,6);         LO_seq(:,6); 0*LOL_seq(:,6); 0*LAL_seq(:,6); LAO_seq(:,6); 0*LAOL_seq(:,6); LOW_seq(:,6); 0*LOWL_seq(:,6)];
    fcoyWhlL =     [JR_seq(:,7);BP_seq(:,7); RO_seq(:,7);     AL_seq(:,7);  LA_seq(:,7);         LO_seq(:,7);   LOL_seq(:,7);   LAL_seq(:,7); LAO_seq(:,7);   LAOL_seq(:,7); LOW_seq(:,7);   LOWL_seq(:,7)];
    fcoyWhlR =     [JR_seq(:,7);BP_seq(:,7); RO_seq(:,7);     AL_seq(:,7);  LA_seq(:,7);         LO_seq(:,7); 0*LOL_seq(:,7); 0*LAL_seq(:,7); LAO_seq(:,7); 0*LAOL_seq(:,7); LOW_seq(:,7); 0*LOWL_seq(:,7)];
    fwcxWhlL =     [JR_seq(:,8);BP_seq(:,8); RO_seq(:,8);     AL_seq(:,8);  LA_seq(:,8);         LO_seq(:,8);   LOL_seq(:,8);   LAL_seq(:,8); LAO_seq(:,8);   LAOL_seq(:,8); LOW_seq(:,8);   LOWL_seq(:,8)];
    fwcxWhlR =     [JR_seq(:,8);BP_seq(:,8); RO_seq(:,8);     AL_seq(:,8);  LA_seq(:,8);         LO_seq(:,8); 0*LOL_seq(:,8); 0*LAL_seq(:,8); LAO_seq(:,8); 0*LAOL_seq(:,8); LOW_seq(:,8); 0*LOWL_seq(:,8)];

    % Assemble structure
    mdata.(Instance).Steer.t.Value         = t;
    mdata.(Instance).Steer.t.Units         = 'sec';
    mdata.(Instance).Steer.t.Comments      = '';

    mdata.(Instance).Steer.aWheel.Value    = qStr;
    mdata.(Instance).Steer.aWheel.Units    = 'rad';
    mdata.(Instance).Steer.aWheel.Comments = '';

    mdata.(Instance).PostL1.t.Value         = t;
    mdata.(Instance).PostL1.t.Units         = 'sec';
    mdata.(Instance).PostL1.t.Comments      = '';
    mdata.(Instance).PostR1.t.Value         = t;
    mdata.(Instance).PostR1.t.Units         = 'sec';
    mdata.(Instance).PostR1.t.Comments      = '';

    mdata.(Instance).PostL1.z.Value         = zWhlL;
    mdata.(Instance).PostL1.z.Units         = 'm';
    mdata.(Instance).PostL1.z.Comments      = '';
    mdata.(Instance).PostR1.z.Value         = zWhlR;
    mdata.(Instance).PostR1.z.Units         = 'm';
    mdata.(Instance).PostR1.z.Comments      = '';

    mdata.(Instance).PostL1.fx.Value         = fxWhlL;
    mdata.(Instance).PostL1.fx.Units         = 'N';
    mdata.(Instance).PostL1.fx.Comments      = '';
    mdata.(Instance).PostR1.fx.Value         = fxWhlR;
    mdata.(Instance).PostR1.fx.Units         = 'N';
    mdata.(Instance).PostR1.fx.Comments      = '';

    mdata.(Instance).PostL1.fy.Value         = fyWhlL;
    mdata.(Instance).PostL1.fy.Units         = 'N';
    mdata.(Instance).PostL1.fy.Comments      = '';
    mdata.(Instance).PostR1.fy.Value         = fyWhlR;
    mdata.(Instance).PostR1.fy.Units         = 'N';
    mdata.(Instance).PostR1.fy.Comments      = '';

    mdata.(Instance).PostL1.tz.Value         = tzWhlL;
    mdata.(Instance).PostL1.tz.Units         = 'N*m';
    mdata.(Instance).PostL1.tz.Comments      = '';
    mdata.(Instance).PostR1.tz.Value         = tzWhlR;
    mdata.(Instance).PostR1.tz.Units         = 'N*m';
    mdata.(Instance).PostR1.tz.Comments      = '';

    mdata.(Instance).PostL1.fcoy.Value         = fcoyWhlL;
    mdata.(Instance).PostL1.fcoy.Units         = 'N*m';
    mdata.(Instance).PostL1.fcoy.Comments      = '';
    mdata.(Instance).PostR1.fcoy.Value         = fcoyWhlR;
    mdata.(Instance).PostR1.fcoy.Units         = 'N*m';
    mdata.(Instance).PostR1.fcoy.Comments      = '';

    mdata.(Instance).PostL1.fwcx.Value         = fwcxWhlL;
    mdata.(Instance).PostL1.fwcx.Units         = 'N*m';
    mdata.(Instance).PostL1.fwcx.Comments      = '';
    mdata.(Instance).PostR1.fwcx.Value         = fwcxWhlR;
    mdata.(Instance).PostR1.fwcx.Units         = 'N*m';
    mdata.(Instance).PostR1.fwcx.Comments      = '';

    mdata.(Instance).PostL2 = mdata.(Instance).PostL1;
    mdata.(Instance).PostR2 = mdata.(Instance).PostR1;
    mdata.(Instance).PostL3 = mdata.(Instance).PostL1;
    mdata.(Instance).PostR3 = mdata.(Instance).PostR1;

    mdata.(Instance).Brake.t.Value          = [0.00	max(t)];
    mdata.(Instance).Brake.t.Units          = 'sec';
    mdata.(Instance).Brake.t.Comments       = '';

    mdata.(Instance).Brake.rPedal.Value     = [0.00	0.00];
    mdata.(Instance).Brake.rPedal.Units     = '0-1';
    mdata.(Instance).Brake.rPedal.Comments  = '';

    mdata.(Instance).Accel.t.Value          = [0.00	max(t)];
    mdata.(Instance).Accel.t.Units          = 'sec';
    mdata.(Instance).Accel.t.Comments       = '';

    mdata.(Instance).Accel.rPedal.Value     = [0.00	0.00];
    mdata.(Instance).Accel.rPedal.Units     = '0-1';
    mdata.(Instance).Accel.rPedal.Comments  = '';

    mdata.(Instance).tRange.Jounce          = [JR_timeline(2) JR_timeline(6)];
    mdata.(Instance).tRange.Rebound         = [JR_timeline(6) JR_timeline(end)];
    mdata.(Instance).tRange.Bumpz0          = [BP_timeline(1) BP_timeline(7)];
    mdata.(Instance).tRange.Bumpzp          = [BP_timeline(9) BP_timeline(15)];
    mdata.(Instance).tRange.Bumpzn          = [BP_timeline(17) BP_timeline(23)];
    mdata.(Instance).tRange.Rollp           = [RO_timeline(3) RO_timeline(4)];
    mdata.(Instance).tRange.Rolln           = [RO_timeline(5) RO_timeline(6)];
    mdata.(Instance).tRange.AlignTrqIn      = [AL_timeline(2) AL_timeline(3)];
    mdata.(Instance).tRange.AlignTrqOut     = [AL_timeline(6) AL_timeline(7)];
    mdata.(Instance).tRange.LatFrcIn        = [LA_timeline(2) LA_timeline(3)];
    mdata.(Instance).tRange.LatFrcOut       = [LA_timeline(6) LA_timeline(7)];
    mdata.(Instance).tRange.LongFrcBrk      = [LO_timeline(2) LO_timeline(3)];
    mdata.(Instance).tRange.LongFrcAcc      = [LO_timeline(6) LO_timeline(7)];
    mdata.(Instance).tRange.LongFrcLBrk     = [LOL_timeline(2) LOL_timeline(3)];
    mdata.(Instance).tRange.LongFrcLAcc     = [LOL_timeline(6) LOL_timeline(7)];
    mdata.(Instance).tRange.LatFrcLIn       = [LAL_timeline(2) LAL_timeline(3)];
    mdata.(Instance).tRange.LatFrcLOut      = [LAL_timeline(6) LAL_timeline(7)];
    mdata.(Instance).tRange.LatFrcOBrk      = [LAO_timeline(2) LAO_timeline(3)];
    mdata.(Instance).tRange.LatFrcOAcc      = [LAO_timeline(6) LAO_timeline(7)];
    mdata.(Instance).tRange.LatFrcOLBr      = [LAOL_timeline(2) LAOL_timeline(3)];
    mdata.(Instance).tRange.LatFrcOLAc      = [LAOL_timeline(6) LAOL_timeline(7)];
    mdata.(Instance).tRange.LongFrcWCBrk    = [LOW_timeline(2)  LOW_timeline(3)];
    mdata.(Instance).tRange.LongFrcWCLBrk   = [LOWL_timeline(2) LOWL_timeline(3)];

    mdata.(Instance).zOffsetBumpTest.Value     = zBumpHeight(i);
    mdata.(Instance).zOffsetBumpTest.Units     = 'm';
    mdata.(Instance).zOffsetBumpTest.Comments  = 'Height (+/-) to check bump steer, camber, caster';

    mdata.(Instance).qToeForCaster.Value     = 1;
    mdata.(Instance).qToeForCaster.Units     = 'deg';
    mdata.(Instance).qToeForCaster.Comments  = 'Toe angle (+/-) to check caster';
end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end
