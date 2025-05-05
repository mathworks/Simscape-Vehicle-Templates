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
%       fLong          Longitudinal force (N)
%       fLat           Lateral force (N)
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
        'Sedan_Hamba','Sedan_HambaLG','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};
    Jounce       =  [   0.14  0.22  0.15  0.22  0.22  0.05];  % m
    Rebound      =  [  -0.15 -0.15 -0.10 -0.15 -0.15 -0.03];  % m
    zBumpHeight  =  [   0.01  0.01  0.01  0.01  0.01  0.01];  % m
    qSteerCaster =  [   0.95  0.95  0.95  0.95  0.95  0.95];  % rad
    Roll         =  [   0.10  0.10  0.10  0.10  0.10  0.07];  % m
    tAlign       =  [ 500   500   500   500   500   500   ]*2;  % m
    fLong        =  [1200  1200  1200  1200  1200  1200   ]*2;  % m
    fLat         =  [1200  1200  1200  1200  1200  1200   ]*2;  % m
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
end

% Durations for pieces of test (sec)
durSettleInit = 5;   % Long to let bushings settle)
durSettle     = 0.5; 
durJounce     = 5;
durRebound    = 5;
durzBump      = 1;
durqSteer     = 5;
durRoll       = 5;
durAlignTrq   = 5;
durLongFrc    = 5;
durLatFrc     = 5;

