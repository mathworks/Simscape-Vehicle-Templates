function maneuver_data = sm_car_maneuverdata_testrig4Post_cycle1(varargin)
%sm_car_maneuverdata_testrig4Post_cycle1  Generate 4 post testrig test sequence
%   maneuver_data = sm_car_maneuverdata_testrig4Post_cycle1(varargin)
%   This function generates a test input sequence for the four post
%   testrig. If no arguments are provided, test input sequences for each of
%   the vehicle classes in the Simscape Vehicle Templates will be produced.
%   Providing optional input arguments will produce a test sequence with
%   custom settings for each phase.
%
%   The test phases are pitch, heave, roll, bump.
%
%       pitchPeriod   Sinusoidal pitch test period (sec)
%       pitchNcycles  Pitch test number of cycles (1)
%       pitchAmp      Pitch test amplitude (m)
%       pitchRdelayFR Pitch test delay for rear axle, fraction of test period (0-1)
%       heavePeriod   Sinusoidal heave test period (sec) (m)
%       heaveNcycles  Heave test number of cycles (1)
%       heaveAmp      Heave test amplitude (m))
%       rollPeriod    Sinusoidal roll test period (sec)
%       rollNcycles   Roll test number of cycles (1)
%       rollAmp       Roll test amplitude (m)
%       bumpTrise     Bump test rise and fall time (sec)
%       bumpDur       Bump test duration (sec)
%       bumpAmp       Bump test amplitude (m)
%       bumpTdelayFR  Bump test delay for rear axle (sec)
%
%  The output structure includes the parameters needed for Simulink blocks
%  to calculate the post height with respect to time. The acceleration,
%  brake, and steer inputs are set to zero.
%
%  For a custom pitch, heave, roll, and bump test cycle, pass arguments to
%  this function. Be sure to configure the model with the "Testrig 4 Post Cycle 1" maneuver.
%  sm_car_config_maneuver('sm_car','Testrig 4 Post Cycle 1')
%  Maneuver = sm_car_maneuverdata_testrig4Post_cycle1(2,2,0.05,0.25,2,2,0.05,1,3,0.03,0.1,2,0.05,0.5);
%
% Copyright 2018-2025 The MathWorks, Inc.

maneuver_type = 'Testrig4Post_Cycle1';

% Input Params
if(nargin == 0)
    % Generate test sequences for all vehicle classes in Simscape Vehicle Templates
    Instance_List = {...
        'Sedan_Hamba','Sedan_HambaLG','SUV_Landy','Bus_Makhulu','Truck_Amandla','Truck_Rhuqa','FSAE_Achilles'};
    pitchPeriod   =  [2     2     2     2     2     2     2];     % sec
    pitchNcycles  =  [2     2     2     2     2     2     2];     % 1
    pitchAmp      =  [0.05  0.05  0.05  0.05  0.05  0.05  0.05];  % m
    pitchRdelayFR =  [0.25  0.25  0.25  0.25  0.25  0.25  0.25];  % (0-1)
    heavePeriod   =  [2     2     2     2     2     2     2];     % sec
    heaveNcycles  =  [2     2     2     2     2     2     2];     % 1
    heaveAmp      =  [0.05  0.05  0.05  0.05  0.05  0.05  0.05];  % m
    rollPeriod    =  [1     1     1     1     1     1     1];     % sec
    rollNcycles   =  [3     3     3     3     3     3     3];     % 1
    rollAmp       =  [0.03  0.03  0.03  0.03  0.03  0.03  0.03];  % m
    bumpTrise     =  [0.1   0.1   0.1   0.1   0.1   0.1   0.1];   % sec
    bumpDur       =  [2     2     2     2     2     2     2];     % sec
    bumpAmp       =  [0.05  0.05  0.05  0.05  0.05  0.05  0.05];  % m
    bumpTdelayFR  =  [0.5   0.5   0.5   0.5   0.5   0.5   0.5];   % sec
else
    % Generate custom test sequences
    Instance_List = {'Custom'};
    pitchPeriod   =  varargin{1};  % sec
    pitchNcycles  =  varargin{2};  % 1
    pitchAmp      =  varargin{3};  % m
    pitchRdelayFR =  varargin{4};  % (0-1)
    heavePeriod   =  varargin{5};  % sec
    heaveNcycles  =  varargin{6};  % 1
    heaveAmp      =  varargin{7};  % m
    rollPeriod    =  varargin{8};  % sec
    rollNcycles   =  varargin{9};  % 1
    rollAmp       =  varargin{10}; % m
    bumpTrise     =  varargin{11}; % sec
    bumpDur       =  varargin{12}; % 1
    bumpAmp       =  varargin{13}; % m
    bumpTdelayFR  =  varargin{14}; % sec
end

% Durations for pieces of test (sec)
durSettleInit = 2;   % Pause at start to let bushings settle
durSettle     = 1;   % Pause between events

% Get input sequence for no accel, brake, or steer
ManNone = sm_car_maneuverdata_none;

% Assemble Maneuver
% Assign same values as defaults for all maneuvers
for i=1:length(Instance_List)
    Instance = Instance_List{i};
    mdata.(Instance).Type      = maneuver_type;
    mdata.(Instance).Instance  = Instance;

    % -- Pitch Test --
    mdata.(Instance).Pitch.L1.tPeriod.Value   = pitchPeriod(i);
    mdata.(Instance).Pitch.L1.tPeriod.Comment = '';
    mdata.(Instance).Pitch.L1.tPeriod.Units   = 'sec';

    mdata.(Instance).Pitch.L1.nCycles.Value   = ceil(pitchNcycles(i)); % Integer
    mdata.(Instance).Pitch.L1.nCycles.Comment = '';
    mdata.(Instance).Pitch.L1.nCycles.Units   = '1';

    mdata.(Instance).Pitch.L1.xAmplitude.Value   = pitchAmp(i);  % m
    mdata.(Instance).Pitch.L1.xAmplitude.Comment = '';
    mdata.(Instance).Pitch.L1.xAmplitude.Units   = 'm';

    mdata.(Instance).Pitch.L1.tStart.Value   = durSettleInit; % m
    mdata.(Instance).Pitch.L1.tStart.Comment = '';
    mdata.(Instance).Pitch.L1.tStart.Units   = 'sec';

    % Front Right same as Front Left
    mdata.(Instance).Pitch.R1 = mdata.(Instance).Pitch.L1; % m

    % Rear delayed by percentage of period
    mdata.(Instance).Pitch.L2 = mdata.(Instance).Pitch.L1; % m
    mdata.(Instance).Pitch.L2.tStart.Value = mdata.(Instance).Pitch.L1.tStart.Value + ...
        pitchRdelayFR(i)*mdata.(Instance).Pitch.L1.tPeriod.Value;

    % Rear Right same as Rear Left
    mdata.(Instance).Pitch.R2 = mdata.(Instance).Pitch.L2; % m

    % In case of 3 axle vehicle, set 3rd axle same as 2nd
    mdata.(Instance).Pitch.L3 = mdata.(Instance).Pitch.L2;
    mdata.(Instance).Pitch.R3 = mdata.(Instance).Pitch.R2;
    
    mdata.(Instance).tRange.Pitch = [0 ...
        mdata.(Instance).Pitch.L1.tStart.Value+...
        mdata.(Instance).Pitch.L1.tPeriod.Value*mdata.(Instance).Pitch.L1.nCycles.Value+...
        pitchRdelayFR(i)];

    % -- Heave Test -- 
    mdata.(Instance).Heave.L1.tPeriod.Value   = heavePeriod(i);
    mdata.(Instance).Heave.L1.tPeriod.Comment = '';
    mdata.(Instance).Heave.L1.tPeriod.Units   = 'sec';

    mdata.(Instance).Heave.L1.nCycles.Value   = ceil(heaveNcycles(i)); % Integer
    mdata.(Instance).Heave.L1.nCycles.Comment = '';
    mdata.(Instance).Heave.L1.nCycles.Units   = '1';

    mdata.(Instance).Heave.L1.xAmplitude.Value   = heaveAmp(i);  % m
    mdata.(Instance).Heave.L1.xAmplitude.Comment = '';
    mdata.(Instance).Heave.L1.xAmplitude.Units   = 'm';

    mdata.(Instance).Heave.L1.tStart.Value   = ...
        mdata.(Instance).tRange.Pitch(2)+durSettle; % m
    mdata.(Instance).Heave.L1.tStart.Comment = '';
    mdata.(Instance).Heave.L1.tStart.Units   = 'sec';
    
    % All posts same
    mdata.(Instance).Heave.R1 = mdata.(Instance).Heave.L1; % m
    mdata.(Instance).Heave.L2 = mdata.(Instance).Heave.L1; % m
    mdata.(Instance).Heave.R2 = mdata.(Instance).Heave.L1; % m

    % In case of 3 axle vehicle, set 3rd axle same as 2nd
    mdata.(Instance).Heave.L3 = mdata.(Instance).Heave.L2;
    mdata.(Instance).Heave.R3 = mdata.(Instance).Heave.R2;
    
    mdata.(Instance).tRange.Heave = [0 ...
        mdata.(Instance).Heave.L1.tStart.Value+...
        mdata.(Instance).Heave.L1.tPeriod.Value*mdata.(Instance).Heave.L1.nCycles.Value];

    % -- Roll Test -- 
    mdata.(Instance).Roll.L1.tPeriod.Value   = rollPeriod(i);
    mdata.(Instance).Roll.L1.tPeriod.Comment = '';
    mdata.(Instance).Roll.L1.tPeriod.Units   = 'sec';

    mdata.(Instance).Roll.L1.nCycles.Value   = ceil(rollNcycles(i)); % Integer
    mdata.(Instance).Roll.L1.nCycles.Comment = '';
    mdata.(Instance).Roll.L1.nCycles.Units   = '1';

    mdata.(Instance).Roll.L1.xAmplitude.Value   = rollAmp(i);  % m
    mdata.(Instance).Roll.L1.xAmplitude.Comment = '';
    mdata.(Instance).Roll.L1.xAmplitude.Units   = 'm';

    mdata.(Instance).Roll.L1.tStart.Value   = ...
        mdata.(Instance).tRange.Heave(2)+durSettle; % m
    mdata.(Instance).Roll.L1.tStart.Comment = '';
    mdata.(Instance).Roll.L1.tStart.Units   = 'sec';

    % Rear Left same as Front Left
    mdata.(Instance).Roll.L2 = mdata.(Instance).Roll.L1; % m

    % Right delayed by 0.5*period
    mdata.(Instance).Roll.R1 = mdata.(Instance).Roll.L1; % m
    mdata.(Instance).Roll.R1.tStart.Value = mdata.(Instance).Roll.L1.tStart.Value + ...
        0.5*mdata.(Instance).Roll.L1.tPeriod.Value;

    % Rear Right same as Front Right
    mdata.(Instance).Roll.R2 = mdata.(Instance).Roll.R1; % m

    % In case of 3 axle vehicle, set 3rd axle same as 2nd
    mdata.(Instance).Roll.L3 = mdata.(Instance).Roll.L2;
    mdata.(Instance).Roll.R3 = mdata.(Instance).Roll.R2;
    
    mdata.(Instance).tRange.Roll = [0 ...
        mdata.(Instance).Roll.L1.tStart.Value+...
        mdata.(Instance).Roll.L1.tPeriod.Value*(mdata.(Instance).Roll.L1.nCycles.Value+0.5)];

    % -- Bump Test --
    mdata.(Instance).Bump.L1.tDuration.Value   = bumpDur(i);
    mdata.(Instance).Bump.L1.tDuration.Comment = '';
    mdata.(Instance).Bump.L1.tDuration.Units   = 'sec';

    mdata.(Instance).Bump.L1.xAmplitude.Value   = bumpAmp(i);  % m
    mdata.(Instance).Bump.L1.xAmplitude.Comment = '';
    mdata.(Instance).Bump.L1.xAmplitude.Units   = 'm';

    mdata.(Instance).Bump.L1.tRise.Value   = bumpTrise(i);
    mdata.(Instance).Bump.L1.tRise.Comment = '';
    mdata.(Instance).Bump.L1.tRise.Units   = 'sec';

    mdata.(Instance).Bump.L1.tStart.Value   =  ...
        mdata.(Instance).tRange.Roll(2)+durSettle; % m

    mdata.(Instance).Bump.L1.tStart.Comment = '';
    mdata.(Instance).Bump.L1.tStart.Units   = 'sec';

    % Front Right same as Front Left
    mdata.(Instance).Bump.R1 = mdata.(Instance).Bump.L1; % m

    % Rear delayed by percentage of period
    mdata.(Instance).Bump.L2 = mdata.(Instance).Bump.L1; % m
    mdata.(Instance).Bump.L2.tStart.Value = ...
        mdata.(Instance).Bump.L1.tStart.Value + bumpTdelayFR(i);

    % Rear Right same as Rear Left
    mdata.(Instance).Bump.R2 = mdata.(Instance).Bump.L2; % m

    % In case of 3 axle vehicle, set 3rd axle same as 2nd
    mdata.(Instance).Bump.L3 = mdata.(Instance).Bump.L2;
    mdata.(Instance).Bump.R3 = mdata.(Instance).Bump.R2;
    
    mdata.(Instance).tRange.Bump = [0 ...
        mdata.(Instance).Bump.L1.tStart.Value+...
        mdata.(Instance).Bump.L1.tDuration.Value+...
        bumpTdelayFR(i)+durSettle];

    % Add zero inputs for accel, brake, and steer
    mdata.(Instance).Accel = ManNone.None.Default.Accel;
    mdata.(Instance).Accel.t.Value      = [0 mdata.(Instance).tRange.Bump(2)];
    mdata.(Instance).Accel.rPedal.Value = mdata.(Instance).Accel.rPedal.Value(1:2);
    mdata.(Instance).Brake = ManNone.None.Default.Brake;
    mdata.(Instance).Brake.t.Value      = [0 mdata.(Instance).tRange.Bump(2)];
    mdata.(Instance).Brake.rPedal.Value = mdata.(Instance).Brake.rPedal.Value(1:2);
    mdata.(Instance).Steer = ManNone.None.Default.Steer;
    mdata.(Instance).Steer.t.Value      = [0 mdata.(Instance).tRange.Bump(2)];
    mdata.(Instance).Steer.aWheel.Value = mdata.(Instance).Steer.aWheel.Value(1:2);

    
end

if(nargin==0)
    % Assemble structure with inputs for all vehicle classes
    maneuver_data.(maneuver_type) = mdata;
else
    % Return single structure for custom test sequence
    maneuver_data = mdata.(Instance);
end