% Assemble Maneuver
% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type     = maneuver_type;
    mdata.(Instance).Instance = Instance;

    % Assemble Jounce Rebound Test
    JR_seq = [...
        0             0          0     0  0  0;
        durSettleInit 0          0     0  0  0;
        durSettle     0          0     0  0  0;
        durJounce     Jounce(i)  0     0  0  0;
        durSettle     Jounce(i)  0     0  0  0;
        durJounce     0          0     0  0  0;
        durRebound    Rebound(i) 0     0  0  0;
        durSettle     Rebound(i) 0     0  0  0;
        durRebound    0          0     0  0  0;
        durSettle     0          0     0  0  0];

    JR_timeline = cumsum(JR_seq(:,1));

    % Assemble Bump Test
    BP_seq = [...
        durSettle     0                0                0  0  0;
        durqSteer     0                qSteerCaster(i)  0  0  0;
        durSettle     0                qSteerCaster(i)  0  0  0;
        2*durqSteer   0               -qSteerCaster(i)  0  0  0;
        durSettle     0               -qSteerCaster(i)  0  0  0;
        durqSteer     0                0                0  0  0;
        durSettle     0                0                0  0  0;
        durzBump      zBumpHeight(i)   0                0  0  0;
        durSettle     zBumpHeight(i)   0                0  0  0;
        durqSteer     zBumpHeight(i)   qSteerCaster(i)  0  0  0;
        durSettle     zBumpHeight(i)   qSteerCaster(i)  0  0  0;
        2*durqSteer   zBumpHeight(i)  -qSteerCaster(i)  0  0  0;
        durSettle     zBumpHeight(i)  -qSteerCaster(i)  0  0  0;
        durqSteer     zBumpHeight(i)   0                0  0  0;
        durSettle     zBumpHeight(i)   0                0  0  0;
        2*durzBump   -zBumpHeight(i)   0                0  0  0;
        durSettle    -zBumpHeight(i)   0                0  0  0;
        durqSteer    -zBumpHeight(i)   qSteerCaster(i)  0  0  0;
        durSettle    -zBumpHeight(i)   qSteerCaster(i)  0  0  0;
        2*durqSteer  -zBumpHeight(i)  -qSteerCaster(i)  0  0  0;
        durSettle    -zBumpHeight(i)  -qSteerCaster(i)  0  0  0;
        durqSteer    -zBumpHeight(i)   0                0  0  0;
        durSettle    -zBumpHeight(i)   0                0  0  0;
        durzBump      0                0                0  0  0;
        durSettle     0                0                0  0  0];

    BP_timeline = cumsum(BP_seq(:,1)) + JR_timeline(end);

    % Assemble Roll Test
    RO_seq = [...
        durSettle     0         0  0 0 0;
        durRoll       Roll(i)   0  0 0 0;
        durSettle*2   Roll(i)   0  0 0 0;
        durRoll*2    -Roll(i)   0  0 0 0;
        durSettle*2  -Roll(i)   0  0 0 0;
        durRoll       0         0  0 0 0;
        durSettle     0         0  0 0 0];

    RO_timeline = cumsum(RO_seq(:,1)) + BP_timeline(end);

    % Assemble Aligning Torque Test
    AL_seq = [...
        durSettle     0   0  0 0 0;
        durAlignTrq   0   0  0 0  tAlign(i);
        durSettle*2   0   0  0 0  tAlign(i);
        durAlignTrq   0   0  0 0 0;
        durSettle     0   0  0 0 0;
        durAlignTrq   0   0  0 0 -tAlign(i);
        durSettle*2   0   0  0 0 -tAlign(i);
        durAlignTrq   0   0  0 0 0;
        durSettle     0   0  0 0 0];

    AL_timeline = cumsum(AL_seq(:,1)) + RO_timeline(end);

    % Assemble Longitudinal Force Test
    LA_seq = [...
        durSettle     0   0  0      0         0;
        durLatFrc     0   0  0      -fLat(i)  0;
        durSettle*2   0   0  0      -fLat(i)  0;
        durLatFrc     0   0  0      0         0;
        durSettle     0   0  0      0         0;
        durLatFrc     0   0  0       fLat(i)  0;
        durSettle*2   0   0  0       fLat(i)  0;
        durLatFrc     0   0  0      0         0;
        durSettle     0   0  0      0         0];

    LA_timeline = cumsum(LA_seq(:,1)) + AL_timeline(end);


    % Assemble Longitudinal Force Test
    LO_seq = [...
        durSettle     0   0  0         0      0;
        durLongFrc    0   0  -fLong(i) 0      0;
        durSettle*2   0   0  -fLong(i) 0      0;
        durLongFrc    0   0  0         0      0;
        durSettle     0   0  0         0      0;
        durLongFrc    0   0   fLong(i) 0      0;
        durSettle*2   0   0   fLong(i) 0      0;
        durLongFrc    0   0  0         0      0;
        durSettle     0   0  0         0      0];

    LO_timeline = cumsum(LO_seq(:,1)) + LA_timeline(end);

    % Create Vectors
    t     = cumsum([JR_seq(:,1);BP_seq(:,1); RO_seq(:,1);     AL_seq(:,1);  LA_seq(:,1);  LO_seq(:,1)]);
    zWhlL =        [JR_seq(:,2);BP_seq(:,2); RO_seq(:,2);     AL_seq(:,2);  LA_seq(:,2);  LO_seq(:,2)];
    zWhlR =        [JR_seq(:,2);BP_seq(:,2);-RO_seq(:,2);     AL_seq(:,2);  LA_seq(:,2);  LO_seq(:,2)];
    qStr  =        [JR_seq(:,3);BP_seq(:,3); RO_seq(:,3);     AL_seq(:,3);  LA_seq(:,3);  LO_seq(:,3)];
    fxWhlL =       [JR_seq(:,4);BP_seq(:,4); RO_seq(:,4);     AL_seq(:,4);  LA_seq(:,4);  LO_seq(:,4)];
    fxWhlR =       [JR_seq(:,4);BP_seq(:,4); RO_seq(:,4);     AL_seq(:,4);  LA_seq(:,4);  LO_seq(:,4)];
    fyWhlL =       [JR_seq(:,5);BP_seq(:,5); RO_seq(:,5);     AL_seq(:,5); -(abs(LA_seq(:,5)));  LO_seq(:,5)];
    fyWhlR =       [JR_seq(:,5);BP_seq(:,5); RO_seq(:,5);     AL_seq(:,5);  LA_seq(:,5);  LO_seq(:,5)];
    tzWhlL =       [JR_seq(:,6);BP_seq(:,6); RO_seq(:,6); abs(AL_seq(:,6)); LA_seq(:,6);  LO_seq(:,6)];
    tzWhlR =       [JR_seq(:,6);BP_seq(:,6); RO_seq(:,6);     AL_seq(:,6);  LA_seq(:,6);  LO_seq(:,6)];

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
